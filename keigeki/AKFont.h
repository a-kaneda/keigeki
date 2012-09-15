/*!
 @file AKFont.h
 @brief フォント管理クラス
 
 フォント情報を管理するクラスを定義する。
 */

#import <Foundation/Foundation.h>
#import "cocos2d.h"

// フォントサイズ
extern const NSInteger kAKFontSize;

// フォント管理クラス
@interface AKFont : NSObject {
    /// 文字のテクスチャ内の位置情報
    NSDictionary *m_fontMap;
    /// フォントテクスチャ
    CCTexture2D *m_fontTexture;
}

/// 文字のテクスチャ内の位置情報
@property (nonatomic, retain)NSDictionary *fontMap;
/// フォントテクスチャ
@property (nonatomic, retain)CCTexture2D *fontTexture;

// シングルトンオブジェクトの取得
+ (AKFont *)sharedInstance;
// 文字のテクスチャ内の位置を取得する
- (CGRect)rectOfChar:(unichar)c;
// キーからテクスチャ内の位置を取得する
- (CGRect)rectByKey:(NSString *)key;
// 文字のスプライトフレームを取得する
- (CCSpriteFrame *)spriteFrameOfChar:(unichar)c;
// キーからスプライトフレームを取得する
- (CCSpriteFrame *)spriteFrameWithKey:(NSString *)key;
@end
