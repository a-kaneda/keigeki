/*!
 @file AKTitleLayer.m
 @brief タイトルレイヤークラスの定義
 
 タイトルシーンを管理するクラスを定義する。
 */

#import "AKTitleLayer.h"

/// タイトル画像のファイル名
static NSString *kAKTitleImage = @"Title.png";
/// ゲーム開始メニューのキャプション
static NSString *kAKGameStartCaption = @"GAME START";
/// 遊び方画面メニューのキャプション
static NSString *kAKHowToPlayCaption = @"HOW TO PLAY";
/// クレジット画面メニューのキャプション
static NSString *kAKCreditCaption = @"CREDIT";

/*!
 @brief タイトルレイヤークラス
 
 タイトルシーンを管理する。
 */
@implementation AKTitleLayer

/*!
 @brief オブジェクト生成処理
 
 オブジェクトの生成を行う。
 @return 生成したオブジェクト。失敗時はnilを返す。
 */
- (id)init
{
    // スーパークラスの生成処理
    self = [super init];
    if (!self) {
        return nil;
    }
    
    // タイトル画像を読み込む
    CCSprite *image = [CCSprite spriteWithFile:kAKTitleImage];
    NSAssert(image != nil, @"can not open title image : %@", kAKTitleImage);
    
    return self;
}

/*!
 @brief ゲームの開始
 
 ゲームを開始する。ゲームシーンへと遷移する。
 CCMenu用メソッド。
 @param sender 選択されたメニュー項目
 */
- (void)startGame:(id)sender
{
    
}

/*!
 @brief 遊び方画面の開始
 
 遊び方画面を開始する。遊び方シーンへと遷移する。
 CCMenu用メソッド。
 @param sender 選択されたメニュー項目
 */
- (void)startHowTo:(id)sender
{
    
}

/*!
 @brief クレジット画面の開始
 
 クレジット画面を開始する。クレジットシーンへと遷移する。
 CCMenu用メソッド。
 @param sender 選択されたメニュー項目
 */
- (void)startCredit:(id)sender
{
    
}
@end
