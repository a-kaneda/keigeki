/*!
 @file AKTitleScene.m
 @brief タイトルシーンクラスの定義
 
 タイトルシーンを管理するクラスを定義する。
 */

#import "AKTitleScene.h"
#import "AKInterface.h"
#import "AKLabel.h"
#import "AKGameScene.h"
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
    kAKTitleMenuPosZ,       ///< メニュー項目のz座標
    kAKTitleIntarfeceZ,     ///< メニュー画面インターフェースのz座標
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
    
    // タイトル画像を読み込む
    CCSprite *image = [CCSprite spriteWithFile:kAKTitleImage];
    NSAssert(image != nil, @"can not open title image : %@", kAKTitleImage);
    
    // 配置位置は画面中央とする
    image.position = ccp(kAKScreenSize.width / 2, kAKScreenSize.height / 2);
    
    // タイトル画像を画面に配置する
    [self addChild:image z:kAKTitleBackPosZ];
    
    // インターフェースを作成する
    AKInterface *interface = [AKInterface interfaceWithCapacity:kAKMenuItemCount];
    
    // インターフェースを画面に配置する
    [self addChild:interface z:kAKTitleIntarfeceZ tag:kAKTitleIntarfeceZ];
    
    // ゲームスタートのメニューを作成する
    [self addMenuWithString:kAKGameStartCaption atPosition:kAKGameStartMenuPos action:@selector(startGame)];
    
    // 遊び方のメニューを作成する
    [self addMenuWithString:kAKHowToPlayCaption atPosition:kAKHowToPlayMenuPos action:@selector(startHowTo)];
    
    // クレジットのメニューを作成する
    [self addMenuWithString:kAKCreditCaption atPosition:kAKCreditMenuPos action:@selector(startCredit)];
    
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
    DBGLOG(1, @"startHowTo");
}

/*!
 @brief クレジット画面の開始
 
 クレジット画面を開始する。クレジットシーンへと遷移する。
 */
- (void)startCredit
{
    DBGLOG(1, @"startCredit");
}

/*!
 @brief メニュー項目の追加
 
 メニュー項目のラベルを作成し、インターフェースに項目を追加する。
 @param menuString メニューのキャプション
 @param pos メニューの位置
 @param action メニュー選択時の処理
 */
- (void)addMenuWithString:(NSString *)menuString atPosition:(NSInteger)pos action:(SEL)action
{
    // ラベルを作成する
    AKLabel *label = [AKLabel labelWithString:menuString maxLength:menuString.length maxLine:1];
    
    // ラベルの位置は画面中央とする
    label.position = ccp((kAKScreenSize.width - label.width) / 2, pos);
    
    // ラベルを画面に配置する
    [self addChild:label z:kAKTitleMenuPosZ];
    
    // インターフェースレイヤーを取得する
    AKInterface *interface = (AKInterface *)[self getChildByTag:kAKTitleIntarfeceZ];
    
    // メニュー項目をインターフェースに追加する
    [interface.menuItems addObject:[AKMenuItem itemWithRect:label.rect action:action tag:0]];
}
@end
