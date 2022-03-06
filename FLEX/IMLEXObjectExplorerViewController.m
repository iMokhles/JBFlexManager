//
//  IMLEXObjectExplorerViewController.m
//  Flipboard
//
//  Created by Ryan Olson on 2014-05-03.
//  Copyright (c) 2020 Flipboard. All rights reserved.
//

#import "IMLEXObjectExplorerViewController.h"
#import "IMLEXUtility.h"
#import "IMLEXRuntimeUtility.h"
#import "UIBarButtonItem+IMLEX.h"
#import "IMLEXMultilineTableViewCell.h"
#import "IMLEXObjectExplorerFactory.h"
#import "IMLEXFieldEditorViewController.h"
#import "IMLEXMethodCallingViewController.h"
#import "IMLEXObjectListViewController.h"
#import "IMLEXTabsViewController.h"
#import "IMLEXBookmarkManager.h"
#import "IMLEXTableView.h"
#import "IMLEXResources.h"
#import "IMLEXTableViewCell.h"
#import "IMLEXScopeCarousel.h"
#import "IMLEXMetadataSection.h"
#import "IMLEXSingleRowSection.h"
#import "IMLEXShortcutsSection.h"
#import "NSUserDefaults+IMLEX.h"
#import <objc/runtime.h>

#pragma mark - Private properties
@interface IMLEXObjectExplorerViewController () <UIGestureRecognizerDelegate>
@property (nonatomic, readonly) IMLEXSingleRowSection *descriptionSection;
@property (nonatomic, readonly) IMLEXTableViewSection *customSection;
@property (nonatomic) NSIndexSet *customSectionVisibleIndexes;

@property (nonatomic, readonly) NSArray<NSString *> *observedNotifications;

@end

@implementation IMLEXObjectExplorerViewController

#pragma mark - Initialization

+ (instancetype)exploringObject:(id)target {
    return [self exploringObject:target customSection:[IMLEXShortcutsSection forObject:target]];
}

+ (instancetype)exploringObject:(id)target customSection:(IMLEXTableViewSection *)section {
    return [[self alloc]
        initWithObject:target
        explorer:[IMLEXObjectExplorer forObject:target]
        customSection:section
    ];
}

- (id)initWithObject:(id)target
            explorer:(__kindof IMLEXObjectExplorer *)explorer
       customSection:(IMLEXTableViewSection *)customSection {
    NSParameterAssert(target);
    
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        _object = target;
        _explorer = explorer;
        _customSection = customSection;
    }

    return self;
}

- (NSArray<NSString *> *)observedNotifications {
    return @[
        kIMLEXDefaultsHidePropertyIvarsKey,
        kIMLEXDefaultsHidePropertyMethodsKey,
        kIMLEXDefaultsHideMethodOverridesKey,
    ];
}

#pragma mark - View controller lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    self.showsShareToolbarItem = YES;
    self.wantsSectionIndexTitles = YES;

    // Use [object class] here rather than object_getClass
    // to avoid the KVO prefix for observed objects
    self.title = [[self.object class] description];

    // Search
    self.showsSearchBar = YES;
    self.searchBarDebounceInterval = kIMLEXDebounceInstant;
    self.showsCarousel = YES;

    // Carousel scope bar
    [self.explorer reloadClassHierarchy];
    self.carousel.items = [self.explorer.classHierarchyClasses IMLEX_mapped:^id(Class cls, NSUInteger idx) {
        return NSStringFromClass(cls);
    }];
    
    // ... button for extra options
    [self addToolbarItems:@[[UIBarButtonItem
        itemWithImage:IMLEXResources.moreIcon target:self action:@selector(moreButtonPressed)
    ]]];

    // Swipe gestures to swipe between classes in the hierarchy
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc]
        initWithTarget:self action:@selector(handleSwipeGesture:)
    ];
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc]
        initWithTarget:self action:@selector(handleSwipeGesture:)
    ];
    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    leftSwipe.delegate = self;
    rightSwipe.delegate = self;
    [self.tableView addGestureRecognizer:leftSwipe];
    [self.tableView addGestureRecognizer:rightSwipe];
    
    // Observe preferences which may change on other screens
    //
    // "If your app targets iOS 9.0 and later or macOS 10.11 and later,
    // you don't need to unregister an observer in its dealloc method."
    NSArray<NSString *> *observedNotifications = @[
        kIMLEXDefaultsHidePropertyIvarsKey,
        kIMLEXDefaultsHidePropertyMethodsKey,
        kIMLEXDefaultsHideMethodOverridesKey,
    ];
    for (NSString *pref in observedNotifications) {
        [NSNotificationCenter.defaultCenter
            addObserver:self
            selector:@selector(fullyReloadData)
            name:pref
            object:nil
        ];
    }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    [self.navigationController setToolbarHidden:NO animated:YES];
    return YES;
}


#pragma mark - Overrides

/// Override to hide the description section when searching
- (NSArray<IMLEXTableViewSection *> *)nonemptySections {
    if (self.shouldShowDescription) {
        return super.nonemptySections;
    }
    
    return [super.nonemptySections IMLEX_filtered:^BOOL(IMLEXTableViewSection *section, NSUInteger idx) {
        return section != self.descriptionSection;
    }];
}

- (NSArray<IMLEXTableViewSection *> *)makeSections {
    IMLEXObjectExplorer *explorer = self.explorer;
    
    // Description section is only for instances
    if (self.explorer.objectIsInstance) {
        _descriptionSection = [IMLEXSingleRowSection
            title:@"Description" reuse:kIMLEXMultilineCell cell:^(IMLEXTableViewCell *cell) {
                cell.titleLabel.font = UIFont.IMLEX_defaultTableCellFont;
                cell.titleLabel.text = explorer.objectDescription;
            }
        ];
        self.descriptionSection.filterMatcher = ^BOOL(NSString *filterText) {
            return [explorer.objectDescription localizedCaseInsensitiveContainsString:filterText];
        };
    }

    // Object graph section
    IMLEXSingleRowSection *referencesSection = [IMLEXSingleRowSection
        title:@"Object Graph" reuse:kIMLEXDefaultCell cell:^(IMLEXTableViewCell *cell) {
            cell.titleLabel.text = @"See Objects with References to This Object";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
    ];
    referencesSection.selectionAction = ^(UIViewController *host) {
        UIViewController *references = [IMLEXObjectListViewController
            objectsWithReferencesToObject:explorer.object
        ];
        [host.navigationController pushViewController:references animated:YES];
    };

    NSMutableArray *sections = [NSMutableArray arrayWithArray:@[
        [IMLEXMetadataSection explorer:self.explorer kind:IMLEXMetadataKindProperties],
        [IMLEXMetadataSection explorer:self.explorer kind:IMLEXMetadataKindClassProperties],
        [IMLEXMetadataSection explorer:self.explorer kind:IMLEXMetadataKindIvars],
        [IMLEXMetadataSection explorer:self.explorer kind:IMLEXMetadataKindMethods],
        [IMLEXMetadataSection explorer:self.explorer kind:IMLEXMetadataKindClassMethods],
        [IMLEXMetadataSection explorer:self.explorer kind:IMLEXMetadataKindClassHierarchy],
        [IMLEXMetadataSection explorer:self.explorer kind:IMLEXMetadataKindProtocols],
        [IMLEXMetadataSection explorer:self.explorer kind:IMLEXMetadataKindOther],
        referencesSection
    ]];

    if (self.customSection) {
        [sections insertObject:self.customSection atIndex:0];
    }
    if (self.descriptionSection) {
        [sections insertObject:self.descriptionSection atIndex:0];
    }

    return sections.copy;
}

/// In our case, all this does is reload the table view,
/// or reload the sections' data if we changed places
/// in the class hierarchy. Doesn't refresh \c self.explorer
- (void)reloadData {
    // Check to see if class scope changed, update accordingly
    if (self.explorer.classScope != self.selectedScope) {
        self.explorer.classScope = self.selectedScope;
        [self reloadSections];
    }
    
    [super reloadData];
}

- (void)shareButtonPressed {
    [IMLEXAlert makeSheet:^(IMLEXAlert *make) {
        make.button(@"Add to Bookmarks").handler(^(NSArray<NSString *> *strings) {
            [IMLEXBookmarkManager.bookmarks addObject:self.object];
        });
        make.button(@"Copy Description").handler(^(NSArray<NSString *> *strings) {
            UIPasteboard.generalPasteboard.string = self.explorer.objectDescription;
        });
        make.button(@"Copy Address").handler(^(NSArray<NSString *> *strings) {
            UIPasteboard.generalPasteboard.string = [IMLEXUtility addressOfObject:self.object];
        });
        make.button(@"Cancel").cancelStyle();
    } showFrom:self];
}


#pragma mark - Private

/// Unlike \c -reloadData, this refreshes everything, including the explorer.
- (void)fullyReloadData {
    [self.explorer reloadMetadata];
    [self reloadSections];
    [self reloadData];
}

- (void)handleSwipeGesture:(UISwipeGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        switch (gesture.direction) {
            case UISwipeGestureRecognizerDirectionRight:
                if (self.selectedScope > 0) {
                    self.selectedScope -= 1;
                }
                break;
            case UISwipeGestureRecognizerDirectionLeft:
                if (self.selectedScope != self.explorer.classHierarchy.count - 1) {
                    self.selectedScope += 1;
                }
                break;

            default:
                break;
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)g1 shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)g2 {
    // Prioritize important pan gestures over our swipe gesture
    if ([g2 isKindOfClass:[UIPanGestureRecognizer class]]) {
        if (g2 == self.navigationController.interactivePopGestureRecognizer ||
            g2 == self.navigationController.barHideOnSwipeGestureRecognizer ||
            g2 == self.tableView.panGestureRecognizer) {
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UISwipeGestureRecognizer *)gesture {
    // Don't allow swiping from the carousel
    CGPoint location = [gesture locationInView:self.tableView];
    if ([self.carousel hitTest:location withEvent:nil]) {
        return NO;
    }
    
    return YES;
}
    
- (void)moreButtonPressed {
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    // Maps preference keys to a description of what they affect
    NSDictionary<NSString *, NSString *> *explorerToggles = @{
        kIMLEXDefaultsHidePropertyIvarsKey:   @"Property-Backing Ivars",
        kIMLEXDefaultsHidePropertyMethodsKey: @"Property-Backing Methods",
        kIMLEXDefaultsHideMethodOverridesKey: @"Method Overrides",
    };
    
    // Maps the key of the action itself to a map of a description
    // of the action ("hide X") mapped to the current state.
    //
    // So keys that are hidden by default have NO mapped to "Show"
    NSDictionary<NSString *, NSDictionary *> *nextStateDescriptions = @{
        kIMLEXDefaultsHidePropertyIvarsKey:   @{ @NO: @"Hide ", @YES: @"Show " },
        kIMLEXDefaultsHidePropertyMethodsKey: @{ @NO: @"Hide ", @YES: @"Show " },
        kIMLEXDefaultsHideMethodOverridesKey: @{ @NO: @"Show ", @YES: @"Hide " },
    };
    
    [IMLEXAlert makeSheet:^(IMLEXAlert *make) {
        make.title(@"Options");
        
        for (NSString *option in explorerToggles.allKeys) {
            BOOL current = [defaults boolForKey:option];
            NSString *title = [nextStateDescriptions[option][@(current)]
                stringByAppendingString:explorerToggles[option]
            ];
            make.button(title).handler(^(NSArray<NSString *> *strings) {
                [NSUserDefaults.standardUserDefaults toggleBoolForKey:option];
                [self fullyReloadData];
            });
        }
        
        make.button(@"Cancel").cancelStyle();
    } showFrom:self];
}

#pragma mark - Description

- (BOOL)shouldShowDescription {
    // Hide if we have filter text; it is rarely
    // useful to see the description when searching
    // since it's already at the top of the screen
    if (self.filterText.length) {
        return NO;
    }

    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // For the description section, we want that nice slim/snug looking row.
    // Other rows use the automatic size.
    IMLEXTableViewSection *section = self.filterDelegate.sections[indexPath.section];
    
    if (section == self.descriptionSection) {
        NSAttributedString *attributedText = [[NSAttributedString alloc]
            initWithString:self.explorer.objectDescription
            attributes:@{ NSFontAttributeName : UIFont.IMLEX_defaultTableCellFont }
        ];
        
        return [IMLEXMultilineTableViewCell
            preferredHeightWithAttributedText:attributedText
            maxWidth:tableView.frame.size.width - tableView.separatorInset.right
            style:tableView.style
            showsAccessory:NO
        ];
    }

    return UITableViewAutomaticDimension;
}

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.filterDelegate.sections[indexPath.section] == self.descriptionSection;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    // Only the description section has "actions"
    if (self.filterDelegate.sections[indexPath.section] == self.descriptionSection) {
        return action == @selector(copy:);
    }

    return NO;
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    if (action == @selector(copy:)) {
        UIPasteboard.generalPasteboard.string = self.explorer.objectDescription;
    }
}

@end
