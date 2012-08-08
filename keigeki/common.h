//
//  common.h
//  keigeki
//
//  Created by 金田 明浩 on 12/05/26.
//  Copyright (c) 2012 KANEDA Akihiro. All rights reserved.
//

#ifndef keigeki_common_h
#define keigeki_common_h

#import <Foundation/Foundation.h>

// スクリーン幅
#define SCREEN_WIDTH 480
// スクリーン高さ
#define SCREEN_HEIGHT 320
// <注意> ループ時に背景が飛ばないようにステージサイズは背景のサイズの倍数とすること。
// ステージ幅
#define STAGE_WIDTH SCREEN_WIDTH * 4
// ステージ高さ
#define STAGE_HEIGHT SCREEN_HEIGHT * 4
// 自機の表示位置(x座標)
#define PLAYER_POS_X    (SCREEN_WIDTH / 2)
// 自機の表示位置(y座標)
#define PLAYER_POS_Y    (SCREEN_HEIGHT / 2)

#ifdef DEBUG
// デバッグログ。出力条件の指定が可能。ログの先頭にメソッド名と行数を付加する。
#define DBGLOG(cond, fmt, ...) if (cond) NSLog(@"[%s][%d] " fmt, __FUNCTION__, __LINE__, ## __VA_ARGS__)
#else
#define DBGLOG(cond, fmt, ...) 
#endif

// 範囲チェック
float RangeCheckLF(float val, float min, float max);
float RangeCheckF(float val, float min, float max);

// 角度変換
float CnvAngleRad2Scr(float radAngle);

#endif
