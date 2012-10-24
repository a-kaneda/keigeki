/*!
 @file AKRadar.h
 @brief レーダークラス定義
 
 敵のいる方向を示すレーダーを管理するクラスを定義する。
 */

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AKCommon.h"

// レーダークラス
@interface AKRadar : CCNode {
    /// レーダーの画像
    CCSprite *radarImage_;
    /// マーカーの画像
    NSMutableArray *markerImage_;
}

/// レーダーの画像
@property (nonatomic, retain)CCSprite *radarImage;
/// マーカーの画像
@property (nonatomic, retain)NSMutableArray *markerImage;

// マーカーの配置位置更新処理
- (void)updateMarker:(const NSArray *)enemys ScreenAngle:(float)screenAngle;

@end
