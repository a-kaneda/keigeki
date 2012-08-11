//
//  GameStage.m
//  keigeki
//
//  Created by 金田 明浩 on 2012/08/09.
//  Copyright 2012 KANEDA Akihiro. All rights reserved.
//

#import "GameStage.h"
#import "common.h"

// 敵出現パターン定義構造体
struct STAGE_PATTERN {
    float interval;                     // 敵出現の間隔
    int probability[ENEMY_TYPE_COUNT];  // 敵の種別ごとの出現確率
};

// 敵出現パターン定義
static const struct STAGE_PATTERN g_stagePtn[STAGE_COUNT] = {
    {10.0f, 1, 0, 0},
    {10.0f, 1, 0, 0},
    {10.0f, 1, 0, 0},
    {10.0f, 1, 0, 0},
    {10.0f, 1, 0, 0}
};

@implementation GameStage

@synthesize enemyPool = m_enemyPool;

/*!
 @method オブジェクト生成処理
 @abstruct オブジェクトの生成を行う。
 @param enemyPool 敵キャラクター管理プール
 @return 生成したオブジェクト。失敗時はnilを返す。
 */
- (id)initWithEnemyPool:(CharacterPool *)enemyPool
{
    // スーパークラスの生成処理
    self = [super init];
    if (!self) {
        return nil;
    }
    
    // メンバ変数の初期化
    self.enemyPool = enemyPool;
    m_stageNum = 0;
    m_time = 0.0f;
        
    return self;
}

/*!
 @method ステージ進行処理
 @abstruct ステージの進行。敵キャラクターの生成を行う。
 @param dt フレーム更新間隔
 */
- (void)update:(float)dt
{
    // ステージ番号によって処理を分岐する
    switch (m_stageNum) {
        case 1:
            break;
            
        default:
            break;
    }
}

/*!
 @method ステージ開始処理
 @abstruct 指定したステージを開始する。
 */
- (void)startStage:(NSInteger)stageNum
{
    // 経過時間を初期化する
    m_time = 0.0f;
    
    // ステージ番号を設定する
    m_stageNum = stageNum;
}

@end
