/*!
 @file AKCreditScene.h
 @brief クレジット画面シーンの定義
 
 クレジット画面のシーンクラスを定義する。
 */

#import <Foundation/Foundation.h>
#import "cocos2d.h"


// クレジット画面シーン
@interface AKCreditScene : CCScene {
    
}

// インターフェースレイヤー初期化
- (void)initInterface;
// メッセージレイヤー初期化
- (void)initMessage;
// 戻るボタン選択時の処理
- (void)selectBack;
// リンクボタン1選択時の処理
- (void)selectLink1;
// リンクボタン2選択時の処理
- (void)selectLink2;
// リンクボタン3選択時の処理
- (void)selectLink3;

@end
