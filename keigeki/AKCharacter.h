/*!
 @file AKCharacter.h
 @brief キャラクタークラス定義
 
 当たり判定を持つオブジェクトの基本クラスを定義する。
 */

#import <Foundation/Foundation.h>
#import "cocos2d.h"

// キャラクタークラス
@interface AKCharacter : CCNode {
    /// 画像
    CCSprite *m_image;
    /// 当たり判定サイズ幅
    NSInteger m_width;
    /// 当たり判定サイズ高さ
    NSInteger m_height;
    /// 絶対座標x
    float m_absx;
    /// 絶対座標y
    float m_absy;
    /// 速度
    float m_speed;
    /// 向き
    float m_angle;
    /// 回転速度
    float m_rotSpeed;
    /// HP
    NSInteger m_hitPoint;
    /// ステージ上に存在しているかどうか
    BOOL m_isStaged;
}

/// 画像
@property (nonatomic, retain)CCSprite *image;
/// 当たり判定サイズ幅
@property (nonatomic)NSInteger width;
/// 当たり判定サイズ高さ
@property (nonatomic)NSInteger height;
/// 絶対座標x
@property (nonatomic)float absx;
/// 絶対座標y
@property (nonatomic)float absy;
/// 速度
@property (nonatomic)float speed;
/// 向き
@property (nonatomic)float angle;
/// 回転速度
@property (nonatomic)float rotSpeed;
/// HP
@property (nonatomic)NSInteger hitPoint;
/// ステージ上に存在しているかどうか
@property (nonatomic)BOOL isStaged;

// 移動処理
- (void)move:(ccTime)dt ScreenX:(NSInteger)scrx ScreenY:(NSInteger)scry;
// キャラクター固有の動作
- (void)action:(ccTime)dt;
// 破壊処理
- (void)destroy;
// 衝突判定
- (void)hit:(const NSEnumerator *)characters;
@end
