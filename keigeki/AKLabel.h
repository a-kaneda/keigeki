/*!
 @file AKLabel.h
 @brief ラベル表示クラス
 
 テキストラベルを表示するクラスを定義する。
 */

#import <Foundation/Foundation.h>
#import "cocos2d.h"

/// ラベルの枠のタイプ
enum AKLabelFrame {
    kAKLabelFrameNone = 0,  ///< 枠なし
    kAKLabelFrameMessage,   ///< メッセージボックス
    kAKLabelFrameButton     ///< ボタン
};

// ラベル表示クラス
@interface AKLabel : CCNode <CCLabelProtocol> {
    /// 表示文字列
    NSString *labelString_;
    /// １行の表示文字数
    NSInteger length_;
    /// 表示行数
    NSInteger line_;
    /// 枠のタイプ
    enum AKLabelFrame frame_;
}

/// 表示文字列
@property (nonatomic, retain)NSString *labelString;

// 指定文字数の幅取得
+ (NSInteger)widthWithLength:(NSInteger)length hasFrame:(BOOL)hasFrame;
// 指定行数の高さ取得
+ (NSInteger)heightWithLine:(NSInteger)line hasFrame:(BOOL)hasFrame;
// 指定文字数、指定行数の指定位置の矩形範囲取得
+ (CGRect)rectWithCenterX:(float)x centerY:(float)y length:(NSInteger)length line:(NSInteger)line hasFrame:(BOOL)hasFrame;
// 初期文字列を指定した初期化
- (id)initWithString:(NSString *)str maxLength:(NSInteger)length maxLine:(NSInteger)line frame:(enum AKLabelFrame)frame;
// 初期文字列を指定したコンビニエンスコンストラクタ
+ (id)labelWithString:(NSString *)str maxLength:(NSInteger)length maxLine:(NSInteger)line frame:(enum AKLabelFrame)frame;
// 枠表示用バッチノード取得
- (CCSpriteBatchNode *)frameBatch;
// 文字表示用バッチノード取得
- (CCSpriteBatchNode *)labelBatch;
// ラベルの幅の取得
- (NSInteger)width;
// ラベルの高さの取得
- (NSInteger)height;
// ラベルの矩形領域の取得
- (CGRect)rect;
// 枠の生成
- (void)createFrame;

@end
