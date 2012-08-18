/*!
 @file GameConfig.h
 @brief cocos2d定数定義
 
 cocos2dのテンプレートで自動生成される定数定義ファイル。
 */

#ifndef __GAME_CONFIG_H
#define __GAME_CONFIG_H

//
// Supported Autorotations:
//		None,
//		UIViewController,
//		CCDirector
//
/// Supported Autorotations:None
#define kGameAutorotationNone 0
/// Supported Autorotations:CCDirector
#define kGameAutorotationCCDirector 1
/// Supported Autorotations:UIViewController,
#define kGameAutorotationUIViewController 2

//
// Define here the type of autorotation that you want for your game
//

// 3rd generation and newer devices: Rotate using UIViewController. Rotation should be supported on iPad apps.
// TIP:
// To improve the performance, you should set this value to "kGameAutorotationNone" or "kGameAutorotationCCDirector"
#if defined(__ARM_NEON__) || TARGET_IPHONE_SIMULATOR
/// Game Autorotation定数定義。CPU種別で変わる。
#define GAME_AUTOROTATION kGameAutorotationUIViewController

// ARMv6 (1st and 2nd generation devices): Don't rotate. It is very expensive
#elif __arm__
/// Game Autorotation定数定義。CPU種別で変わる。
#define GAME_AUTOROTATION kGameAutorotationNone


// Ignore this value on Mac
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)

#else
#error(unknown architecture)
#endif

#endif // __GAME_CONFIG_H

