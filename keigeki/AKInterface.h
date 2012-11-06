/*!
 @file AKInterface.h
 @brief 画面入力管理クラス
 
 画面のタッチ入力を管理するクラスを定義する。
 */

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AKMenuItem.h"
#import "AKLabel.h"

// 画面入力管理クラス
@interface AKInterface : CCLayer {
    /// メニュー項目
    NSMutableArray *menuItems_;
    /// 有効タグ
    NSUInteger enableTag_;
}

/// メニュー項目
@property (nonatomic, retain)NSMutableArray *menuItems;
/// 有効タグ
@property (nonatomic)NSUInteger enableTag;

// 項目数を指定した初期化処理
- (id)initWithCapacity:(NSInteger)capacity;
// 項目数を指定したコンビニエンスコンストラクタ
+ (id)interfaceWithCapacity:(NSInteger)capacity;
// 画像ファイルからメニュー項目作成
- (CCSprite *)addMenuWithFile:(NSString *)filename
                        atPos:(CGPoint)pos
                       action:(SEL)action
                            z:(NSInteger)z
                          tag:(NSInteger)tag;
// 文字列からメニュー項目作成
- (AKLabel *)addMenuWithString:(NSString*)menuString
                         atPos:(CGPoint)pos
                        action:(SEL)action
                             z:(NSInteger)z
                           tag:(NSInteger)tag
                     withFrame:(BOOL)withFrame;
// メニュー項目表示非表示設定
- (void)updateVisible;
// メニュー項目個別表示設定
- (void)updateVisibleItem:(CCNode *)item;

@end
