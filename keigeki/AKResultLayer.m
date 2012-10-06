/*!
 @file AKResultLayer.m
 @brief ステージクリア結果レイヤー
 
 ステージクリア結果画面のレイヤーを定義する。
 */

#import "AKResultLayer.h"
#import "SimpleAudioEngine.h"
#import "AKGameScene.h"
#import "AKLabel.h"
#import "AKScreenSize.h"
#import "common.h"

/// ラベルのタグ
enum {
    kAKTimeNumTag = 0,    ///< タイムラベルのタグ
    kAKTimeBonusTag,      ///< タイムボーナスラベルのタグ
    kAKHitNumTag,         ///< 命中率ラベルのタグ
    kAKHitBonusTag,       ///< 命中率ボーナスラベルのタブ
    kAKRestNumTag,        ///< 残機ラベルのタグ
    kAKRestBonusTag,      ///< 残機ボーナスラベルのタグ
    kAKScoreNumTag        ///< スコアラベルのタグ
};

/// 待ち時間(タイムボーナス、命中率ボーナス計算時)
static const float kAKDealyShort = 0.05f;
/// 待ち時間(その他)
static const float kAKDelayLong = 0.5f;

/// キャプション位置x座標
#define kAKCaptionPosX 60
/// 値位置x座標
#define kAKValuePosX (kAKCaptionPosX + 96)
/// ボーナス位置x座標
#define kAKBonusPosX (kAKValuePosX + 144)
/// タイム位置y座標
#define kAKTimePosY 180
/// 命中率位置y座標
#define kAKHitPosY (kAKTimePosY - 20)
/// 残機位置y座標
#define kAKRestPosY (kAKHitPosY - 20)
/// スコア位置y座標
#define kAKScorePosY (kAKRestPosY - 20)

/// タイトルキャプション位置、横方向中心からの位置
static const float kAKTitleCaptionPosHorizontalCenterPoint = -88.0f;
/// タイトルキャプション位置、上からの位置
static const float kAKTitleCaptionPosTopPoint = 80.0f;
/// キャプション位置、横方向中心からの位置
static const float kAKCaptionPosHorizontalCenterPoint = -184.0f;
/// 値位置、横方向中心からの位置
static const float kAKValuePosHorizontalCenterPoint = -88.0f;
/// ボーナス位置、横方向中心からの位置
static const float kAKBonusPosHorizontalCenterPoint = 56.0f;
/// キャプション位置、上からの位置
static const float kAKCaptionPosTopPoint = 140.0f;
/// キャプション縦方向位置のマージン
static const float kAKCaptionPosMargin = 20.0f;

/// ステージクリアのタイトルキャプション
static NSString *kAKTitleCaption = @"STAGE CLEAR";
/// タイムのキャプション
static NSString *kAKTimeCaption = @" TIME:";
/// 命中率のキャプション
static NSString *kAKHitCaption = @"  HIT:";
/// 残機のキャプション
static NSString *kAKRestCaption = @" REST:";
/// スコアのキャプション
static NSString *kAKScoreCaption = @"SCORE:";
/// ラベルのフォーマット
static NSString *kAKLabelFormat = @"%8d";

/// 少しずつ表示更新するときの増加分
static const NSInteger kAKIncrementValue = 100;
/// 残機ボーナスの増加分
static const NSInteger kAKRestIncrementValue = 1000;
/// タイムボーナスの基準となる時間
static const NSInteger kAKBaseTime = 300;
/// 1秒あたりのタイムボーナス
static const NSInteger kAKTimeBonus = 50;
/// 1%あたりの命中率ボーナス
static const NSInteger kAKHitBonus = 50;
/// タイムの最大値
static const NSInteger kAKTimeMax = 9999;

/// スコアカウントのSE
static NSString *kAKScoreCountSE = @"ScoreCount.caf";

/*!
 @brief ステージクリア結果レイヤー
 
 ステージクリア結果画面を表示する。
 */
@implementation AKResultLayer

/*!
 @brief オブジェクト生成処理
 
 オブジェクトの生成を行う。
 @return 生成したオブジェクト。失敗時はnilを返す。
 */
- (id)init
{
    // スーパークラスの生成処理を実行する
    self = [super init];
    if (!self) {
        return nil;
    }
    
    // 広告枠を配置する
//    CCSprite *adSpace = [CCSprite spriteWithFile:kAKAdSpaceImage];
//    adSpace.anchorPoint = ccp(0.0f, 1.0f);
//    adSpace.position = ccp([AKScreenSize positionFromLeftPoint:0],
//                           [AKScreenSize positionFromTopPoint:0]);
//    [self addChild:adSpace z:999];
    
    // 背景色レイヤーを配置する
    [self addChild:AKCreateBackColorLayer() z:0];
    
    // メンバの初期化
    m_state = kAKstateScoreView;
    m_score = 0;
    m_rest = 0;
    m_time = 0;
    m_hit = 0;
    m_restBonus = 0;
    m_timeBonus = 0;
    m_hitBonus = 0;
    m_delay = kAKDelayLong;
    
    // タイトルキャプションラベルを生成する
    [self createLabelWithString:kAKTitleCaption
                            pos:ccp([AKScreenSize positionFromHorizontalCenterPoint:kAKTitleCaptionPosHorizontalCenterPoint],
                                    [AKScreenSize positionFromTopPoint:kAKTitleCaptionPosTopPoint])];
    
    // キャプション位置縦方向は一番上の項目からマージンを等間隔であけて配置する
    float position = [AKScreenSize positionFromTopPoint:kAKCaptionPosTopPoint];
    
    // タイムキャプションラベルを生成する
    [self createLabelWithString:kAKTimeCaption
                            pos:ccp([AKScreenSize positionFromHorizontalCenterPoint:kAKCaptionPosHorizontalCenterPoint],
                                    position)];
    
    
    // タイムラベルを生成する
    [self createLabelWithTag:kAKTimeNumTag
                         pos:ccp([AKScreenSize positionFromHorizontalCenterPoint:kAKValuePosHorizontalCenterPoint],
                                 position)];
    
    // タイムボーナスラベルを生成する
    [self createLabelWithTag:kAKTimeBonusTag
                         pos:ccp([AKScreenSize positionFromHorizontalCenterPoint:kAKBonusPosHorizontalCenterPoint],
                                 position)];
    
    // 縦方向の位置を下へずらす
    position -= kAKCaptionPosMargin;
    
    // 命中率キャプションラベルを生成する
    [self createLabelWithString:kAKHitCaption
                            pos:ccp([AKScreenSize positionFromHorizontalCenterPoint:kAKCaptionPosHorizontalCenterPoint],
                                    position)];
    
    // 命中率ラベルを生成する
    [self createLabelWithTag:kAKHitNumTag
                         pos:ccp([AKScreenSize positionFromHorizontalCenterPoint:kAKValuePosHorizontalCenterPoint],
                                 position)];
    
    // 命中率ボーナスラベルを生成する
    [self createLabelWithTag:kAKHitBonusTag
                         pos:ccp([AKScreenSize positionFromHorizontalCenterPoint:kAKBonusPosHorizontalCenterPoint],
                                 position)];
    
    // 縦方向の位置を下へずらす
    position -= kAKCaptionPosMargin;

    // 残機キャプションラベルを生成する
    [self createLabelWithString:kAKRestCaption
                            pos:ccp([AKScreenSize positionFromHorizontalCenterPoint:kAKCaptionPosHorizontalCenterPoint],
                                    position)];
    
    // 残機ラベルを生成する
    [self createLabelWithTag:kAKRestNumTag
                         pos:ccp([AKScreenSize positionFromHorizontalCenterPoint:kAKValuePosHorizontalCenterPoint],
                                 position)];
    
    // 残機ボーナスラベルを生成する
    [self createLabelWithTag:kAKRestBonusTag
                         pos:ccp([AKScreenSize positionFromHorizontalCenterPoint:kAKBonusPosHorizontalCenterPoint],
                                 position)];
    
    // 縦方向の位置を下へずらす
    position -= kAKCaptionPosMargin;

    // スコアキャプションラベルを生成する
    [self createLabelWithString:kAKScoreCaption
                            pos:ccp([AKScreenSize positionFromHorizontalCenterPoint:kAKCaptionPosHorizontalCenterPoint],
                                    position)];
    // スコアラベルを生成する
    [self createLabelWithTag:kAKScoreNumTag
                         pos:ccp([AKScreenSize positionFromHorizontalCenterPoint:kAKBonusPosHorizontalCenterPoint],
                                 position)];
    
    return self;
}

/*!
 @brief 計算が完了しているかどうか
 
 計算が完了しているかどうかを取得する。
 @return 計算が完了しているかどうか
 */
- (BOOL)isFinish
{
    if (m_state == kAKstateFinish) {
        return YES;
    }
    else {
        return NO;
    }
}

/*!
 @brief インスタンス解放時処理
 
 インスタンス解放時にオブジェクトを解放する。
 */
- (void)dealloc
{
    // 配置されているオブジェクトを開放する
    [self removeAllChildrenWithCleanup:YES];
    
    // スーパークラスの開放処理を実行する
    [super dealloc];
}

/*!
 @brief パラメータの設定
 
 スコア計算に必要なパラメータを設定する。
 @param score 現在のスコア
 @param time ステージクリアにかかった時間
 @param hit 命中率
 @param rest 残機
 */
- (void)setScore:(NSInteger)score andTime:(NSInteger)time andHit:(NSInteger)hit
         andRest:(NSInteger)rest
{
    // メンバに設定する
    m_score = score;
    m_time = time;
    m_hit = hit;
    m_rest = rest;
    
    // タイムが最大値を超えている場合は最大値に補正する
    if (m_time > kAKTimeMax) {
        m_time = kAKTimeMax;
    }
    
    // タイムボーナスを計算する
    m_timeBonusTarget = (kAKBaseTime - m_time) * kAKTimeBonus;
    if (m_timeBonusTarget < 0) {
        m_timeBonusTarget = 0;
    }
    
    // 命中率ボーナスを計算する
    m_hitBonusTarget = m_hit * kAKHitBonus;
    
    // 残機ボーナスを計算する
    m_restBonusTarget = m_rest * kAKRestIncrementValue;
}

/*!
 @brief タグ指定ラベル生成
 
 ラベルを生成し、タグを設定し、レイヤーに配置する。
 数字ラベル表示用。
 @param tag ラベルに設定するタグ
 @param pos ラベルの座標
 */
- (void)createLabelWithTag:(NSInteger)tag pos:(CGPoint)pos
{
    // 各ラベルの初期文字列を作成する
    NSString *initString = [NSString stringWithFormat:kAKLabelFormat, 0];
    
    // ラベルを生成する
    AKLabel *label = [AKLabel labelWithString:initString maxLength:initString.length maxLine:1 hasFrame:NO];
    
    // タグを設定する
    label.tag = tag;
    
    // 位置を設定する
    label.position = pos;
    
    // レイヤーに配置する
    [self addChild:label];
}

/*!
 @brief 文字列指定ラベル生成
 
 ラベルを生成し、文字列を設定し、レイヤーに配置する。
 固定文字列表示用。
 @param str ラベルに設定する文字列
 @param pos ラベルの座標
 */
- (void)createLabelWithString:(NSString *)str pos:(CGPoint)pos
{
    // ラベルを生成する
    AKLabel *label = [AKLabel labelWithString:str maxLength:str.length maxLine:1 hasFrame:NO];
    
    // 位置を設定する
    label.position = pos;
    
    // レイヤーに配置する
    [self addChild:label];
}

/*!
 @brief 表示アイテムの更新
 
 表示しているアイテムの値を更新する。
 @param tag ラベルのタグ
 @param current 現在の値
 @param target 目標値
 @param increment 値の増加量
 @param isAddScore スコアに加算するかどうか
 @param isLongWait 待ち時間を長めにするかどうか
 @param withSE 効果音を鳴らすかどうか
 @return 更新後の値
 */
- (NSInteger)updateItemWithTag:(NSInteger)tag
                  currentValue:(NSInteger)current
                   targetValue:(NSInteger)target
                incrementValue:(NSInteger)increment
                    isAddScore:(BOOL)isAddScore
                    isLongWait:(BOOL)isLongWait
                        withSE:(BOOL)withSE
{

    // 設定する値を決める
    NSInteger value = 0;
    // 増加量が設定されている場合は増加量分増やす
    if (increment > 0) {
        value = current + increment;
        
        // 目標値を超えた場合は目標値を設定する
        if (value > target) {
            value = target;
        }
    }
    // 増加量が設定されていない場合はそのまま設定する
    else {
        value = target;
    }
    
    // 文字列を生成する
    NSString *string = [NSString stringWithFormat:kAKLabelFormat, value];
    
    // ラベルを取得する
    AKLabel *label = (AKLabel *)[self getChildByTag:tag];
    
    // ラベルの表示を更新する
    [label setString:string];
    
    // スコアカウントの効果音を鳴らす
    if (withSE) {
        [[SimpleAudioEngine sharedEngine] playEffect:kAKScoreCountSE];
    }
    
    // スコアに加算する項目の場合は加算処理を行う
    if (isAddScore) {
        
        // ゲームシーンクラスのスコアを加算する
        [[AKGameScene sharedInstance] addScore:value - current];
        
        // ステージクリア結果画面のスコアを加算する
        m_score += (value - current);
        
        // スコア文字列を生成する
        NSString *scoreString = [NSString stringWithFormat:kAKLabelFormat, m_score];
        
        // スコアラベルを取得する
        AKLabel *scoreLabel = (AKLabel *)[self getChildByTag:kAKScoreNumTag];
        
        // スコアラベルの表示を更新する
        [scoreLabel setString:scoreString];
    }
    
    // 更新が完了したか判定する
    if (value >= target) {
        
        // 更新が完了していれば待ち時間は長めに設定する
        m_delay = kAKDelayLong;
        
        // 状態をひとつ進める
        m_state++;
    }
    else {
        // まだ増加中の時は待ち時間は短めの時間を設定する。
        // ただし、引数で長めの待ち時間を設定するようになっている場合は長めの時間とする
        if (isLongWait) {
            m_delay = kAKDelayLong;
        }
        else {
            m_delay = kAKDealyShort;
        }
    }
    
    return value;
}
/*!
 @brief 計算更新処理
 
 ステージクリアボーナスを計算し、スコアに加算する。
 @param dt フレーム更新間隔
 */
- (void)updateCalc:(ccTime)dt
{    
    // 表示更新待ち時間をカウントする
    m_delay -= dt;
    
    // 待ち時間が経過しているときは表示を更新する
    if (m_delay < 0.0f) {
        
        // 現在の状態によって更新対象を変える
        switch (m_state) {
            case kAKstateScoreView:   // 初期スコア表示中
                
                // スコアを更新する
                [self updateItemWithTag:kAKScoreNumTag currentValue:0 targetValue:m_score
                         incrementValue:-1 isAddScore:NO isLongWait:NO withSE:YES];
                break;
                
            case kAKstateTimeView:    // タイム表示中
                
                // タイムラベルを更新する
                [self updateItemWithTag:kAKTimeNumTag currentValue:0 targetValue:m_time
                         incrementValue:-1 isAddScore:NO isLongWait:NO withSE:YES];
                break;
                
            case kAKstateHitView:     // 命中率表示中
                
                // 命中率ラベルを更新する
                [self updateItemWithTag:kAKHitNumTag currentValue:0 targetValue:m_hit
                         incrementValue:-1 isAddScore:NO isLongWait:NO withSE:YES];
                break;
                
            case kAKstateRestView:    // 残機表示中
                
                // 残機ラベルを更新する
                [self updateItemWithTag:kAKRestNumTag currentValue:0 targetValue:m_rest
                         incrementValue:-1 isAddScore:NO isLongWait:NO withSE:YES];
                break;
                
            case kAKstateTimeBonus:   // タイムボーナス表示中
                
                // タイムボーナスを更新する
                m_timeBonus = [self updateItemWithTag:kAKTimeBonusTag currentValue:m_timeBonus
                                          targetValue:m_timeBonusTarget
                                       incrementValue:kAKIncrementValue
                                           isAddScore:YES isLongWait:NO withSE:YES];
                break;
                
            case kAKstateHitBonus:    // 命中率ボーナス表示中
                
                // 命中率ボーナスを更新する
                m_hitBonus = [self updateItemWithTag:kAKHitBonusTag currentValue:m_hitBonus
                                         targetValue:m_hitBonusTarget
                                      incrementValue:kAKIncrementValue
                                          isAddScore:YES isLongWait:NO withSE:YES];
                break;
                
            case kAKstateRestBonus:   // 残機ボーナス表示中
                
                // 残機ボーナスを更新する
                m_restBonus = [self updateItemWithTag:kAKRestBonusTag currentValue:m_restBonus
                                          targetValue:m_restBonusTarget
                                       incrementValue:kAKRestIncrementValue
                                           isAddScore:YES isLongWait:YES withSE:YES];
                
            case kAKstateFinish:      // 表示完了
                
                // [TODO] Touch Screenのメッセージを表示する
                break;
                
            default:
                break;
        }
    }
}

/*!
 @brief 計算の強制終了
 
 すべてのスコアの更新処理を終了させる。
 */
- (void)finish
{
    // すべての項目を更新させる
    [self updateItemWithTag:kAKScoreNumTag currentValue:0 targetValue:m_score
             incrementValue:-1 isAddScore:NO isLongWait:NO withSE:NO];
    [self updateItemWithTag:kAKTimeNumTag currentValue:0 targetValue:m_time
             incrementValue:-1 isAddScore:NO isLongWait:NO withSE:NO];
    [self updateItemWithTag:kAKHitNumTag currentValue:0 targetValue:m_hit
             incrementValue:-1 isAddScore:NO isLongWait:NO withSE:NO];
    [self updateItemWithTag:kAKRestNumTag currentValue:0 targetValue:m_rest
             incrementValue:-1 isAddScore:NO isLongWait:NO withSE:NO];
    [self updateItemWithTag:kAKTimeBonusTag currentValue:m_timeBonus
                targetValue:m_timeBonusTarget incrementValue:-1 isAddScore:YES isLongWait:NO withSE:NO];
    [self updateItemWithTag:kAKHitBonusTag currentValue:m_hitBonus
                targetValue:m_hitBonusTarget incrementValue:-1 isAddScore:YES isLongWait:NO withSE:NO];
    [self updateItemWithTag:kAKRestBonusTag currentValue:m_restBonus
                targetValue:m_restBonusTarget incrementValue:-1 isAddScore:YES isLongWait:NO withSE:NO];
    
    // スコアカウントの効果音を鳴らす
    [[SimpleAudioEngine sharedEngine] playEffect:kAKScoreCountSE];
    
    // 状態を表示完了にする
    m_state = kAKstateFinish;
}
@end
