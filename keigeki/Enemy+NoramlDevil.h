//
//  Enemy+NoramlDevil.h
//  keigeki
//
//  Created by 金田 明浩 on 2012/08/10.
//  Copyright 2012 KANEDA Akihiro. All rights reserved.
//

#import "Enemy.h"

// 雑魚悪魔の移動速度
#define NORMALDEVIL_SPEED 120
// 雑魚悪魔の方向変更の時間
#define NORMALDEVIL_ACTIONTIME 5

/*!
 @class 雑魚悪魔クラス
 @abstruct 雑魚悪魔。移動するだけ。一撃で死ぬ。
 */
@interface Enemy (NormalDevil)
// 生成処理
- (void)createNoramlDevil;
// 動作処理
- (void)actionNoramlDevil:(ccTime)dt;
// 破壊処理
- (void)destroyNormalDevil;
@end
