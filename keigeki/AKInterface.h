/*!
 @file AKInterface.h
 @brief 画面入力管理クラス
 
 画面のタッチ入力を管理するクラスを定義する。
 */

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AKMenuItem.h"

// 画面入力管理クラス
@interface AKInterface : CCLayer {
    /// メニュー項目
    NSMutableArray *m_menuItems;
    /// 有効化するタグ
    NSInteger m_enableItemTag;
}

/// メニュー項目
@property (nonatomic, retain)NSMutableArray *menuItems;
/// 有効化するタグ
@property (nonatomic)NSInteger enableItemTag;

@end
