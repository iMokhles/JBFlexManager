#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "PFStatusBarAlert.h"

static void statusbar_got_notification(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo )
{
    if (observer)
        [(PFStatusBarAlert *)observer showOverlayForSeconds:5.5];
}

int oldLevel;
@implementation PFStatusBarAlert

@synthesize statusBarOverlay=_statusBarOverlay, message=_message, notification=_notification, action=_action;
@synthesize target=_target, actionButton=_actionButton, backgroundColor=_backgroundColor, textColor=_textColor;

- (id)initWithMessage:(NSString *)message notification:(NSString *)notification action:(SEL)action target:(id)target
{
 self = [self init];

 // checking for screen orientation change
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateStatusBarFrame) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];

// checking for status bar change
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateStatusBarFrame) name:UIApplicationWillChangeStatusBarFrameNotification object:nil];


 self.message = message;

 if (notification)
  _notification = [notification copy];

 self.action = action;
 self.target = target;

 if (self.notification)
 {
  CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), self, (CFNotificationCallback)statusbar_got_notification,
  (CFStringRef)self.notification, NULL, CFNotificationSuspensionBehaviorCoalesce);
 }



 self.statusBarOverlay = [UIApplication sharedApplication].keyWindow;
 oldLevel = self.statusBarOverlay.windowLevel;
 //  [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [[UIApplication sharedApplication] statusBarFrame].size.height)];
 // self.statusBarOverlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
 // self.statusBarOverlay.alpha = 0.0f;

 self.actionButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 20)];
 self.actionButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
 if (self.target && self.action)
  [self.actionButton addTarget:self.target action:self.action forControlEvents:UIControlEventTouchUpInside];


 self.backgroundColor = [UIColor blueColor];
 self.textColor = [UIColor whiteColor];

 self.actionButton.backgroundColor = self.backgroundColor;

 return self;
}

- (void)updateStatusBarFrame
{
    UIView *view = self.actionButton;
    view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 20);
}

- (void)showOverlayForSeconds:(float)seconds
{

  if (self.actionButton.isHidden)
    self.actionButton.hidden = NO;

  self.statusBarOverlay.windowLevel = UIWindowLevelStatusBar;
  // [self.statusBarOverlay makeKeyAndVisible];



  [self.actionButton setTitle:self.message forState:UIControlStateNormal];
  [self.actionButton setTitleColor:self.textColor forState:UIControlStateNormal];
  self.actionButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];

  [self.statusBarOverlay addSubview:self.actionButton];
  [self.statusBarOverlay bringSubviewToFront:self.actionButton];

  [UIView animateWithDuration:0.3f animations:^{

    // self.statusBarOverlay.alpha = 1.0f;
    self.actionButton.alpha = 1.0f;

  } completion:^(BOOL finished) {

    [NSTimer scheduledTimerWithTimeInterval:seconds
    target:self
    selector:@selector(hideOverlay)
    userInfo:nil
    repeats:NO];

  }];
}

- (void)hideOverlay
{
  [UIView animateWithDuration:0.3f animations:^{

    // self.statusBarOverlay.alpha = 0.0f;
    self.actionButton.alpha = 0.0f;
    self.statusBarOverlay.windowLevel = oldLevel;
  } completion:^(BOOL finished) {
    // self.statusBarOverlay.hidden = YES;
    [self.actionButton removeFromSuperview];
    self.actionButton.hidden = YES;
  }];
}

- (void)dealloc
{
  self.message = nil;
  // self.statusBarOverlay = nil;
  self.target = nil;

  if (_notification)
    [_notification release];

  self.actionButton = nil;
  self.backgroundColor = nil;
  self.textColor = nil;

  [super dealloc];
}

@end
