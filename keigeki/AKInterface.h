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
    NSMutableArray *menuItems_;
    /// 有効化するタグ開始番号
    NSInteger enableItemTagStart_;
    /// 有効化するタグ終了番号
    NSInteger enableItemTagEnd_;
}

/// メニュー項目
@property (nonatomic, retain)NSMutableArray *menuItems;
/// 有効化するタグ
@property (nonatomic)NSInteger enableItemTag;
/// 有効化するタグ開始番号
@property (nonatomic)NSInteger enableItemTagStart;
/// 有効化するタグ終了番号
@property (nonatomic)NSInteger enableItemTagEnd;

// 項目数を指定した初期化処理
- (id)initWithCapacity:(NSInteger)capacity;
// 項目数を指定したコンビニエンスコンストラクタ
+ (id)interfaceWithCapacity:(NSInteger)capacity;
// 画像ファイルからメニュー項目作成
- (void)addMenuWithFile:(NSString *)filename
                  atPos:(CGPoint)pos
                 action:(SEL)action
                      z:(NSInteger)z
                    tag:(NSInteger)tag;
// 文字列からメニュー項目作成
- (void)addMenuWithString:(NSString*)menuString
                    atPos:(CGPoint)pos
                   action:(SEL)action
                        z:(NSInteger)z
                      tag:(NSInteger)tag
                withFrame:(BOOL)withFrame;

@end
