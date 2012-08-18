/*!
 @file AKRadar.h
 @brief レーダークラス定義
 
 敵のいる方向を示すレーダーを管理するクラスを定義する。
 */

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "common.h"

/// レーダーのサイズ
#define RADAR_SIZE 128
/// レーダーの配置位置x座標
#define RADAR_POS_X (SCREEN_WIDTH - 80)
/// レーダーの配置位置y座標
#define RADAR_POS_Y (SCREEN_HEIGHT - 130)

// レーダークラス
@interface AKRadar : CCNode {
    /// レーダーの画像
    CCSprite *m_radarImage;
    /// マーカーの画像
    NSMutableArray *m_markerImage;
}

/// レーダーの画像
@property (nonatomic, retain)CCSprite *radarImage;
/// マーカーの画像
@property (nonatomic, retain)NSMutableArray *markerImage;

// マーカーの配置位置更新処理
- (void)updateMarker:(const NSArray *)enemys ScreenAngle:(float)screenAngle;

@end
