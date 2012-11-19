/*!
 @file AKAppBankNetworkBanner.h
 @brief AppBankNetworkの広告バナー
 
 AppBankNetworkの広告バナーを管理するクラスを定義する。
 */

#import <Foundation/Foundation.h>
#import "GADCustomEventBanner.h"
#import "NADView.h"

// AppBankNetworkの広告バナー
@interface AKAppBankNetworkBanner : NSObject <NADViewDelegate, GADCustomEventBanner> {
    /// デリゲート
    id<GADCustomEventBannerDelegate> delegate_;
    /// 広告バナー
    NADView *nadView_;
}

/// デリゲート
@property (nonatomic, assign)id<GADCustomEventBannerDelegate> delegate;
/// 広告バナー
@property (nonatomic, retain)NADView *nadView;

@end
