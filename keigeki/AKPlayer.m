/*!
 @file AKPlayer.m
 @brief 自機クラス定義
 
 自機を管理するクラスを定義する。
 */

#import "AKPlayer.h"
#import <math.h>

/*!
 @brief 自機クラス

 自機を管理する。
 */
@implementation AKPlayer

/*!
 @brief オブジェクト生成処理

 オブジェクトの生成を行う。
 @return 生成したオブジェクト。失敗時はnilを返す。
 */
- (id)init
{
    // スーパークラスの生成処理
    self = [super init];
    if (!self) {
        return nil;
    }
    
    // 初期角度は垂直上向き
    m_angle = M_PI / 2;
    
    // HPの設定
    m_hitPoint = 1;
    
    // 速度の設定
    m_speed = PLAYER_SPEED;
    
    // ステージ配置フラグを立てる
    m_isStaged = YES;
    
    // 画像の読込
    self.image = [CCSprite spriteWithFile:@"Player.png"];
    assert(m_image != nil);
    
    // 画像をノードに配置する
    [self addChild:m_image];
    
    return self;
}

/*!
 @brief キャラクター固有の動作

 速度によって位置を移動する。自機の表示位置は固定とする。
 @param dt フレーム更新間隔
 */
- (void)action:(ccTime)dt
{
    // 自機の表示座標は画面中央下部に固定
    self.position = ccp(PLAYER_POS_X, PLAYER_POS_Y);
    
    DBGLOG(0, @"player pos=(%f, %f)", self.position.x, self.position.y);
    DBGLOG(0, @"player angle=%f speed=%f", m_angle, m_speed);
}

/*!
 @brief スクリーン座標(x座標)の取得

 自機の絶対座標からスクリーン座標を計算して返す。x座標を求める。
 @return スクリーン座標(x座標)
 */
- (float)getScreenPosX
{
    return AKRangeCheckLF(self.absx + SCREEN_WIDTH / 2 - PLAYER_POS_X, 0.0f, STAGE_WIDTH);
}

/*!
 @brief スクリーン座標(y座標)の取得

 自機の絶対座標からスクリーン座標を計算して返す。x座標を求める。
 @return スクリーン座標(y座標)
 */
- (float)getScreenPosY
{
    return AKRangeCheckLF(self.absy + SCREEN_HEIGHT / 2 - PLAYER_POS_Y, 0.0f, STAGE_HEIGHT);
}

/*!
 @brief 速度の設定

 速度を設定する。-0.1〜0.1の範囲で指定する。
 @param vx x軸方向の速度
 @param vy y軸方向の速度
 */
- (void)setVelocityX:(float)vx Y:(float)vy
{
    // スピードは縦方向の傾きから決定する
    m_speed = (vy + 1.5) * PLAYER_SPEED;
    
    // 角速度は横方向の傾きから決定する
    m_rotSpeed = -1 * vx * PLAYER_ROT_SPEED;
}

@end
