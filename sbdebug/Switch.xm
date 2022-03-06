#import "FSSwitchDataSource.h"
#import "FSSwitchPanel.h"
#import <notify.h>

#define kPreferencesPath @"/User/Library/Preferences/com.imokhles.jbflexmanager.plist"
#define kPreferencesChanged "com.imokhles.jbflexmanager.preferences-changed"

#define kEnableTweak @"isTweakEnabledSB"

@interface SBDebugSwitch : NSObject <FSSwitchDataSource>
@end

@implementation SBDebugSwitch

- (NSString *)titleForSwitchIdentifier:(NSString *)switchIdentifier {
	return @"SBDebug";
}

- (FSSwitchState)stateForSwitchIdentifier:(NSString *)switchIdentifier {
	NSDictionary *JBFlexManagerSettings = [NSDictionary dictionaryWithContentsOfFile:kPreferencesPath];
	NSNumber *enableTweakNU = JBFlexManagerSettings[kEnableTweak];
	BOOL editNum = enableTweakNU ? [enableTweakNU boolValue] : 1;
    return editNum ? FSSwitchStateOn : FSSwitchStateOff;
}

- (void)applyState:(FSSwitchState)newState forSwitchIdentifier:(NSString *)switchIdentifier {
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:kPreferencesPath];
    NSMutableDictionary *mutableDict = dict ? [dict mutableCopy] : [NSMutableDictionary dictionary];
    switch (newState) {
        case FSSwitchStateIndeterminate:
            return;
        case FSSwitchStateOn:
            [mutableDict setObject:[NSNumber numberWithBool:YES] forKey:kEnableTweak];
            break;
        case FSSwitchStateOff:
            [mutableDict setObject:[NSNumber numberWithBool:NO] forKey:kEnableTweak];
            break;
    }
    [mutableDict writeToFile:kPreferencesPath atomically:YES];
      notify_post(kPreferencesChanged);
}

@end
