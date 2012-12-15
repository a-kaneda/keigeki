/*!
 @file AKEnemy.m
 @brief 敵クラス定義
 
 敵キャラクターのクラスの定義をする。
 */

#import "SimpleAudioEngine.h"
#import "AKEnemy.h"
#import "AKGameScene.h"
#import "AKGameCenterHelper.h"

/// 敵を倒したときのスコア
static const NSInteger kAKEnemyScore = 500;
/// 破壊時の効果音
static NSString *kAKHitSE = @"Hit.caf";
/// 背面攻撃の実績解除のcosしきい値
static float kAKBackShortCos = -0.95f;

/// 雑魚の移動速度
static const NSInteger kAKEnemySpeed = 240;
/// 雑魚の回転速度
static const float kAKEnemyRotSpeed = 0.3f;
/// 雑魚の弾発射の時間
static const NSInteger kAKEnemyActionTime = 5;
/// 雑魚の敵のサイズ
static const NSInteger kAKEnemySize = 16;

/// 大砲の移動速度
static const NSInteger kAKCanonSpeed = 120;
/// 大砲の回転速度
static const float kAKCanonRotSpeed = 0.7f;


/// 爆発エフェクト画像のファイル名
static NSString *kAKExplosion = @"Explosion.png";
/// 爆発エフェクトの位置とサイズ
static const CGRect kAKExplosionRect = {0, 0, 32, 32};
/// 爆発エフェクトのフレーム数
static const NSInteger kAKExplosionFrameCount = 8;
/// 爆発エフェクトのフレーム更新間隔
static const float kAKExplosionFrameDelay = 0.2f;

/*!
 @brief 敵クラス
 
 敵キャラクターのクラス。
 */
@implementation AKEnemy

/*!
 @brief キャラクター固有の動作

 生成時に指定されたセレクタを呼び出す。
 @param dt フレーム更新間隔
 */
- (void)action:(ccTime)dt
{
    NSNumber *objdt = NULL;     // フレーム更新間隔(オブジェクト版)
    
    // 動作開始からの経過時間をカウントする
    time_ += dt;
    
    // id型として渡すためにNSNumberを作成する
    objdt = [NSNumber numberWithFloat:dt];
    
    // 敵種別ごとの処理を実行
    [self performSelector:action_ withObject:objdt];
}

/*!
 @brief 破壊処理

 HPが0になったときに敵種別固有の破壊処理を呼び出す。
 */
- (void)destroy
{
    NSInteger score = 0;    // 加算スコア
    float destAngle = 0.0f; // 敵から自機への角度
    
    // 破壊時の効果音を鳴らす
    [[SimpleAudioEngine sharedEngine] playEffect:kAKHitSE];
    
    // 敵種別ごとの処理を実行
    [self performSelector:destroy_];
    
    // 敵の向きによって加算するスコアを変える。
    // 後ろを向いている場合が最大とする。
    destAngle = AKCalcDestAngle(self.image.position.x, self.image.position.y,
                                AKPlayerPosX(), AKPlayerPosY());
    score = kAKEnemyScore * (2 - cos(destAngle - self.angle));
    
    AKLog(1, @"destAngle=%f self.angle=%f cos()=%f", destAngle, self.angle, cos(destAngle - self.angle));
    // cos値が背面攻撃のしきい値よりも小さい場合は実績を解除する
    if (cos(destAngle - self.angle) < kAKBackShortCos) {
        [[AKGameCenterHelper sharedHelper] reportAchievements:kAKGCBackShootID];
    }
    
    // スコアを加算する
    [[AKGameScene getInstance] addScore:score];
    
    // 画像の解放
    [self.image removeFromParentAndCleanup:YES];
    self.image = nil;
    
    // スーパークラスの処理を行う
    [super destroy];
}

/*!
 @brief 生成処理

 敵キャラを生成する。
 @param x 生成位置x座標
 @param y 生成位置y座標
 @param z 生成位置z座標
 @param angle 敵キャラの初期向き
 @param parent 敵キャラを配置する親ノード
 @param create 種別ごとの生成処理
 */
- (void)createWithX:(NSInteger)x Y:(NSInteger)y Z:(NSInteger)z Angle:(float)angle Parent:(CCNode *)parent CreateSel:(SEL)create
{
    // パラメータの内容をメンバに設定する
    self.absx = x;
    self.absy = y;
    self.angle = angle;
    
    // 配置フラグを立てる
    isStaged_ = YES;
    
    // 動作時間をクリアする
    time_ = 0;
    
    // 状態をクリアする
    state_ = 0;
    
    // 種別ごとの固有生成処理を実行する
    [self performSelector:create];
    
    // レイヤーに配置する
    [parent addChild:self.image z:z];
}

/*!
 @brief 雑魚生成
 
 雑魚のパラメータを設定する。
 */
- (void)createNoraml
{
    // 動作処理を設定する
    action_ = @selector(actionNoraml:);
    
    // 破壊処理を設定する
    destroy_ = @selector(destroyNormal);
    
    // 画像を読み込む
    self.image = [CCSprite spriteWithFile:@"Enemy1.png"];
    assert(image_ != nil);
    
    // 当たり判定サイズを設定する
    self.width = kAKEnemySize;
    self.height = kAKEnemySize;
    
    // 速度を設定する
    speed_ = kAKEnemySpeed;
    
    // HPを設定する
    hitPoint_ = 1;
    
    AKLog(0, @"angle=%f", AKCnvAngleRad2Deg(angle_));
}

/*!
 @brief 高速移動生成
 
 高速移動のパラメータを設定する。
 */
- (void)createHighSpeed
{
    // 動作処理を設定する
    action_ = @selector(actionNoraml:);
    
    // 破壊処理を設定する
    destroy_ = @selector(destroyNormal);
    
    // 画像を読み込む
    self.image = [CCSprite spriteWithFile:@"Enemy3.png"];
    assert(image_ != nil);
    
    // 当たり判定サイズを設定する
    self.width = kAKEnemySize;
    self.height = kAKEnemySize;
    
    // 速度を設定する
    speed_ = kAKEnemySpeed * 1.3;
    
    // HPを設定する
    hitPoint_ = 1;
}

/*!
 @brief 高速旋回生成
 
 高速旋回のパラメータを設定する。
 */
- (void)createHighTurn
{
    // 動作処理を設定する
    action_ = @selector(actionHighTurn:);
    
    // 破壊処理を設定する
    destroy_ = @selector(destroyNormal);
    
    // 画像を読み込む
    self.image = [CCSprite spriteWithFile:@"Enemy2.png"];
    assert(image_ != nil);
    
    // 当たり判定サイズを設定する
    self.width = kAKEnemySize;
    self.height = kAKEnemySize;
    
    // 速度を設定する
    speed_ = kAKEnemySpeed;
    
    // HPを設定する
    hitPoint_ = 1;    
}

/*!
 @brief 高速ショット生成
 
 高速ショットのパラメータを設定する。
 */
- (void)createHighShot
{
    // 動作処理を設定する
    action_ = @selector(actionHighShot:);
    
    // 破壊処理を設定する
    destroy_ = @selector(destroyNormal);
    
    // 画像を読み込む
    self.image = [CCSprite spriteWithFile:@"Enemy4.png"];
    assert(image_ != nil);
    
    // 当たり判定サイズを設定する
    self.width = kAKEnemySize;
    self.height = kAKEnemySize;
    
    // 速度を設定する
    speed_ = kAKEnemySpeed * 1.3;
    
    // HPを設定する
    hitPoint_ = 1;    
}

/*!
 @brief 3-Way弾発射生成
 
 3-Way弾を発射する敵のパラメータを設定する。
 */
- (void)create3WayShot
{
    // 動作処理を設定する
    action_ = @selector(action3WayShot:);
    
    // 破壊処理を設定する
    destroy_ = @selector(destroyNormal);
    
    // 画像を読み込む
    self.image = [CCSprite spriteWithFile:@"Enemy5.png"];
    assert(image_ != nil);
    
    // 当たり判定サイズを設定する
    self.width = kAKEnemySize;
    self.height = kAKEnemySize;
    
    // 速度を設定する
    speed_ = kAKEnemySpeed * 1.3;
    
    // HPを設定する
    hitPoint_ = 1;
}

/*!
 @brief 大砲生成処理
 
 大砲のパラメータを設定する。
 */
- (void)createCanon
{    
    // 動作処理を設定する
    action_ = @selector(actionCanon:);
    
    // 破壊処理を設定する
    destroy_ = @selector(destroyNormal);
    
    // 画像を読み込む
    self.image = [CCSprite spriteWithFile:@"Enemy6.png"];
    assert(image_ != nil);
    
    // 当たり判定サイズを設定する
    self.width = kAKEnemySize;
    self.height = kAKEnemySize;
    
    // 速度を設定する
    speed_ = kAKCanonSpeed;
    
    // HPを設定する
    hitPoint_ = 1;
}

/*!
 @brief 雑魚動作
 
 自機を追う。一定間隔で自機を狙う1-way弾発射。
 @param dt フレーム更新間隔
 */
- (void)actionNoraml:(ccTime)dt
{
    int rotdirect = 0;      // 回転方向
    
    // 回転方向を自機のある方に決定する
    rotdirect = AKCalcRotDirect(angle_, self.image.position.x, self.image.position.y,
                                AKPlayerPosX(), AKPlayerPosY());
    
    // 自機の方に向かって向きを回転する
    self.rotSpeed = rotdirect * kAKEnemyRotSpeed;
    AKLog(0, @"rotspeed=%f roddirect=%d", rotSpeed_, rotdirect);
    
    // 一定時間経過しているときは自機を狙う1-way弾を発射する
    if (time_ > kAKEnemyActionTime) {
        
        // 弾を発射する
        [self fireNormal];
        
        // 動作時間の初期化を行う
        time_ = 0.0f;
    }
    
    AKLog(0, @"pos=(%f, %f) angle=%f", self.image.position.x, self.image.position.y,
          AKCnvAngleRad2Deg(angle_));
}

/*!
 @brief 高速旋回動作処理
 
 自機を追う。一定間隔で自機を狙う1-way弾発射。
 @param dt フレーム更新間隔
 */
- (void)actionHighTurn:(ccTime)dt
{
    int rotdirect = 0;      // 回転方向
    
    // 回転方向を自機のある方に決定する
    rotdirect = AKCalcRotDirect(angle_, self.image.position.x, self.image.position.y,
                                AKPlayerPosX(), AKPlayerPosY());
    
    // 自機の方に向かって向きを回転する
    self.rotSpeed = rotdirect * kAKEnemyRotSpeed * 1.5;
    
    // 一定時間経過しているときは自機を狙う1-way弾を発射する
    if (time_ > kAKEnemyActionTime) {
        
        // 弾を発射する
        [self fireNormal];
        
        // 動作時間の初期化を行う
        time_ = 0.0f;
    }
}

/*!
 @brief 高速ショット処理
 
 自機を追う。通常よりも短い間隔で1-way弾を発射する。
 @param dt フレーム更新間隔
 */
- (void)actionHighShot:(ccTime)dt
{
    int rotdirect = 0;      // 回転方向
    
    // 回転方向を自機のある方に決定する
    rotdirect = AKCalcRotDirect(angle_, self.image.position.x, self.image.position.y,
                                AKPlayerPosX(), AKPlayerPosY());
    
    // 自機の方に向かって向きを回転する
    self.rotSpeed = rotdirect * kAKEnemyRotSpeed;
    
    // 一定時間経過しているときは自機を狙う1-way弾を発射する
    if (time_ > kAKEnemyActionTime / 5.0f) {
        
        // 弾を発射する
        [self fireNormal];
        
        // 動作時間の初期化を行う
        time_ = 0.0f;
    }
}

/*!
 @brief 3-Way弾発射処理
 
 自機を追う。一定間隔で3-way弾を発射する。
 @param dt フレーム更新間隔
 */
- (void)action3WayShot:(ccTime)dt
{
    int rotdirect = 0;      // 回転方向
    
    // 回転方向を自機のある方に決定する
    rotdirect = AKCalcRotDirect(angle_, self.image.position.x, self.image.position.y,
                                AKPlayerPosX(), AKPlayerPosY());
    
    // 自機の方に向かって向きを回転する
    self.rotSpeed = rotdirect * kAKEnemyRotSpeed * 1.3;
    
    // 一定時間経過しているときは自機を狙う3-way弾を発射する
    if (time_ > kAKEnemyActionTime / 2.0f) {
        
        // 弾を発射する
        [self fireNWay:3];
        
        // 動作時間の初期化を行う
        time_ = 0.0f;
    }
}

/*!
 @brief 大砲動作処理
 
 大砲の動作を行う。
 */
- (void)actionCanon:(ccTime)dt
{
    // 待機時間
    const float waitTime = 3.0f;
    // 弾発射間隔
    const float fireDelay = 0.5f;
    // 弾発射弾数
    const int fireCount = 5;
    
    // 状態が発射弾数に達していない場合は弾を発射する
    if (state_ < fireCount) {

        // 一定時間経過しているときは自機を狙う3-way弾を発射する
        if (time_ > fireDelay) {
            
            // 弾を発射する
            [self fireNWay:3];
            
            // 状態をひとつ進める
            state_++;

            // 動作時間の初期化を行う
            time_ = 0.0f;
        }
    }
    // 弾を発射したあとは向きを変える
    else {
        int rotdirect = 0;      // 回転方向
    
        // 回転方向を自機のある方に決定する
        rotdirect = AKCalcRotDirect(angle_, self.image.position.x, self.image.position.y,
                                    AKPlayerPosX(), AKPlayerPosY());
    
        // 自機の方に向かって向きを回転する
        self.rotSpeed = rotdirect * kAKCanonRotSpeed;
    
        // 待機時間経過している場合は状態をリセットする
        if (time_ > waitTime) {
            
            // 回転を停止する
            self.rotSpeed = 0.0f;
            
            // 状態をリセットする
            state_ = 0;
            
            // 動作時間の初期化を行う
            time_ = 0.0f;
        }
    }
}

/*!
 @brief 雑魚破壊処理
 
 破壊エフェクトを発生させる。
 */
- (void)destroyNormal
{
    // 画面効果を生成する
    [[AKGameScene getInstance] entryEffect:kAKExplosion
                                 startRect:kAKExplosionRect
                                frameCount:kAKExplosionFrameCount
                                     delay:kAKExplosionFrameDelay
                                      posX:self.absx posY:self.absy];
}

/*!
 @brief 通常弾の発射
 
 通常弾の発射を行う。
 */
- (void)fireNormal
{
    // 通常弾を生成する
    [[AKGameScene getInstance] fireEnemyShot:ENEMY_SHOT_TYPE_NORMAL
                                        PosX:self.absx PosY:self.absy Angle:self.angle];
}

/*!
 @brief n-Way弾発射
 
 n-Way弾の発射を行う。
 @param way 発射方向の数
 */
- (void)fireNWay:(NSInteger)way
{
    // 弾の間隔を決める
    float space = M_PI / 8.0f;
    
    // 発射角度を計算する
    NSArray *angleArray = AKCalcNWayAngle(way, self.angle, space);
    
    // 各弾を発射する
    for (NSNumber *angle in angleArray) {
        // 通常弾を生成する
        [[AKGameScene getInstance] fireEnemyShot:ENEMY_SHOT_TYPE_NORMAL
                                            PosX:self.absx PosY:self.absy Angle:[angle floatValue]];
    }
}
@end
