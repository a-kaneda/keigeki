/*!
 @file AKCharacter.h
 @brief キャラクタークラス定義
 
 当たり判定を持つオブジェクトの基本クラスを定義する。
 */

#import <Foundation/Foundation.h>
#import "cocos2d.h"

// キャラクタークラス
@interface AKCharacter : NSObject {
    /// 画像
    CCNode *image_;
    /// 当たり判定サイズ幅
    NSInteger width_;
    /// 当たり判定サイズ高さ
    NSInteger height_;
    /// 絶対座標x
    float absx_;
    /// 絶対座標y
    float absy_;
    /// 速度
    float speed_;
    /// 向き
    float angle_;
    /// 回転速度
    float rotSpeed_;
    /// HP
    NSInteger hitPoint_;
    /// ステージ上に存在しているかどうか
    BOOL isStaged_;
}

/// 画像
@property (nonatomic, retain)CCNode *image;
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
