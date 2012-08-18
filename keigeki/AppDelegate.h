/*!
 @file AppDelegate.h
 @brief Application controller定義
 
 Application controllerを定義する。
 */


#import <UIKit/UIKit.h>
#import "cocos2d.h"

// Application controller
@interface AppController : NSObject <UIApplicationDelegate, CCDirectorDelegate>
{
    /// Main window
	UIWindow *window_;
    /// Navigation controller
	UINavigationController *navController_;
    /// Director
	CCDirectorIOS	*director_;							// weak ref
}

/// Main window
@property (nonatomic, retain) UIWindow *window;
/// Navigation controller
@property (readonly) UINavigationController *navController;
/// Director
@property (readonly) CCDirectorIOS *director;

@end
