/*!
 @file AKMenuItem.h
 @brief メニュー項目クラス
 
 画面入力管理クラスに登録するメニュー項目クラスを定義する。
 */

#import <Foundation/Foundation.h>

// メニュー項目クラス
@interface AKMenuItem : NSObject {
    /// 位置
    CGRect m_pos;
    /// 処理
    SEL m_action;
    /// タグ
    NSInteger m_tag;
}

/// 処理
@property (nonatomic)SEL action;
/// タグ
@property (nonatomic)NSInteger tag;

/// メニュー項目生成
- (id)initWithPos:(CGRect)pos action:(SEL)action tag:(NSInteger)tag;
/// メニュー項目生成のコンビニエンスコンストラクタ
+ (id)itemWithPos:(CGRect)pos action:(SEL)action tag:(NSInteger)tag;
/// 項目選択判定
- (BOOL)isSelectPos:(CGPoint)pos;

@end
