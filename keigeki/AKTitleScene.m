/*!
 @file AKTitleScene.m
 @brief タイトルシーンクラスの定義
 
 タイトルシーンを管理するクラスを定義する。
 */

#import "AKTitleScene.h"
#import "AKInterface.h"
#import "AKLabel.h"
#import "AKGameScene.h"
#import "AKHowToPlayScene.h"
#import "AKScreenSize.h"
#import "common.h"
#import "SimpleAudioEngine.h"

/// メニュー項目のタグ
enum {
    kAKTitleMenuGame = 0,   ///< ゲーム開始ボタン
    kAKTitleMenuHowTo,      ///< 遊び方ボタン
    kAKTitleMenuCredit,     ///< クレジットボタン
    kAKTitleMenuCount       ///< メニュー項目数
};

/// レイヤーのタグ
enum {
    kAKTitleLayerBackground = 0,    ///< 背景レイヤー
    kAKTitleLayerInterface          ///< インターフェースレイヤー
};

/// タイトル画像のファイル名
static NSString *kAKTitleImage = @"Title.png";

/// ゲーム開始メニューのキャプション
static NSString *kAKGameStartCaption = @"GAME START ";
/// 遊び方画面メニューのキャプション
static NSString *kAKHowToPlayCaption = @"HOW TO PLAY";
/// クレジット画面メニューのキャプション
static NSString *kAKCreditCaption = @"CREDIT     ";

/// タイトルの位置、横方向の中心からの位置
static const float kAKTitlePosFromHorizontalCenterPoint = -100.0f;
/// メニュー項目の数
static const NSInteger kAKMenuItemCount = 3;
/// メニュー項目の位置、右からの位置
static const float kAKMenuPosRightPoint = 120.0f;
/// ゲーム開始メニューのキャプションの表示位置、上からの比率
static const float kAKGameStartMenuPosTopRatio = 0.3f;
/// 遊び方画面メニューのキャプションの表示位置、上からの比率
static const float kAKHowToPlayMenuPosTopRatio = 0.5f;
/// クレジット画面メニューのキャプションの表示位置、上からの比率
static const float kAKCreditMenuPosTopRatio = 0.7f;

/// 各ノードのz座標
enum {
    kAKTitleBackPosZ = 0,   ///< 背景のz座標
    kAKTitleMenuPosZ        ///< メニュー項目のz座標
};

/*!
 @brief タイトルレイヤークラス
 
 タイトルシーンを管理する。
 */
@implementation AKTitleScene

/*!
 @brief オブジェクト生成処理
 
 オブジェクトの生成を行う。
 @return 生成したオブジェクト。失敗時はnilを返す。
 */
- (id)init
{
    DBGLOG(0, @"init 開始");
    
    // スーパークラスの生成処理
    self = [super init];
    if (!self) {
        return nil;
    }
    
    // 背景レイヤーを配置する
    [self addChild:AKCreateBackColorLayer() z:kAKTitleLayerBackground tag:kAKTitleLayerBackground];
    
    // インターフェースを作成する
    AKInterface *interface = [AKInterface interfaceWithCapacity:kAKMenuItemCount];
    
    // インターフェースをシーンに配置する
    [self addChild:interface z:kAKTitleLayerInterface tag:kAKTitleLayerInterface];
    
    // タイトル画像を読み込む
    CCSprite *image = [CCSprite spriteWithFile:kAKTitleImage];
    NSAssert(image != nil, @"can not open title image : %@", kAKTitleImage);
    
    // 配置位置を設定する
    image.position = ccp([AKScreenSize positionFromHorizontalCenterPoint:kAKTitlePosFromHorizontalCenterPoint],
                         [AKScreenSize center].y);
    
    // タイトル画像をインターフェースに配置する
    [interface addChild:image z:kAKTitleBackPosZ];
    
    // ゲームスタートのメニューを作成する
    [interface addMenuWithString:kAKGameStartCaption
                           atPos:ccp([AKScreenSize positionFromRightPoint:kAKMenuPosRightPoint],
                                     [AKScreenSize positionFromTopRatio:kAKGameStartMenuPosTopRatio])
                          action:@selector(startGame)
                               z:0
                             tag:kAKTitleMenuGame
                       withFrame:YES];
    
    // 遊び方のメニューを作成する
    [interface addMenuWithString:kAKHowToPlayCaption
                           atPos:ccp([AKScreenSize positionFromRightPoint:kAKMenuPosRightPoint],
                                     [AKScreenSize positionFromTopRatio:kAKHowToPlayMenuPosTopRatio])
                          action:@selector(startHowTo)
                               z:0
                             tag:kAKTitleMenuHowTo
                       withFrame:YES];
    
    // クレジットのメニューを作成する
    [interface addMenuWithString:kAKCreditCaption
                           atPos:ccp([AKScreenSize positionFromRightPoint:kAKMenuPosRightPoint],
                                     [AKScreenSize positionFromTopRatio:kAKCreditMenuPosTopRatio])
                          action:@selector(startCredit)
                               z:0
                             tag:kAKTitleMenuCredit
                       withFrame:YES];
    
    // すべてのメニュー項目を有効とする
    interface.enableItemTagStart = 0;
    interface.enableItemTagEnd = kAKTitleMenuCount - 1;
    
    DBGLOG(0, @"init 終了");
    return self;
}

/*!
 @brief インターフェースレイヤーの取得
 
 インターフェースレイヤーを取得する。
 @return インターフェースレイヤー
 */
- (AKInterface *)interface
{
    return (AKInterface *)[self getChildByTag:kAKTitleLayerInterface];
}

/*!
 @brief ゲームの開始
 
 ゲームを開始する。ゲームシーンへと遷移する。
 */
- (void)startGame
{
    DBGLOG(0, @"startGame");
    
    // メニュー選択時の効果音を鳴らす
    [[SimpleAudioEngine sharedEngine] playEffect:kAKMenuSelectSE];

    // ボタンのブリンクアクションを作成する
    CCBlink *action = [CCBlink actionWithDuration:0.2f blinks:2];
    
    // ボタンを取得する
    CCNode *button = [self.interface getChildByTag:kAKTitleMenuGame];
    
    // ブリンクアクションを開始する
    [button runAction:action];
    
    // ゲームシーンへの遷移を作成する
    CCTransitionFade *transition = [CCTransitionFade transitionWithDuration:0.5f scene:[AKGameScene sharedInstance]];
    
    // ゲームシーンへ遷移する
    [[CCDirector sharedDirector] replaceScene:transition];
}

/*!
 @brief 遊び方画面の開始
 
 遊び方画面を開始する。遊び方シーンへと遷移する。
 */
- (void)startHowTo
{
    DBGLOG(0, @"startHowTo");
    
    // メニュー選択時の効果音を鳴らす
    [[SimpleAudioEngine sharedEngine] playEffect:kAKMenuSelectSE];

    // ボタンのブリンクアクションを作成する
    CCBlink *action = [CCBlink actionWithDuration:0.2f blinks:2];
    
    // ボタンを取得する
    CCNode *button = [self.interface getChildByTag:kAKTitleMenuHowTo];
    
    // ブリンクアクションを開始する
    [button runAction:action];
    
    // 遊び方シーンへの遷移を作成する
    CCTransitionFade *transition = [CCTransitionFade transitionWithDuration:0.5f scene:[AKHowToPlayScene node]];
    
    // 遊び方シーンへ遷移する
    [[CCDirector sharedDirector] replaceScene:transition];
}

/*!
 @brief クレジット画面の開始
 
 クレジット画面を開始する。クレジットシーンへと遷移する。
 */
- (void)startCredit
{
    DBGLOG(1, @"startCredit");
    // メニュー選択時の効果音を鳴らす
    [[SimpleAudioEngine sharedEngine] playEffect:kAKMenuSelectSE];
    
}
@end
