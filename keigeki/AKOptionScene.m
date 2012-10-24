/*!
 @file AKOptionScene.m
 @brief オプション画面シーンクラスの定義
 
 オプション画面シーンクラスを定義する。
 */

#import "AKOptionScene.h"
#import "SimpleAudioEngine.h"
#import "AKScreenSize.h"
#import "AKLabel.h"
#import "AKTitleScene.h"
#import "AKGameCenterHelper.h"

// オプション画面シーンに配置するノードのタグ
enum {
    kAKOptionSceneBackColor = 0,    ///< 背景色のタグ
    kAKOptionSceneInterface         ///< インターフェースレイヤーのタグ
};

// インターフェースレイヤーに配置するノードのタグ
enum {
    kAKMenuLeaderboard = 0,     ///< Leaderboardボタンのタグ
    kAKMenuAchievements,        ///< Achievementsボタンのタグ
    kAKMenuTwitterOff,          ///< Twitter連携Offボタンのタグ
    kAKMenuTwitterOn,           ///< Twitter連携Onボタンのタグ
    kAKMenuBack,                ///< 戻るボタンのタグ
    kAKMenuItemCount            ///< メニュー項目の数
};

/// 戻るボタンの画像ファイル名
static NSString *kAKBackImage = @"BackButton.png";
/// Game Centerのキャプション
static NSString *kAKGameCenterCaption = @"GAME CENTER";
/// Leaderboardボタンのキャプション
static NSString *kAKLeaderboardCaption = @"LEADERBOARD";
/// Achievementsボタンのキャプション
static NSString *kAKAchievementsCaption = @"ACHIEVEMENTS";
/// Twitter連携のキャプション
static NSString *kAKTwitterCaption = @"TWITTER";
/// Twitter連携Onラジオボタンのキャプション
static NSString *kAKTwitterOnCaption = @"ON ";
/// Twitter連携Offラジオボタンのキャプション
static NSString *kAKTwitterOffCaption = @"OFF";
/// Game Centerのキャプション位置、上からの比率
static const float kAKGameCenterCaptionPosTopRatio = 0.1f;
/// Leaderboardボタンの位置、上からの比率
static const float kAKLeaderboardPosTopRatio = 0.3f;
/// Achievementsボタンの位置、上からの比率
static const float kAKAchievemetnsPosTopRatio = 0.5f;
/// Twitter連携のキャプション位置、上からの比率
static const float kAKTwitterCaptionPosTopRatio = 0.7f;
/// Twitter連携On/Offラジオボタンの位置、上からの比率
static const float kAKTwitterOnOffPosTopRatio = 0.9f;
/// Twitter連携Onラジオボタンの位置、左からの比率
static const float kAKTwitterOnPosLeftRatio = 0.4f;
/// Twitter連携Offラジオボタンの位置、左からの比率
static const float kAKTwitterOffPosLeftRatio = 0.6f;
/// 戻るボタンの位置、右からの位置
static const float kAKBackPosRightPoint = 26.0f;
/// 戻るボタンの位置、上からの位置
static const float kAKBackPosTopPoint = 26.0f;

/*!
 @brief オプション画面シーン
 
 オプション画面のシーン。
 */
@implementation AKOptionScene

/*!
 @brief オブジェクト初期化処理
 
 オブジェクトの初期化を行う。
 @return 初期化したオブジェクト。失敗時はnilを返す。
 */
- (id)init
{
    // スーパークラスの生成処理
    self = [super init];
    if (!self) {
        return nil;
    }
    
    // 背景色レイヤーを作成する
    CCLayerColor *backColor = AKCreateBackColorLayer();
    
    // シーンへ配置する
    [self addChild:backColor z:kAKOptionSceneBackColor tag:kAKOptionSceneBackColor];
    
    // インターフェースを作成する
    AKInterface *interface = [AKInterface interfaceWithCapacity:kAKMenuItemCount];
    
    // シーンへ配置する
    [self addChild:interface z:kAKOptionSceneInterface tag:kAKOptionSceneInterface];
    
    // Game Centerのラベルを作成する
    AKLabel *gameCenterLabel = [AKLabel labelWithString:kAKGameCenterCaption
                                              maxLength:kAKGameCenterCaption.length
                                                maxLine:1
                                                  frame:kAKLabelFrameNone];
    
    // Game Centerのラベルの位置を設定する
    gameCenterLabel.position = ccp([AKScreenSize center].x,
                                   [AKScreenSize positionFromTopRatio:kAKGameCenterCaptionPosTopRatio]);
    
    // Game Centerのラベルを配置する
    [interface addChild:gameCenterLabel];
    
    // Leaderboardのメニューを作成する
    [interface addMenuWithString:kAKLeaderboardCaption
                           atPos:ccp([AKScreenSize center].x,
                                     [AKScreenSize positionFromTopRatio:kAKLeaderboardPosTopRatio])
                          action:@selector(selectLeaerboard)
                               z:0
                             tag:kAKMenuLeaderboard
                       withFrame:YES];

    // Achievementsのメニューを作成する
    [interface addMenuWithString:kAKAchievementsCaption
                           atPos:ccp([AKScreenSize center].x,
                                     [AKScreenSize positionFromTopRatio:kAKAchievemetnsPosTopRatio])
                          action:@selector(selectAchievements)
                               z:0
                             tag:kAKMenuAchievements
                       withFrame:YES];
    
    // Twitter連携のラベルを作成する
    AKLabel *twitterLabel = [AKLabel labelWithString:kAKTwitterCaption
                                           maxLength:kAKTwitterCaption.length
                                             maxLine:1
                                               frame:kAKLabelFrameNone];
    
    // Twitter連携のラベルの位置を設定する
    twitterLabel.position = ccp([AKScreenSize center].x,
                                [AKScreenSize positionFromTopRatio:kAKTwitterCaptionPosTopRatio]);
    
    // Twitter連携のラベルを配置する
    [interface addChild:twitterLabel];
    
    // 戻るボタンをインターフェースに配置する
    [interface addMenuWithFile:kAKBackImage
                         atPos:ccp([AKScreenSize positionFromRightPoint:kAKBackPosRightPoint],
                                   [AKScreenSize positionFromTopPoint:kAKBackPosTopPoint])
                        action:@selector(selectBack)
                             z:0
                           tag:kAKMenuBack];
    
    // すべてのメニュー項目を有効とする
    interface.enableItemTagStart = 0;
    interface.enableItemTagEnd = kAKMenuItemCount - 1;

    return self;
}

/*!
 @brief Leaderboardボタン取得
 
 Leaderboardボタンのインスタンスを取得する。
 @return Leaderboardボタン
 */
- (CCNode *)leaderboard
{
    NSAssert([self getChildByTag:kAKOptionSceneInterface] != nil, @"インターフェースレイヤーが作成されていない");
    NSAssert([[self getChildByTag:kAKOptionSceneInterface] getChildByTag:kAKMenuLeaderboard] != nil, @"Leaderboardボタンが作成されていない");
    return [[self getChildByTag:kAKOptionSceneInterface] getChildByTag:kAKMenuLeaderboard];
}

/*!
 @brief Achievementsボタン取得
 
 Achievementsボタンのインスタンスを取得する。
 @return Achievementsボタン
 */
- (CCNode *)achievements
{
    NSAssert([self getChildByTag:kAKOptionSceneInterface] != nil, @"インターフェースレイヤーが作成されていない");
    NSAssert([[self getChildByTag:kAKOptionSceneInterface] getChildByTag:kAKMenuAchievements] != nil, @"Achievementsボタンが作成されていない");
    return [[self getChildByTag:kAKOptionSceneInterface] getChildByTag:kAKMenuAchievements];
}

- (void)onEnter
{
    AKLog(1, @"onEnter");
    [super onEnter];
}
/*!
 @brief Leaderboardボタン選択時の処理
 
 Leaderboardボタン選択時の処理。
 Leaderboardを表示する。
 */
- (void)selectLeaerboard
{
    // メニュー選択時の効果音を鳴らす
    [[SimpleAudioEngine sharedEngine] playEffect:kAKMenuSelectSE];
    
    // ボタンのブリンクアクションを作成する。
    // ブリンクアクション終了後にLeaderboardを表示する。
    // ブリンクアクションの途中でViewを表示させると、消えた状態でアニメーションが止まることがあるため。
    CCBlink *blink = [CCBlink actionWithDuration:0.2f blinks:2];
    CCCallFunc *callFunc = [CCCallFunc actionWithTarget:self selector:@selector(showLeaderboard)];
    CCSequence *action = [CCSequence actions:blink, callFunc, nil];
    
    // ボタンを取得する
    CCNode *button = self.leaderboard;
    
    // ブリンクアクションを開始する
    [button runAction:action];
}

/*!
 @brief Achievementsボタン選択時の処理

 Achievementsボタン選択時の処理
 Achievementsを表示する。
 */
- (void)selectAchievements
{
    // メニュー選択時の効果音を鳴らす
    [[SimpleAudioEngine sharedEngine] playEffect:kAKMenuSelectSE];
    
    // ボタンのブリンクアクションを作成する
    // ブリンクアクション終了後にAchievementsを表示する。
    // ブリンクアクションの途中でViewを表示させると、消えた状態でアニメーションが止まることがあるため。
    CCBlink *blink = [CCBlink actionWithDuration:0.2f blinks:2];
    CCCallFunc *callFunc = [CCCallFunc actionWithTarget:self selector:@selector(showAchievements)];
    CCSequence *action = [CCSequence actions:blink, callFunc, nil];
    
    // ボタンを取得する
    CCNode *button = self.achievements;
    
    // ブリンクアクションを開始する
    [button runAction:action];
}

// Twitter連携Offボタン選択時の処理
- (void)selectTwitterOff
{
    
}

// Twitter連携Onボタン選択時の処理
- (void)selectTwitterOn
{
    
}

// 戻るボタン選択時の処理
- (void)selectBack
{
    // メニュー選択時の効果音を鳴らす
    [[SimpleAudioEngine sharedEngine] playEffect:kAKMenuSelectSE];
    
    // タイトルシーンへの遷移を作成する
    CCTransitionFade *transition = [CCTransitionFade transitionWithDuration:0.5f scene:[AKTitleScene node]];
    
    // タイトルシーンへ遷移する
    [[CCDirector sharedDirector] replaceScene:transition];
}

/*!
 @brief Leaderboard表示
 
 Leaderboardを表示する。
 ボタンのブリンクアクション終了時に呼ばれるので、Leaderboard表示前にボタンのvisibleを表示に変更する。
 */
- (void)showLeaderboard
{
    // ブリンク終了直後はボタン非表示になっているため、表示を元に戻す
    self.leaderboard.visible = YES;
    
    // Achievementsを表示する
    [[AKGameCenterHelper sharedHelper] showLeaderboard];
}

/*! 
 @brief Achievements表示

 Achievementsを表示する。
 ボタンのブリンクアクション終了時に呼ばれるので、Achievements表示前にボタンのvisibleを表示に変更する。
 */
- (void)showAchievements
{
    // ブリンク終了直後はボタン非表示になっているため、表示を元に戻す
    self.achievements.visible = YES;
    
    // Achievementsを表示する
    [[AKGameCenterHelper sharedHelper] showAchievements];
}

@end
