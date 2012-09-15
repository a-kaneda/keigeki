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
#import "common.h"

/// タイトル画像のファイル名
static NSString *kAKTitleImage = @"Title.png";

/// ゲーム開始メニューのキャプション
static NSString *kAKGameStartCaption = @"GAME START";
/// 遊び方画面メニューのキャプション
static NSString *kAKHowToPlayCaption = @"HOW TO PLAY";
/// クレジット画面メニューのキャプション
static NSString *kAKCreditCaption = @"CREDIT";

/// メニュー項目の数
static const NSInteger kAKMenuItemCount = 3;
/// ゲーム開始メニューのキャプションの表示位置
static const NSInteger kAKGameStartMenuPos = 150;
/// 遊び方画面メニューのキャプションの表示位置
static const NSInteger kAKHowToPlayMenuPos = 100;
/// クレジット画面メニューのキャプションの表示位置
static const NSInteger kAKCreditMenuPos = 50;

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
    
    // インターフェースを作成する
    AKInterface *interface = [AKInterface interfaceWithCapacity:kAKMenuItemCount];
    
    // インターフェースをシーンに配置する
    [self addChild:interface];
    
    // タイトル画像を読み込む
    CCSprite *image = [CCSprite spriteWithFile:kAKTitleImage];
    NSAssert(image != nil, @"can not open title image : %@", kAKTitleImage);
    
    // 配置位置は画面中央とする
    image.position = ccp(kAKScreenSize.width / 2, kAKScreenSize.height / 2);
    
    // タイトル画像をインターフェースに配置する
    [interface addChild:image z:kAKTitleBackPosZ];
    
    // ゲームスタートのメニューを作成する
    [interface addMenuWithString:kAKGameStartCaption
                           atPos:ccp(kAKScreenSize.width / 2, kAKGameStartMenuPos)
                        isCenter:YES action:@selector(startGame)
                               z:0
                             tag:0];
    
    // 遊び方のメニューを作成する
    [interface addMenuWithString:kAKHowToPlayCaption
                           atPos:ccp(kAKScreenSize.width / 2, kAKHowToPlayMenuPos)
                        isCenter:YES
                          action:@selector(startHowTo)
                               z:0
                             tag:0];
    
    // クレジットのメニューを作成する
    [interface addMenuWithString:kAKCreditCaption
                           atPos:ccp(kAKScreenSize.width / 2, kAKCreditMenuPos)
                        isCenter:YES
                          action:@selector(startCredit)
                               z:0
                             tag:0];
    
    DBGLOG(0, @"init 終了");
    return self;
}

/*!
 @brief ゲームの開始
 
 ゲームを開始する。ゲームシーンへと遷移する。
 */
- (void)startGame
{
    DBGLOG(0, @"startGame");
    [[CCDirector sharedDirector] replaceScene:[AKGameScene sharedInstance]];
}

/*!
 @brief 遊び方画面の開始
 
 遊び方画面を開始する。遊び方シーンへと遷移する。
 */
- (void)startHowTo
{
    DBGLOG(0, @"startHowTo");
    [[CCDirector sharedDirector] replaceScene:[AKHowToPlayScene node]];
}

/*!
 @brief クレジット画面の開始
 
 クレジット画面を開始する。クレジットシーンへと遷移する。
 */
- (void)startCredit
{
    DBGLOG(1, @"startCredit");
}
@end
