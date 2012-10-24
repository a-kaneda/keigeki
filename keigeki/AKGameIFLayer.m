/*!
 @file AKGameIFLayer.m
 @brief ゲームプレイ画面インターフェース定義
 
 ゲームプレイ画面のインターフェースを管理するを定義する。
 */

#import "AKGameIFLayer.h"
#import "AKGameScene.h"
#import "AKCommon.h"

/// ショットボタンのサイズ
static const NSInteger kAKShotButtonSize = 64;
/// ポーズボタンのサイズ
static const NSInteger kAKPauseButtonSize = 32;

// 加速度センサーの値を比率換算する
static float AKAccel2Ratio(float accel);

/*!
 @brief ゲームプレイ画面インターフェースクラス
 
 ゲームプレイ画面のインターフェースを管理する。
 */
@implementation AKGameIFLayer

/*!
 @brief 項目数を指定した初期化処理
 
 メニュー項目数を指定した初期化処理。
 @return 初期化したオブジェクト。失敗時はnilを返す。
 */
- (id)initWithCapacity:(NSInteger)capacity
{
    // スーパークラスの初期化処理を実行する
    self = [super initWithCapacity:capacity];
    if (!self) {
        return nil;
    }
    
    // 加速度センサーを有効にする
    self.isAccelerometerEnabled = YES;
    
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
    
    AKLog(0, @"x=%g,y=%g,z=%g",acceleration.x, acceleration.y, acceleration.z);
    
    // 加速度センサーの入力値を-1.0〜1.0の比率に変換
    // 画面を横向きに使用するのでx軸y軸を入れ替える
    // x軸は+-逆なので反転させる
    ax = AKAccel2Ratio(-acceleration.y);
    ay = AKAccel2Ratio(acceleration.x);
    
    AKLog(0, @"ax=%f,ay=%f", ax, ay);

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
