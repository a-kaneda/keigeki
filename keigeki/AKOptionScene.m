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
#import "AKTwitterHelper.h"

// オプション画面シーンに配置するノードのタグ
enum {
    kAKOptionSceneBackColor = 0,    ///< 背景色のタグ
    kAKOptionSceneLabel,            ///< ラベルのタグ
    kAKOptionSceneInterface         ///< インターフェースレイヤーのタグ
};

// インターフェースレイヤーに配置するノードのタグ
enum {
    kAKMenuLeaderboard = 1,     ///< Leaderboardボタンのタグ
    kAKMenuAchievements,        ///< Achievementsボタンのタグ
    kAKMenuTwitterOff,          ///< Twitter連携Offボタンのタグ
    kAKMenuTwitterManual,       ///< Twitter連携Manualボタンのタグ
    kAKMenuTwitterAuto,         ///< Twitter連携Autoボタンのタグ
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
/// Twitter連携自動ボタンのキャプション
static NSString *kAKTwitterAutoCaption = @" O N ";
/// Twitter連携手動ボタンのキャプション
static NSString *kAKTwitterManualCaption = @"MANUAL";
/// Twitter連携Offボタンのキャプション
static NSString *kAKTwitterOffCaption = @" OFF ";
/// Game Centerのキャプション位置、上からの比率
static const float kAKGameCenterCaptionPosTopRatio = 0.15f;
/// Leaderboardボタンの位置、上からの比率
static const float kAKLeaderboardPosTopRatio = 0.3f;
/// Achievementsボタンの位置、上からの比率
static const float kAKAchievemetnsPosTopRatio = 0.5f;
/// Twitter連携のキャプション位置、上からの比率
static const float kAKTwitterCaptionPosTopRatio = 0.65f;
/// Twitter連携ボタンの位置、上からの比率
static const float kAKTwitterButtonPosTopRatio = 0.8f;
/// Twitter連携自動ボタンの位置、左からの比率
static const float kAKTwitterAutoPosLeftRatio = 0.8f;
/// Twitter連携手動ラジオボタンの位置、左からの比率
static const float kAKTwitterManualPosLeftRatio = 0.5f;
/// Twitter連携Offラジオボタンの位置、左からの比率
static const float kAKTwitterOffButtonPosTopRatio = 0.2f;
/// 戻るボタンの位置、右からの位置
static const float kAKBackPosRightPoint = 26.0f;
/// 戻るボタンの位置、上からの位置
static const float kAKBackPosTopPoint = 26.0f;

/*!
 @brief オプション画面シーン
 
 オプション画面のシーン。
 */
@implementation AKOptionScene

@synthesize leaderboardButton = leaderboardButton_;
@synthesize achievementsButton = achievementsButton_;
@synthesize twitterAutoButton = twitterAutoButton_;
@synthesize twitterManualButton = twitterManualButton_;
@synthesize twitterOffButton = twitterOffButton_;

/*!
 @brief インスタンス初期化処理
 
 インスタンスの初期化を行う。
 @return 初期化したインスタンス。失敗時はnilを返す。
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
    
    // Game Centerのラベルを作成する
    AKLabel *gameCenterLabel = [AKLabel labelWithString:kAKGameCenterCaption
                                              maxLength:kAKGameCenterCaption.length
                                                maxLine:1
                                                  frame:kAKLabelFrameNone];
    
    // Game Centerのラベルの位置を設定する
    gameCenterLabel.position = ccp([AKScreenSize center].x,
                                   [AKScreenSize positionFromTopRatio:kAKGameCenterCaptionPosTopRatio]);
    
    // Game Centerのラベルを配置する
    [self addChild:gameCenterLabel z:kAKOptionSceneLabel];
    
    // Twitter連携のラベルを作成する
    AKLabel *twitterLabel = [AKLabel labelWithString:kAKTwitterCaption
                                           maxLength:kAKTwitterCaption.length
                                             maxLine:1
                                               frame:kAKLabelFrameNone];
    
    // Twitter連携のラベルの位置を設定する
    twitterLabel.position = ccp([AKScreenSize center].x,
                                [AKScreenSize positionFromTopRatio:kAKTwitterCaptionPosTopRatio]);
    
    // Twitter連携のラベルを配置する
    [self addChild:twitterLabel z:kAKOptionSceneLabel];
    
    // インターフェースを作成する
    AKInterface *interface = [AKInterface interfaceWithCapacity:kAKMenuItemCount + 1];
    
    // シーンへ配置する
    [self addChild:interface z:kAKOptionSceneInterface tag:kAKOptionSceneInterface];
    
    // Leaderboardのメニューを作成する
    self.leaderboardButton = [interface addMenuWithString:kAKLeaderboardCaption
                                                    atPos:ccp([AKScreenSize center].x,
                                                              [AKScreenSize positionFromTopRatio:kAKLeaderboardPosTopRatio])
                                                   action:@selector(selectLeaerboard)
                                                        z:0
                                                      tag:kAKMenuLeaderboard
                                                withFrame:YES];

    // Achievementsのメニューを作成する
    self.achievementsButton = [interface addMenuWithString:kAKAchievementsCaption
                                                     atPos:ccp([AKScreenSize center].x,
                                                               [AKScreenSize positionFromTopRatio:kAKAchievemetnsPosTopRatio])
                                                    action:@selector(selectAchievements)
                                                         z:0
                                                       tag:kAKMenuAchievements
                                                 withFrame:YES];
    
    // Twitter連携自動ボタンのメニューを作成する
    self.twitterAutoButton = [interface addMenuWithString:kAKTwitterAutoCaption
                                                    atPos:ccp([AKScreenSize positionFromLeftRatio:kAKTwitterAutoPosLeftRatio],
                                                              [AKScreenSize positionFromTopRatio:kAKTwitterButtonPosTopRatio])
                                                   action:@selector(selectTwitterAuto)
                                                        z:0
                                                      tag:kAKMenuTwitterAuto
                                                withFrame:YES];
    
    // Twitter連携手動ボタンのメニューを作成する
    self.twitterManualButton = [interface addMenuWithString:kAKTwitterManualCaption
                                                      atPos:ccp([AKScreenSize positionFromLeftRatio:kAKTwitterManualPosLeftRatio],
                                                                [AKScreenSize positionFromTopRatio:kAKTwitterButtonPosTopRatio])
                                                     action:@selector(selectTwitterManual)
                                                          z:0
                                                        tag:kAKMenuTwitterManual
                                                  withFrame:YES];
    
    // Twitter連携Offボタンのメニューを作成する
    self.twitterOffButton = [interface addMenuWithString:kAKTwitterOffCaption
                                                   atPos:ccp([AKScreenSize positionFromLeftRatio:kAKTwitterOffButtonPosTopRatio],
                                                             [AKScreenSize positionFromTopRatio:kAKTwitterButtonPosTopRatio])
                                                  action:@selector(selectTwitterOff)
                                                       z:0
                                                     tag:kAKMenuTwitterOff
                                               withFrame:YES];
    
    // 戻るボタンをインターフェースに配置する
    [interface addMenuWithFile:kAKBackImage
                         atPos:ccp([AKScreenSize positionFromRightPoint:kAKBackPosRightPoint],
                                   [AKScreenSize positionFromTopPoint:kAKBackPosTopPoint])
                        action:@selector(selectBack)
                             z:0
                           tag:kAKMenuBack];
    
    // すべてのメニュー項目を有効とする
    interface.enableTag = 0xFFFFFFFFUL;
    
    // Twitter連携ボタンの表示を更新する
    [self updateTwitterButton];

    return self;
}

/*!
 @brief インスタンス解放処理
 
 インスタンス解放時の処理を行う。
 メンバを解放する。
 */
- (void)dealloc
{
    // メンバを解放する
    self.leaderboardButton = nil;
    self.achievementsButton = nil;
    self.twitterAutoButton = nil;
    self.twitterManualButton = nil;
    self.twitterOffButton = nil;
    
    // 親クラスの処理を実行する
    [super dealloc];
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
    
    // ブリンクアクションを開始する
    [self.leaderboardButton runAction:action];
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
        
    // ブリンクアクションを開始する
    [self.achievementsButton runAction:action];
}

/*!
 @brief Twitter連携自動ボタン選択時の処理
 
 Twitter連携自動ボタン選択時の処理を行う。
 Twitter連携を自動に変更する。
 */
- (void)selectTwitterAuto
{
    // メニュー選択時の効果音を鳴らす
    [[SimpleAudioEngine sharedEngine] playEffect:kAKMenuSelectSE];
    
    // Twitter設定を自動にする
    [AKTwitterHelper sharedHelper].mode = kAKTwitterModeAuto;

    // Twitter連携ボタンの表示を更新する
    [self updateTwitterButton];    
}

/*!
 @brief Twitter連携手動ボタン選択時の処理
 
 Twitter連携手動ボタン選択時の処理を行う。
 Twitter連携を手動に変更する。
 */
- (void)selectTwitterManual
{
    // メニュー選択時の効果音を鳴らす
    [[SimpleAudioEngine sharedEngine] playEffect:kAKMenuSelectSE];
    
    // Twitter設定を手動にする
    [AKTwitterHelper sharedHelper].mode = kAKTwitterModeManual;
    
    // Twitter連携ボタンの表示を更新する
    [self updateTwitterButton];
}

/*!
 @brief Twitter連携Offボタン選択時の処理
 
 Twitter連携Offボタン選択時の処理を行う。
 Twitter連携をOffに変更する。
 */
- (void)selectTwitterOff
{
    // メニュー選択時の効果音を鳴らす
    [[SimpleAudioEngine sharedEngine] playEffect:kAKMenuSelectSE];
    
    // Twitter設定をOffにする
    [AKTwitterHelper sharedHelper].mode = kAKTwitterModeOff;
    
    // Twitter連携ボタンの表示を更新する
    [self updateTwitterButton];
}

/*!
 @brief 戻るボタン選択時の処理
 
 戻るボタンを選択した時の処理を行う。
 効果音を鳴らし、タイトルシーンへと戻る。
 */
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
    self.leaderboardButton.visible = YES;
    
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
    self.achievementsButton.visible = YES;
    
    // Achievementsを表示する
    [[AKGameCenterHelper sharedHelper] showAchievements];
}

/*!
 @brief Twitter連携ボタン表示更新
 
 Twitter連携ボタンの色反転をTwitter設定に応じて変更する。
 設定内容に対応するボタンの色を反転する。
 */
- (void)updateTwitterButton
{
    AKLog(1, @"Twitter連携ボタン表示更新開始");
    
    // Twitter連携の設定を取得し、処理を分岐する
    switch ([[AKTwitterHelper sharedHelper] mode]) {
            
        case kAKTwitterModeAuto:        // 自動
            
            AKLog(1, @"Twitter連携自動");
            
            // Twitter連携自動ボタンのみ色反転する
            self.twitterAutoButton.isReverse = YES;
            self.twitterManualButton.isReverse = NO;
            self.twitterOffButton.isReverse = NO;
            break;
            
        case kAKTwitterModeManual:      // 手動
            
            AKLog(1, @"Twitter連携手動");
            
            // Twitter連携手動ボタンのみ色反転する
            self.twitterAutoButton.isReverse = NO;
            self.twitterManualButton.isReverse = YES;
            self.twitterOffButton.isReverse = NO;
            break;
            
        case kAKTwitterModeOff:         // Off
            
            AKLog(1, @"Twitter連携Off");
            
            // Twitter連携OFfボタンのみ色反転する
            self.twitterAutoButton.isReverse = NO;
            self.twitterManualButton.isReverse = NO;
            self.twitterOffButton.isReverse = YES;
            break;
            
        default:
            NSAssert(0, @"Twitter設定取得失敗:%d", [[AKTwitterHelper sharedHelper] mode]);
            break;
    }
}

@end
