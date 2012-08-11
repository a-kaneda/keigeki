//
//  GameStage.h
//  keigeki
//
//  Created by 金田 明浩 on 2012/08/09.
//  Copyright 2012 KANEDA Akihiro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CharacterPool.h"

/*!
 @class ステージ管理クラス
 @abstruct ステージの進行を管理するクラス。
 */
@interface GameStage : NSObject {
    // ステージの番号
    NSInteger m_stageNum;
    // 経過時間
    float m_time;
    // 敵キャラクター
    CharacterPool *m_enemyPool;
}

@property (nonatomic, retain)CharacterPool *enemyPool;

// オブジェクト生成処理
- (id)initWithEnemyPool:(CharacterPool *)enemyPool;
// ステージ進行処理
- (void)update:(float)dt;
// ステージ開始処理
- (void)startStage:(NSInteger)stageNum;

@end
