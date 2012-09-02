/*!
 @file common.m
 @brief 共通関数、共通定数定義
 
 アプリケーション全体で共通に使用する関数、定数の定義を行う。
 */

#import <stdio.h>
#import <math.h>
#import "common.h"

#ifdef DEBUG
/// デバッグログON/OFF用フラグ
unsigned int g_debugflg = 0;
#endif

/// スクリーンサイズ
const CGSize kAKScreenSize = {480, 320};
// <注意> ループ時に背景が飛ばないようにステージサイズは背景のサイズの倍数とすること。
/// ステージサイズ(スクリーンサイズ * 8)
const CGSize kAKStageSize = {3840, 2560};
/// 自機の表示位置(画面中央、画面下から1/4)
const CGPoint kAKPlayerPos = {240, 80};
/// 同時に生成可能な敵の最大数
const NSInteger kAKMaxEnemyCount = 16;
/// ショットボタンの配置位置(画面右下から50)
const CGPoint kAKShotButtonPos = {430, 50};
/// ポーズボタンの配置位置(画面右上から26)
const CGPoint kAKPauseButtonPos = {454, 294};
// 背景塗りつぶし用の画像のファイル名
NSString *kAKBaseColorImage = @"BaseColor.png";

/*!
 @brief 範囲チェック(実数)

 値が範囲内にあるかチェックし、範囲外にあれば範囲内の値に補正する。
 @param val 値
 @param min 最小値
 @param max 最大値
 @return 補正結果
 */
float AKRangeCheckF(float val, float min, float max)
{
    // 最小値未満
    if (val < min) {
        return min;
    }
    // 最大値超過
    else if (val > max) {
        return max;
    }
    // 範囲内
    else {
        return val;
    }
}

/*!
 @brief 範囲チェック(ループ、 実数)

 値が範囲内にあるかチェックし、範囲外にあれば反対側にループする。
 @param val 値
 @param min 最小値
 @param max 最大値
 @return 補正結果
 */
float AKRangeCheckLF(float val, float min, float max)
{
    // 最小値未満
    if (val < min) {
        return AKRangeCheckLF(val + (max - min), min, max);
    }
    // 最大値超過
    else if (val > max) {
        return AKRangeCheckLF(val - (max - min), min, max);
    }
    // 範囲内
    else {
        return val;
    }
}

/*!
 @brief rad角度からdeg角度への変換

 fadianからdegreeへ変換する。
 @param radAngle rad角度
 @return deg角度
 */
float AKCnvAngleRad2Deg(float radAngle)
{
    // radianからdegreeへ変換する
    return radAngle / (2 * M_PI) * 360;
}

/*!
 @brief rad角度からスクリーン角度への変換

 radianからdegreeへ変換し、上向きを0°とする。時計回りを正とする。
 @param radAngle rad角度
 @return スクリーン角度
 */
float AKCnvAngleRad2Scr(float radAngle)
{
    float srcAngle = 0.0f;
    
    // radianからdegreeへ変換する
    srcAngle = AKCnvAngleRad2Deg(radAngle);
    
    // 上向きを0°とするため、90°ずらす。
    srcAngle -= 90;
    
    // 時計回りを正とするため符号を反転する。
    srcAngle *= -1;
    
    return srcAngle;
}

/*!
 @brief 2点間の角度計算

 2点間を線で結んだときの角度を計算する。
 @param srcx 出発点x座標
 @param srcy 出発点y座標
 @param dstx 到達点x座標
 @param dsty 到達点y座標
 @return 2点間の角度
 */
float AKCalcDestAngle(float srcx, float srcy, float dstx, float dsty)
{
    float vx = 0.0f;        // x方向のベクトルの大きさ
    float vy = 0.0f;        // y方向のベクトルの大きさ
    float angle = 0.0f;     // 2点間の角度
    
    // 角度を計算する
    vx = dstx - srcx;
    vy = dsty - srcy;
    angle = atan(vy / vx);

    // 第2象限、第3象限の場合はπ進める
    if (vx < 0.0f) {
        angle += M_PI;
    }

    DBGLOG(0, @"angle=%f vy=%f vx=%f vy/vx=%f", AKCnvAngleRad2Deg(angle), vy, vx, vy / vx);
    
    return angle;
}

/*!
 @brief 回転方向の計算

 現在の角度から見て、到達点が時計回りの側にあるか反時計回りの側にあるかを計算する。
 @param angle 現在の角度
 @param srcx 出発点x座標
 @param srcy 出発点y座標
 @param dstx 到達点x座標
 @param dsty 到達点y座標
 @return 1:反時計回り、-1:時計回り、0:直進
 */
int AKCalcRotDirect(float angle, float srcx, float srcy, float dstx, float dsty)
{
    int rotdirect = 0;      // 回転方向(1:反時計回り、-1:時計回り、0:直進)
    float destangle = 0.0f; // 目的角度
    float destsin = 0.0f;   // sin(目的角度 - 現在の角度)
    float destcos = 0.0f;   // cos(目的角度 - 現在の角度)
    
    DBGLOG(0, @"angle=%f src=(%f, %f) dst=(%f, %f)", AKCnvAngleRad2Deg(angle), srcx, srcy, dstx, dsty);
 
    // 角度を計算する
    destangle = AKCalcDestAngle(srcx, srcy, dstx, dsty);
        
    // 現在の角度から見て入力角度が時計回りの側か反時計回りの側か調べる
    // sin(目的角度 - 現在の角度) > 0の場合は反時計回り
    // sin(目的角度 - 現在の角度) < 0の場合は時計回り
    destsin = sin(destangle - angle);
    
    // 回転方向を設定する
    if (destsin > 0.0f) {
        rotdirect = 1;
    }
    else if (destsin < 0.0f) {
        rotdirect = -1;
    }
    else {
        // 上記判定でこのelseに入るのは入力角度が同じ向きか反対向きのときだけ
        // 同じ向きか反対向きか調べる
        // cos(入力角度 - 現在角度) < 0の場合は反対向き
        // 反対向きの場合は反時計回りとする
        destcos = cos(destangle - angle);
        if (destcos < 0.0f) {
            rotdirect = 1;
        }
        else {
            rotdirect = 0;
        }
    }
    
    return rotdirect;
}

/*!
 @brief n-way弾発射時の方向計算
 
 n-way弾を発射するときの角度を計算する。
 @param count 弾の数
 @param centerAngle n-way弾の中心の角度
 @param space 2点間の間隔
 @return n-way弾の角度配列(autorelease済)
 */
NSArray* AKCalcNWayAngle(int count, float centerAngle, float space)
{
    int i = 0;                          // ループ変数
    float angle = 0.0f;                 // 弾を発射する角度
    float minAngle = 0.0f;              // n-way弾の最小の角度
    NSNumber *angleObj = nil;           // 角度をNSArrayに格納するためのオブジェクト
    NSMutableArray *angleArray = nil;   // n-way弾の角度配列
    
    // 角度格納用配列を生成する
    angleArray = [NSMutableArray arrayWithCapacity:count];
    
    // 最小値の角度を計算する
    minAngle = centerAngle - (space * (count - 1)) / 2.0f;
    
    // 各弾の発射角度を計算する
    for (i = 0; i < count; i++) {
        
        // 弾の角度を計算する
        angle = minAngle + i * space;
        
        // NSArrayに格納するためにオブジェクトを作成する
        angleObj = [NSNumber numberWithFloat:angle];
        
        // 戻り値の配列に追加する
        [angleArray addObject:angleObj];
    }
    
    // 計算した角度の配列を返す
    return angleArray;
}