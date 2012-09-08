/*!
 @file AKLabel.h
 @brief ラベル表示クラス
 
 テキストラベルを表示するクラスを定義する。
 */

#import <Foundation/Foundation.h>
#import "cocos2d.h"

// ラベル表示クラス
@interface AKLabel : CCNode <CCLabelProtocol> {
    /// 文字表示用バッチノード
    CCSpriteBatchNode *m_batch;
    /// 表示文字列
    NSString *m_labelString;
    /// １行の表示文字数
    NSInteger m_length;
    /// 表示行数
    NSInteger m_line;
}

/// 文字表示用バッチノード
@property (nonatomic, retain)CCSpriteBatchNode *batch;
/// 表示文字列
@property (nonatomic, retain)NSString *labelString;

// 初期文字列を指定した初期化
- (id)initWithString:(NSString *)str maxLength:(NSInteger)length maxLine:(NSInteger)line;
// 初期文字列を指定したコンビニエンスコンストラクタ
+ (id)labelWithString:(NSString *)str maxLength:(NSInteger)length maxLine:(NSInteger)line;
// ラベルの幅の取得
- (NSInteger)width;
// ラベルの矩形領域の取得
- (CGRect)rect;

@end
