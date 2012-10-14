/*!
 @file AKNavigationController.h
 @brief UINavigationControllerのカスタマイズ
 
 UINavigationControllerのカスタマイズクラスを定義する。
 */

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

// UINavigationControllerのカスタマイズ
@interface AKNavigationController : UINavigationController<GKLeaderboardViewControllerDelegate>

@end
