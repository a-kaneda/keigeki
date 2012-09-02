/*!
 @file common.h
 @brief 共通関数、共通定数定義
 
 アプリケーション全体で共通に使用する関数、定数の定義を行う。
 */

#ifndef keigeki_common_h
#define keigeki_common_h

#import <Foundation/Foundation.h>

// スクリーンサイズ
extern const CGSize kAKScreenSize;
// ステージサイズ
extern const CGSize kAKStageSize;
// 自機の表示位置
extern const CGPoint kAKPlayerPos;
// 同時に生成可能な敵の最大数
extern const NSInteger kAKMaxEnemyCount;
// ショットボタンの配置位置
extern const CGPoint kAKShotButtonPos;
// ポーズボタンの配置位置
extern const CGPoint kAKPauseButtonPos;
// 背景塗りつぶし用の画像のファイル名
extern NSString *kAKBaseColorImage;

#ifdef DEBUG
/// デバッグログON/OFF用フラグ
extern unsigned int g_debugflg;

/*!
 @brief デバッグログ
 
 デバッグログ。出力条件の指定が可能。ログの先頭にメソッド名と行数を付加する。
 @param cond 出力条件
 @param fmt 出力フォーマット
 */
#define DBGLOG(cond, fmt, ...) if (cond) NSLog(@"%s(%d) " fmt, __FUNCTION__, __LINE__, ## __VA_ARGS__)

/*!
 @brief デバッグフラグの設定
 
 デバッグログON/OFF用フラグの指定したビットを立てる。
 @param flg フラグをONにするビット
 */
#define DBGFLGSET(flg) g_debugflg |= (flg)

/*!
 @brief デバッグフラグの解除
 
 デバッグログON/OFF用フラグの指定したビットを落とす。
 @param flg フラグをOFFにするビット
 */
#define DBGFLGUSET(flg) g_debugflg &= ((flg) ^ 0xFFFFFFFFUL)

/*!
 @brief デバッグフラグの取得
 
 デバッグログON/OFF用フラグの指定したビットが立っているか確認する。
 @param flg フラグを確認するビット
 */
#define DBGFLGGET(flg) (g_debugflg & (flg))
#else
/*!
 @brief デバッグログ
 
 デバッグログ。出力条件の指定が可能。ログの先頭にメソッド名と行数を付加する。
 @param cond 出力条件
 @param fmt 出力フォーマット
 */
#define DBGLOG(cond, fmt, ...)

/*!
 @brief デバッグフラグの設定
 
 デバッグログON/OFF用フラグの指定したビットを立てる。
 @param flg フラグをONにするビット
 */
#define DBGFLGSET(flg)

/*!
 @brief デバッグフラグの解除
 
 デバッグログON/OFF用フラグの指定したビットを落とす。
 @param flg フラグをOFFにするビット
 */
#define DBGFLGUSET(flg)

/*!
 @brief デバッグフラグの取得
 
 デバッグログON/OFF用フラグの指定したビットが立っているか確認する。
 @param flg フラグを確認するビット
 */
#define DBGFLGGET(flg) (0)
#endif

// 範囲チェック
float AKRangeCheckLF(float val, float min, float max);
float AKRangeCheckF(float val, float min, float max);

// 角度変換
float AKCnvAngleRad2Deg(float radAngle);
float AKCnvAngleRad2Scr(float radAngle);

// 2点間の角度計算
float AKCalcDestAngle(float srcx, float srcy, float dstx, float dsty);

// 回転方向の計算
int AKCalcRotDirect(float angle, float srcx, float srcy, float dstx, float dsty);

// n-way弾発射時の方向計算
NSArray* AKCalcNWayAngle(int count, float centerAngle, float space);

#endif
