/*!
 @file AKResultLayer.m
 @brief ステージクリア結果レイヤー
 
 ステージクリア結果画面のレイヤーを定義する。
 */

#import "AKResultLayer.h"
#import "AKGameScene.h"
#import "AKLabel.h"
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

/// タイトルキャプション位置
static const CGPoint kAKTitleCaptionPos = {152, 240};
/// タイムキャプション位置
static const CGPoint kAKTimeCaptionPos = {kAKCaptionPosX, kAKTimePosY};
/// タイム値位置
static const CGPoint kAKTimeNumPos = {kAKValuePosX, kAKTimePosY};
/// タイムボーナス位置
static const CGPoint kAKTimeBonusPos = {kAKBonusPosX, kAKTimePosY};
/// 命中率キャプション位置
static const CGPoint kAKHitCaptionPos = {kAKCaptionPosX, kAKHitPosY};
/// 命中率値位置
static const CGPoint kAKHitNumPos = {kAKValuePosX, kAKHitPosY};
/// 命中率ボーナス位置
static const CGPoint kAKHitBonusPos = {kAKBonusPosX, kAKHitPosY};
/// 残機キャプション位置
static const CGPoint kAKRestCaptionPos = {kAKCaptionPosX, kAKRestPosY};
/// 残機値位置
static const CGPoint kAKRestNumPos = {kAKValuePosX, kAKRestPosY};
/// 残機ボーナス位置
static const CGPoint kAKRestBonusPos = {kAKBonusPosX, kAKRestPosY};
/// スコアキャプション位置
static const CGPoint kAKScoreCaptionPos = {kAKCaptionPosX, kAKScorePosY};
/// スコア値位置
static const CGPoint kAKScoreNumPos = {kAKBonusPosX, kAKScorePosY};

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
    
    // 背景画像を読み込む
    CCSprite *background = [CCSprite spriteWithFile:kAKBaseColorImage];
    assert(background != nil);
    
    // 背景画像の配置位置を画面中央にする
    background.position = ccp(kAKScreenSize.width / 2, kAKScreenSize.height / 2);
    
    // レイヤーに配置する
    [self addChild:background z:0];
    
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
    [self createLabelWithString:kAKTitleCaption pos:&kAKTitleCaptionPos];
    
    // タイムキャプションラベルを生成する
    [self createLabelWithString:kAKTimeCaption pos:&kAKTimeCaptionPos];
    
    // 命中率キャプションラベルを生成する
    [self createLabelWithString:kAKHitCaption pos:&kAKHitCaptionPos];
    
    // 残機キャプションラベルを生成する
    [self createLabelWithString:kAKRestCaption pos:&kAKRestCaptionPos];
    
    // スコアキャプションラベルを生成する
    [self createLabelWithString:kAKScoreCaption pos:&kAKScoreCaptionPos];
    
    // タイムラベルを生成する
    [self createLabelWithTag:kAKTimeNumTag pos:&kAKTimeNumPos];
    
    // タイムボーナスラベルを生成する
    [self createLabelWithTag:kAKTimeBonusTag pos:&kAKTimeBonusPos];
    
    // 命中率ラベルを生成する
    [self createLabelWithTag:kAKHitNumTag pos:&kAKHitNumPos];

    // 命中率ボーナスラベルを生成する
    [self createLabelWithTag:kAKHitBonusTag pos:&kAKHitBonusPos];
    
    // 残機ラベルを生成する
    [self createLabelWithTag:kAKRestNumTag pos:&kAKRestNumPos];
    
    // 残機ボーナスラベルを生成する
    [self createLabelWithTag:kAKRestBonusTag pos:&kAKRestBonusPos];
    
    // スコアラベルを生成する
    [self createLabelWithTag:kAKScoreNumTag pos:&kAKScoreNumPos];
    
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
- (void)createLabelWithTag:(NSInteger)tag pos:(const CGPoint *)pos
{
    // 各ラベルの初期文字列を作成する
    NSString *initString = [NSString stringWithFormat:kAKLabelFormat, 0];
    
    // ラベルを生成する
    AKLabel *label = [AKLabel labelWithString:initString maxLength:initString.length maxLine:1 hasFrame:NO];
    
    // タグを設定する
    label.tag = tag;
    
    // 位置を設定する
    label.position = *pos;
    
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
- (void)createLabelWithString:(NSString *)str pos:(const CGPoint *)pos
{
    // ラベルを生成する
    AKLabel *label = [AKLabel labelWithString:str maxLength:str.length maxLine:1 hasFrame:NO];
    
    // 位置を設定する
    label.position = *pos;
    
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
 @return 更新後の値
 */
- (NSInteger)updateItemWithTag:(NSInteger)tag currentValue:(NSInteger)current
                   targetValue:(NSInteger)target incrementValue:(NSInteger)increment
                    isAddScore:(BOOL)isAddScore isLongWait:(BOOL)isLongWait
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
                         incrementValue:-1 isAddScore:NO isLongWait:NO];
                break;
                
            case kAKstateTimeView:    // タイム表示中
                
                // タイムラベルを更新する
                [self updateItemWithTag:kAKTimeNumTag currentValue:0 targetValue:m_time
                         incrementValue:-1 isAddScore:NO isLongWait:NO];
                break;
                
            case kAKstateHitView:     // 命中率表示中
                
                // 命中率ラベルを更新する
                [self updateItemWithTag:kAKHitNumTag currentValue:0 targetValue:m_hit
                         incrementValue:-1 isAddScore:NO isLongWait:NO];
                break;
                
            case kAKstateRestView:    // 残機表示中
                
                // 残機ラベルを更新する
                [self updateItemWithTag:kAKRestNumTag currentValue:0 targetValue:m_rest
                         incrementValue:-1 isAddScore:NO isLongWait:NO];
                break;
                
            case kAKstateTimeBonus:   // タイムボーナス表示中
                
                // タイムボーナスを更新する
                m_timeBonus = [self updateItemWithTag:kAKTimeBonusTag currentValue:m_timeBonus
                                          targetValue:m_timeBonusTarget
                                       incrementValue:kAKIncrementValue
                                           isAddScore:YES isLongWait:NO];
                break;
                
            case kAKstateHitBonus:    // 命中率ボーナス表示中
                
                // 命中率ボーナスを更新する
                m_hitBonus = [self updateItemWithTag:kAKHitBonusTag currentValue:m_hitBonus
                                         targetValue:m_hitBonusTarget
                                      incrementValue:kAKIncrementValue
                                          isAddScore:YES isLongWait:NO];
                break;
                
            case kAKstateRestBonus:   // 残機ボーナス表示中
                
                // 残機ボーナスを更新する
                m_restBonus = [self updateItemWithTag:kAKRestBonusTag currentValue:m_restBonus
                                          targetValue:m_restBonusTarget
                                       incrementValue:kAKRestIncrementValue
                                           isAddScore:YES isLongWait:YES];
                
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
             incrementValue:-1 isAddScore:NO isLongWait:NO];
    [self updateItemWithTag:kAKTimeNumTag currentValue:0 targetValue:m_time
             incrementValue:-1 isAddScore:NO isLongWait:NO];
    [self updateItemWithTag:kAKHitNumTag currentValue:0 targetValue:m_hit
             incrementValue:-1 isAddScore:NO isLongWait:NO];
    [self updateItemWithTag:kAKRestNumTag currentValue:0 targetValue:m_rest
             incrementValue:-1 isAddScore:NO isLongWait:NO];
    [self updateItemWithTag:kAKTimeBonusTag currentValue:m_timeBonus
                targetValue:m_timeBonusTarget incrementValue:-1 isAddScore:YES isLongWait:NO];
    [self updateItemWithTag:kAKHitBonusTag currentValue:m_hitBonus
                targetValue:m_hitBonusTarget incrementValue:-1 isAddScore:YES isLongWait:NO];
    [self updateItemWithTag:kAKRestBonusTag currentValue:m_restBonus
                targetValue:m_restBonusTarget incrementValue:-1 isAddScore:YES isLongWait:NO];
    
    // 状態を表示完了にする
    m_state = kAKstateFinish;
}
@end
