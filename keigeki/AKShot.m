/*!
 @file AKShot.m
 @brief 弾クラス定義
 
 弾を管理するクラスを定義する。
 */

#import "AKShot.h"
#import "common.h"

/// 弾の射程距離
static const NSInteger kAKShotRange = 600;

/*!
 @brief 弾クラス
 
 弾を管理するクラス。一定距離まっすぐ進んだあとに消える。
 */
@implementation AKShot

/*!
 @brief キャラクター固有の動作
 
 射程距離を外れたとき画面から取り除く。
 @param dt フレーム更新間隔
 */
- (void)action:(ccTime)dt
{
    // 移動距離をカウントする
    m_distance -= m_speed * dt;
    DBGLOG(0, @"m_distance=%f", m_distance);
    
    // 移動距離が射程距離を超えた場合は弾を削除する
    if (m_distance < 0.0f) {
        m_hitPoint = -1.0f;
        DBGLOG(0, @"shot delete.");
    }
}

/*!
 @brief 生成処理
 
 弾を生成する。
 @param x 生成位置x座標
 @param y 生成位置y座標
 @param z 生成位置z座標
 @param angle 弾の進行方向
 @param parent 弾を配置する親ノード
 */
- (void)createWithX:(NSInteger)x Y:(NSInteger)y Z:(NSInteger)z Angle:(float)angle
             Parent:(CCNode *)parent
{
    // パラメータの内容をメンバに設定する
    self.absx = x;
    self.absy = y;
    self.angle = angle;
    
    // メンバの初期値を設定する
    m_hitPoint = 1;
    m_isStaged = YES;
    m_distance = kAKShotRange;
    
    assert(self.image != nil);
    
    // レイヤーに配置する
    [parent addChild:self.image z:z];
}
@end
