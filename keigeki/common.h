/*!
 @file common.h
 @brief 共通関数、共通定数定義
 
 アプリケーション全体で共通に使用する関数、定数の定義を行う。
 */

#ifndef keigeki_common_h
#define keigeki_common_h

#import <Foundation/Foundation.h>

/// スクリーン幅
#define SCREEN_WIDTH 480
/// スクリーン高さ
#define SCREEN_HEIGHT 320
// <注意> ループ時に背景が飛ばないようにステージサイズは背景のサイズの倍数とすること。
/// ステージ幅
#define STAGE_WIDTH SCREEN_WIDTH * 8
/// ステージ高さ
#define STAGE_HEIGHT SCREEN_HEIGHT * 8
/// 自機の表示位置(x座標)
#define PLAYER_POS_X    (SCREEN_WIDTH / 2)
/// 自機の表示位置(y座標)
#define PLAYER_POS_Y    (SCREEN_HEIGHT / 8)
/// ステージの個数
#define STAGE_COUNT 5
/// 同時に生成可能な敵の最大数
#define MAX_ENEMY_COUNT 16

/// ショットボタンのサイズ
#define SHOT_BUTTON_SIZE 64
/// ショットボタンの配置位置y座標
#define SHOT_BUTTON_POS_Y 50
/// ショットボタンの配置位置x座標
#define SHOT_BUTTON_POS_X (SCREEN_WIDTH - SHOT_BUTTON_POS_Y)

/// ポーズボタンのサイズ
#define PAUSE_BUTTON_SIZE 32
/// ポーズボタンの配置位置x座標
#define PAUSE_BUTTON_POS_X (SCREEN_WIDTH - PAUSE_BUTTON_SIZE / 2- 10)
/// ポーズボタンの配置位置y座標
#define PAUSE_BUTTON_POS_Y (SCREEN_HEIGHT - PAUSE_BUTTON_SIZE / 2- 10)

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
