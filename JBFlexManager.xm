//
//  JBFlexManager.x
//  JBFlexManager
//
//  Created by iMokhles on 18.10.2015.
//  Copyright (c) 2015 iMokhles. All rights reserved.
//

#import "JBFlexManagerHelper.h"
#import "FLEX/IMLEXManager.h"

%group main

BOOL isTweakEnabled;
BOOL isAppSelected;
static void JBFlexManager_Prefs() {
	NSDictionary *JBFlexManagerSettings = [NSDictionary dictionaryWithContentsOfFile:[JBFlexManagerHelper preferencesPath]];
	NSNumber *isTweakEnabledNU = JBFlexManagerSettings[@"isTweakEnabledSB"];
    isTweakEnabled = isTweakEnabledNU ? [isTweakEnabledNU boolValue] : 0;

}

static void prefs_jbfm() {

}

static void jbfm_HandleUpdate() {
	JBFlexManager_Prefs();
	if (isTweakEnabled) {
		[[IMLEXManager sharedManager] showExplorer];
	} else {
		[[IMLEXManager sharedManager] hideExplorer];
	}
}

static void jbfmInit()
{
	[[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *block) {
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)jbfm_HandleUpdate, [JBFlexManagerHelper preferencesChanged], NULL, 0);
		jbfm_HandleUpdate();

     }];
}


__attribute__((visibility("hidden")))
@interface FLEXMang : NSObject {
@private
}
@end

@implementation FLEXMang

+ (instancetype)sharedInstance
{
    static FLEXMang *_sharedFactory;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        _sharedFactory = [[self alloc] init];
    });

    return _sharedFactory;
}

- (id)init
{
        if ((self = [super init]))
        {

        }
        return self;
}

-(void)addMenu {

	NSDictionary *JBFlexManagerSettings = [NSDictionary dictionaryWithContentsOfFile:[JBFlexManagerHelper preferencesPath]];
	NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
	NSNumber *isAppSelectedNU = JBFlexManagerSettings[[NSString stringWithFormat:@"DisplayIn-%@", bundleIdentifier]];
	isAppSelected = [isAppSelectedNU boolValue];

	if (![bundleIdentifier isEqualToString:@"com.apple.springboard"]) {
		if (isAppSelected) {
			[[IMLEXManager sharedManager] showExplorer];
		}
	}
	// else {
	// 	if (isTweakEnabled) {
	// 		[[FLEXManager sharedManager] showExplorer];
	// 	}
	// }

}

@end

%hook SpringBoard
- (id)init {
	id origSelf = %orig;
	jbfmInit();
	return origSelf;
}
%end
%hook UIWindow
- (BOOL)_handleDelegateCallbacksWithOptions:(id)arg1 isSuspended:(BOOL)arg2 restoreState:(BOOL)arg3 {
	BOOL handleDelegate = %orig();
	return handleDelegate;
}
%end

// %hook UIViewController
// - (void)viewWillAppear:(BOOL)arg1 {
// 	%orig;
// 	if ([self isKindOfClass:%c(PTHTweetbotDirectMessagesController)]) {
// 		UIBarButtonItem *origShareBtn = [self navigationItem].rightBarButtonItem;
// 		UIBarButtonItem *camBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(twb_sendImage)];
// 		[self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:origShareBtn, camBtn, nil]];
// 	}
// }
// // %new
// // - (void)twb_sendImage {
// // 	PTHTweetbotTwitterMediaService *twiImagemedia = [[%c(PTHTweetbotTwitterMediaService) alloc] init];
// // 	[twiImagemedia _uploadImage:[TWBEnhancer9Helper lastTakenImage] medium:nil progress:^{

// // 	} completion:^(NSString *mediaID) {
// // 		NSLog(@"********* %@", mediaID);
// // 	}];
// // }
// %end

// %hook NSURL
// + (id)URLWithString:(id)arg1 {
// 	NSLog(@"************ URLWithString %@", arg1);
// 	return %orig(arg1);
// }
// %end
%ctor {
    [[NSNotificationCenter defaultCenter] addObserver:[FLEXMang sharedInstance] selector:@selector(addMenu) name:UIApplicationDidBecomeActiveNotification object:nil];
}

%end


%ctor {
	@autoreleasepool {
		NSArray *args = [NSClassFromString(@"NSProcessInfo") processInfo].arguments;
    if (args.count) {
        NSString *executablePath = args[0];
        if ([executablePath containsString:@".appex"] || [executablePath containsString:@".bundle"] ||
            [executablePath containsString:@".framework"] || (![executablePath containsString:@"/Application"] &&
            ![[executablePath lastPathComponent] isEqualToString:@"SpringBoard"])) {
            return;
        }
    }
		%init(main);
	}
}
