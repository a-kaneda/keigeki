//
//  AKEnemy+NoramlDevil.h
//  keigeki:傾撃
//
//  Created by 金田 明浩 on 2012/08/10.
//  Copyright 2012 KANEDA Akihiro. All rights reserved.
//

#import "AKEnemy.h"

// 雑魚の移動速度
#define ENEMY_NORMAL_SPEED 240
// 雑魚の回転速度
#define ENEMY_NORAML_ROTSPEED 0.5
// 雑魚の方向変更の時間
#define ENEMY_NORMAL_ACTIONTIME 5

/*!
 @class 雑魚クラス
 @abstruct 雑魚。自機に向かって移動、1-way弾を定期的に撃つ。
 */
@interface AKEnemy (Normal)
// 生成処理
- (void)createNoraml;
// 動作処理
- (void)actionNoraml:(ccTime)dt;
// 破壊処理
- (void)destroyNormal;
@end
