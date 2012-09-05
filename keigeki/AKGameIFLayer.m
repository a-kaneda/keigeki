/*!
 @file AKGameIFLayer.m
 @brief ゲームプレイ画面インターフェース定義
 
 ゲームプレイ画面のインターフェースを管理するを定義する。
 */

#import "AKGameIFLayer.h"
#import "AKGameScene.h"
#import "common.h"

/// ショットボタンのサイズ
static const NSInteger kAKShotButtonSize = 64;
/// ポーズボタンのサイズ
static const NSInteger kAKPauseButtonSize = 32;

// 加速度センサーの値を比率換算する
static float AKAccel2Ratio(float accel);
// 中心座標とサイズから矩形を作成する
static CGRect AKMakeRectFromCenter(CGPoint center, NSInteger size);

/*!
 @brief ゲームプレイ画面インターフェースクラス
 
 ゲームプレイ画面のインターフェースを管理する。
 */
@implementation AKGameIFLayer

/*!
 @brief オブジェクト生成処理

 オブジェクトの生成を行う。
 @return 生成したオブジェクト。失敗時はnilを返す。
 */
- (id)init
{
    // メニュー項目の数
    const NSInteger kAKItemCount = 5;

    // スーパークラスの生成処理
    self = [super init];
    if (!self) {
        return nil;
    }
    
    // 加速度センサーを有効にする
    self.isAccelerometerEnabled = YES;
    
    // アイテム格納用配列を生成する
    self.menuItems = [NSMutableArray arrayWithCapacity:kAKItemCount];
    
    // ショットボタンを生成する
    [self.menuItems addObject:[AKMenuItem itemWithPos:AKMakeRectFromCenter(kAKShotButtonPos, kAKShotButtonSize)
                                               action:@selector(firePlayerShot)
                                                  tag:kAKGameStatePlaying]];
    
    // ポーズボタンを生成する
    [self.menuItems addObject:[AKMenuItem itemWithPos:AKMakeRectFromCenter(kAKPauseButtonPos, kAKPauseButtonSize)
                                               action:@selector(pause)
                                                  tag:kAKGameStatePlaying]];
    
    // クリア画面スキップ入力を生成する
    [self.menuItems addObject:[AKMenuItem itemWithPos:CGRectMake(0, 0, kAKScreenSize.width, kAKScreenSize.height)
                                               action:@selector(skipResult)
                                                  tag:kAKGameClear]];
    
    // ゲームオーバースキップ入力を生成する
    [self.menuItems addObject:[AKMenuItem itemWithPos:CGRectMake(0, 0, kAKScreenSize.width, kAKScreenSize.height)
                                               action:@selector(resetAll)
                                                  tag:kAKGameStateGameOver]];
    
    // ポーズ解除入力を生成する
    [self.menuItems addObject:[AKMenuItem itemWithPos:CGRectMake(0, 0, kAKScreenSize.width, kAKScreenSize.height)
                                               action:@selector(resume)
                                                  tag:kAKGameStatePause]];
    
    return self;
}

/*!
 @brief 加速度情報受信処理

 加速度センサーの情報を受信する。
 @param accelerometer 加速度センサー
 @param acceleration 加速度情報
 */
- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
    float ax = 0.0f;
    float ay = 0.0f;
    
    DBGLOG(0, @"x=%g,y=%g,z=%g",acceleration.x, acceleration.y, acceleration.z);
    
    // 加速度センサーの入力値を-1.0〜1.0の比率に変換
    // 画面を横向きに使用するのでx軸y軸を入れ替える
    // x軸は+-逆なので反転させる
    ax = AKAccel2Ratio(-acceleration.y);
    ay = AKAccel2Ratio(acceleration.x);
    
    DBGLOG(0, @"ax=%f,ay=%f", ax, ay);

    // 速度の変更
    [[AKGameScene sharedInstance] movePlayerByVX:ax VY:ay];
}
@end

/*!
 @brief 加速度センサーの値を比率換算する

 加速度センサーの入力値を最大から最小までの比率に換算する。
 @param accel 加速度センサーの入力値
 @return 比率
 */
static float AKAccel2Ratio(float accel)
{
    const float MIN_VAL = 0.05f;
    const float MAX_VAL = 0.3f;

    // 最小値未満
    if (accel < -MAX_VAL) {
        return -1.0f;
    }
    // 最大値超過
    else if (accel > MAX_VAL) {
        return 1.0f;
    }
    // 水平状態
    else if (accel > -MIN_VAL && accel < MIN_VAL) { 
        return 0.0f;
    }
    // 傾き負
    else if (accel < 0) {
        return (accel + MIN_VAL) / (MAX_VAL - MIN_VAL);
    }
    // 傾き正
    else {
        return (accel - MIN_VAL) / (MAX_VAL - MIN_VAL);
    }    
}

/*!
 @brief 中心座標とサイズから矩形を作成する
 
 中心座標とサイズから矩形を作成する。
 @param center 中心座標
 @param size サイズ
 
 */
static CGRect AKMakeRectFromCenter(CGPoint center, NSInteger size)
{
    return CGRectMake(center.x - size / 2, center.y - size / 2, size, size);
}
