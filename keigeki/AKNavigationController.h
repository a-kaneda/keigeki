/*!
 @file AKNavigationController.h
 @brief UINavigationControllerのカスタマイズ
 
 UINavigationControllerのカスタマイズクラスを定義する。
 */

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import "GADBannerView.h"
#import "GADBannerViewDelegate.h"

// UINavigationControllerのカスタマイズ
@interface AKNavigationController : UINavigationController<GKLeaderboardViewControllerDelegate,
    GKAchievementViewControllerDelegate, GADBannerViewDelegate> {
    
    /// 広告バナー
    GADBannerView *bannerView_;
}

/// 広告バナー
@property (nonatomic, retain)GADBannerView *bannerView;

// Twitter Viewの表示
- (void)viewTwitterWithInitialString:(NSString *)string;

@end
