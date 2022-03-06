#line 1 "JBFlexManager.xm"








#import "JBFlexManagerHelper.h"
#import "FLEX/IMLEXManager.h"


#include <substrate.h>
#if defined(__clang__)
#if __has_feature(objc_arc)
#define _LOGOS_SELF_TYPE_NORMAL __unsafe_unretained
#define _LOGOS_SELF_TYPE_INIT __attribute__((ns_consumed))
#define _LOGOS_SELF_CONST const
#define _LOGOS_RETURN_RETAINED __attribute__((ns_returns_retained))
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif

@class UIWindow; @class SpringBoard; 


#line 12 "JBFlexManager.xm"
static SpringBoard* (*_logos_orig$main$SpringBoard$init)(_LOGOS_SELF_TYPE_INIT SpringBoard*, SEL) _LOGOS_RETURN_RETAINED; static SpringBoard* _logos_method$main$SpringBoard$init(_LOGOS_SELF_TYPE_INIT SpringBoard*, SEL) _LOGOS_RETURN_RETAINED; static BOOL (*_logos_orig$main$UIWindow$_handleDelegateCallbacksWithOptions$isSuspended$restoreState$)(_LOGOS_SELF_TYPE_NORMAL UIWindow* _LOGOS_SELF_CONST, SEL, id, BOOL, BOOL); static BOOL _logos_method$main$UIWindow$_handleDelegateCallbacksWithOptions$isSuspended$restoreState$(_LOGOS_SELF_TYPE_NORMAL UIWindow* _LOGOS_SELF_CONST, SEL, id, BOOL, BOOL); 

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


+ (instancetype)sharedInstance {
    static FLEXMang *_sharedFactory;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        _sharedFactory = [[self alloc] init];
    });

    return _sharedFactory;
}


- (id)init {
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
	
	
	
	
	

}

@end


static SpringBoard* _logos_method$main$SpringBoard$init(_LOGOS_SELF_TYPE_INIT SpringBoard* __unused self, SEL __unused _cmd) _LOGOS_RETURN_RETAINED {
	id origSelf = _logos_orig$main$SpringBoard$init(self, _cmd);
	jbfmInit();
	return origSelf;
}


static BOOL _logos_method$main$UIWindow$_handleDelegateCallbacksWithOptions$isSuspended$restoreState$(_LOGOS_SELF_TYPE_NORMAL UIWindow* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, id arg1, BOOL arg2, BOOL arg3) {
	BOOL handleDelegate = _logos_orig$main$UIWindow$_handleDelegateCallbacksWithOptions$isSuspended$restoreState$(self, _cmd, arg1, arg2, arg3);
	return handleDelegate;
}




























static __attribute__((constructor)) void _logosLocalCtor_2cde6470(int __unused argc, char __unused **argv, char __unused **envp) {

    [[NSNotificationCenter defaultCenter] addObserver:[FLEXMang sharedInstance] selector:@selector(addMenu) name:UIApplicationDidBecomeActiveNotification object:nil];

}




static __attribute__((constructor)) void _logosLocalCtor_4de51287(int __unused argc, char __unused **argv, char __unused **envp) {
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
		{Class _logos_class$main$SpringBoard = objc_getClass("SpringBoard"); MSHookMessageEx(_logos_class$main$SpringBoard, @selector(init), (IMP)&_logos_method$main$SpringBoard$init, (IMP*)&_logos_orig$main$SpringBoard$init);Class _logos_class$main$UIWindow = objc_getClass("UIWindow"); MSHookMessageEx(_logos_class$main$UIWindow, @selector(_handleDelegateCallbacksWithOptions:isSuspended:restoreState:), (IMP)&_logos_method$main$UIWindow$_handleDelegateCallbacksWithOptions$isSuspended$restoreState$, (IMP*)&_logos_orig$main$UIWindow$_handleDelegateCallbacksWithOptions$isSuspended$restoreState$);}
	}
}
