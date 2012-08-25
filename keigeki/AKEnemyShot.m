/*!
 @file AKEnemyShot.m
 @brief 敵弾クラス定義
 
 敵弾を管理するクラスを定義する。
 */

#import "AKEnemyShot.h"

/// 敵弾の画像
static const char *ENEMY_SHOT_IMAGE[ENEMY_SHOT_TYPE_COUNT] = {
    "EnemyShot.png"
};

/// 敵弾のスピード
static const int ENEMY_SHOT_SPEED[ENEMY_SHOT_TYPE_COUNT] = {
    600
};

/// 敵弾の幅
static const int ENEMY_SHOT_WIDTH[ENEMY_SHOT_TYPE_COUNT] = {
    4
};

/// 敵弾の高さ
static const int ENEMY_SHOT_HEIGHT[ENEMY_SHOT_TYPE_COUNT] = {
    4
};

/*!
 @brief 敵弾クラス
 
 敵弾を管理するクラス。
 */
@implementation AKEnemyShot

/*!
 @brief 生成処理
 
 弾を生成する。
 @param type 敵弾の種類
 @param x 生成位置x座標
 @param y 生成位置y座標
 @param z 生成位置z座標
 @param angle 弾の進行方向
 @param parent 弾を配置する親ノード
 */
- (void)createWithType:(enum ENEMY_SHOT_TYPE)type X:(NSInteger)x Y:(NSInteger)y Z:(NSInteger)z
                 Angle:(float)angle Parent:(CCNode *)parent
{
    NSString *fileName = nil;   // 画像のファイル名
    
    // 画像を開放する
    [self.image removeFromParentAndCleanup:YES];
    
    // 画像を読み込む
    fileName = [NSString stringWithUTF8String:ENEMY_SHOT_IMAGE[type]];
    self.image = [CCSprite spriteWithFile:fileName];
    assert(m_image != nil);
    
    // 各種パラメータを設定する
    m_speed = ENEMY_SHOT_SPEED[type];
    m_width = ENEMY_SHOT_WIDTH[type];
    m_height = ENEMY_SHOT_HEIGHT[type];
    
    // パラメータの内容をメンバに設定する
    self.absx = x;
    self.absy = y;
    self.angle = angle;
    
    // メンバの初期値を設定する
    m_hitPoint = 1;
    m_isStaged = YES;
    m_distance = 0.0f;
    
    // レイヤーに配置する
    [parent addChild:self.image z:z];
}
@end
