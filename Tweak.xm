#import <UIKit/UIKit.h>

NSString *quote;

#define PLIST_PATH_Settings "/var/mobile/Library/Preferences/com.laughingquoll.reachquote.plist"


@interface SBWindow : UIWindow
@end

@interface SBReachabilityManager
+ (BOOL)reachabilitySupported;
@end

%hook SBMainWorkspace

-(void)handleReachabilityModeActivated {
	%orig;

  SBWindow *backgroundView = MSHookIvar<SBWindow*>(self,"_reachabilityEffectWindow");
  UIView *view = [UIView new];
  view.frame = backgroundView.frame;
  [backgroundView addSubview:view];

  UILabel * lirycLabel = [UILabel new];
  lirycLabel.textColor = [UIColor whiteColor];
  lirycLabel.textAlignment =  NSTextAlignmentCenter;
  lirycLabel.frame = CGRectMake(0,0,backgroundView.frame.size.width,backgroundView.frame.size.height);
  lirycLabel.font = [UIFont fontWithName:@"Arial Rounded MT Bold" size:(18)];
  lirycLabel.text = quote;
  [view addSubview:lirycLabel];

}
-(void)handleReachabilityModeDeactivated {
	%orig;
}

%end

static void settingsChangednotum(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
    @autoreleasepool {
        NSDictionary *NotumPrefs = [[[NSDictionary alloc] initWithContentsOfFile:@PLIST_PATH_Settings]?:[NSDictionary dictionary] copy];

        quote = [NotumPrefs objectForKey:@"quote"];
    }
}


__attribute__((constructor)) static void initialize_notum()
{
    @autoreleasepool {
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, settingsChangednotum, CFSTR("com.laughingquoll.reachquote/changed"), NULL, CFNotificationSuspensionBehaviorCoalesce);
        settingsChangednotum(NULL, NULL, NULL, NULL, NULL);
    }
}
