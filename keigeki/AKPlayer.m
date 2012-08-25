/*!
 @file AKPlayer.m
 @brief 自機クラス定義
 
 自機を管理するクラスを定義する。
 */

#import <math.h>
#import "AKPlayer.h"
#import "AKGameScene.h"

/*!
 @brief 自機クラス

 自機を管理する。
 */
@implementation AKPlayer

@synthesize isInvincible = m_isInvincible;

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

    // 速度の設定
    m_speed = PLAYER_SPEED;
    
    // サイズを設定する
    m_width = PLAYER_SIZE;
    m_height = PLAYER_SIZE;
    
    // 状態を初期化する
    [self reset];
    
    // 画像の読込
    self.image = [CCSprite spriteWithFile:@"Player.png"];
    assert(m_image != nil);
    
    return self;
}

/*!
 @brief キャラクター固有の動作

 速度によって位置を移動する。自機の表示位置は固定とする。
 @param dt フレーム更新間隔
 */
- (void)action:(ccTime)dt
{
    // 無敵状態の時は無敵時間をカウントする
    if (m_isInvincible) {
        m_invincivleTime -= dt;
        
        // 無敵時間が切れている場合は通常状態に戻す
        if (m_invincivleTime < 0) {
            m_isInvincible = NO;
        }
    }
    
    // 自機の表示座標は画面中央下部に固定
    self.image.position = ccp(PLAYER_POS_X, PLAYER_POS_Y);
    
    DBGLOG(0, @"player pos=(%f, %f)", self.image.position.x, self.image.position.y);
    DBGLOG(0, @"player angle=%f speed=%f", m_angle, m_speed);
}

/*!
 @brief 破壊処理
 
 HPが0になったときに爆発エフェクトを生成する。
 */
- (void)destroy
{
    CCParticleSystem *bomb = nil;   // 爆発エフェクト
        
    // 爆発エフェクトを生成する
    bomb = [CCParticleSun node];
    bomb.duration = 0.3f;
    bomb.life = 0.5f;
    bomb.speed = 40;
    bomb.scale = 1.5f;
    
    // 画面効果を生成する
    [[AKGameScene sharedInstance] entryEffect:bomb Time:1.0f PosX:self.absx PosY:self.absy];
    
    // 配置フラグを落とす
    self.isStaged = NO;
    
    // 非表示とする
    self.image.visible = NO;
    
    // 自機破壊時の処理を行う
    [[AKGameScene sharedInstance] miss];
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

/*!
 @brief 復活
 
 破壊された自機を復活させる。
 */
- (void)rebirth
{
    id blink = nil;     // ブリンクアクション
    
    // HPの設定
    m_hitPoint = 1;
    
    // ステージ配置フラグを立てる
    m_isStaged = YES;
    
    // 表示させる
    self.image.visible = YES;
    
    // 無敵状態にする
    m_isInvincible = YES;
    m_invincivleTime = INVINCIBLE_TIME;
    
    // 無敵中はブリンクする
    blink = [CCBlink actionWithDuration:INVINCIBLE_TIME blinks:INVINCIBLE_TIME * 8];
    [self.image runAction:blink];
}

/*!
 @brief 初期化
 
 状態を初期化する。
 */
- (void)reset
{
    // 初期位置は原点
    self.image.position = ccp(0, 0);
    
    // 初期角度は垂直上向き
    m_angle = M_PI / 2;
    
    // HPの設定
    m_hitPoint = 1;
    
    // ステージ配置フラグを立てる
    m_isStaged = YES;
    
    // 表示させる
    self.image.visible = YES;
    
    // 無敵状態はOFFにする
    m_isInvincible = NO;
    m_invincivleTime = 0.0f;
    
    // アクションはすべて停止する
    [self.image stopAllActions];
}
@end
