/*!
 @file AKResultLayer.h
 @brief ステージクリア結果レイヤー
 
 ステージクリア結果画面のレイヤーを定義する。
 */

#import <Foundation/Foundation.h>
#import "cocos2d.h"

/// ステージクリア結果画面の状態
enum AKResultState {
    kAKstateScoreView = 0,    ///< 初期スコア表示中
    kAKstateTimeView,         ///< タイム表示中
    kAKstateHitView,          ///< 命中率表示中
    kAKstateRestView,         ///< 残機表示中
    kAKstateTimeBonus,        ///< タイムボーナス計算中
    kAKstateHitBonus,         ///< 命中率ボーナス計算中
    kAKstateRestBonus,        ///< 残機ボーナス計算中
    kAKstateFinish            ///< 計算完了
};

// ステージクリア結果レイヤー
@interface AKResultLayer : CCNode {
    /// 計算状態
    enum AKResultState m_state;
    /// クリア時の残機
    NSInteger m_rest;
    /// クリアタイム
    NSInteger m_time;
    /// 命中率
    NSInteger m_hit;
    /// 表示中のスコア
    NSInteger m_score;
    /// 表示中の残機ボーナス
    NSInteger m_restBonus;
    /// 表示中のタイムボーナス
    NSInteger m_timeBonus;
    /// 表示中の命中率ボーナス
    NSInteger m_hitBonus;
    /// 残機ボーナスの計算値
    NSInteger m_restBonusTarget;
    /// タイムボーナスの計算値
    NSInteger m_timeBonusTarget;
    /// 命中率ボーナスの計算値
    NSInteger m_hitBonusTarget;
    /// 表示更新待ち時間
    float m_delay;
}

/// 表示が完了しているかどうか
@property (nonatomic, readonly)BOOL isFinish;

// パラメータの設定
- (void)setScore:(NSInteger)score andTime:(NSInteger)time andHit:(NSInteger)hit
         andRest:(NSInteger)rest;
// タグ指定ラベル生成
- (void)createLabelWithTag:(NSInteger)tag pos:(CGPoint)pos;
// 文字列指定ラベル生成
- (void)createLabelWithString:(NSString *)str pos:(CGPoint)pos;
// 表示アイテムの更新
- (NSInteger)updateItemWithTag:(NSInteger)tag
                  currentValue:(NSInteger)current
                   targetValue:(NSInteger)target
                incrementValue:(NSInteger)increment
                    isAddScore:(BOOL)isAddScore
                    isLongWait:(BOOL)isLongWait
                        withSE:(BOOL)withSE;
// 計算更新処理
- (void)updateCalc:(ccTime)dt;
// 計算の強制終了
- (void)finish;
@end
