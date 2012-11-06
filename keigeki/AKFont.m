/*!
 @file AKFont.m
 @brief フォント管理クラス
 
 フォント情報を管理するクラスを定義する。
 */

#import "AKFont.h"
#import "AKCommon.h"

/// フォントサイズ
const NSInteger kAKFontSize = 16;

/// フォント画像のファイル名
static NSString *kAKFontImageName = @"Font.png";
/// フォント中の文字の位置情報のファイル名
static NSString *kAKFontMapName = @"Font";
/// 色反転フォントの位置のキー
static NSString *kAKReversePosKey = @"Reverse";

// シングルトンオブジェクト
static AKFont *sharedInstance_;

/*!
 @brief フォント管理クラス
 
 フォントのテクスチャ情報を管理する。
 */
@implementation AKFont

@synthesize fontMap = fontMap_;
@synthesize fontTexture = fontTexture_;

/*!
 @brief シングルトンオブジェクト取得
 
 シングルトンオブジェクトを返す。初回呼び出し時はオブジェクトを作成して返す。
 @return シングルトンオブジェクト
 */
+ (AKFont *)sharedInstance
{
    // シングルトンオブジェクトが作成されていない場合は作成する。
    if (sharedInstance_ == nil) {
        sharedInstance_ = [[AKFont alloc] init];
    }
    
    // シングルトンオブジェクトを返す。
    return sharedInstance_;
}

/*!
 @method オブジェクト生成処理
 
 オブジェクトの生成を行う。
 @return 生成したオブジェクト。失敗時はnilを返す。
 */
- (id)init
{
    // スーパークラスの生成処理を実行する
    self = [super init];
    if (!self) {
        return nil;
    }
    
    // フォント画像を読み込む
    self.fontTexture = [[CCTextureCache sharedTextureCache] addImage:kAKFontImageName];
    NSAssert(self.fontTexture != nil, @"フォント画像の読み込みに失敗");
    
    // ファイルパスをバンドルから取得する
    NSString *filePath = [[NSBundle mainBundle] pathForResource:kAKFontMapName ofType:@"plist"];
    
    // 文字の位置情報を読み込む
    self.fontMap = [NSDictionary dictionaryWithContentsOfFile:filePath];
    assert(self.fontMap != nil);
    
    return self;
}

/*!
 @brief インスタンス解放時処理
 
 インスタンス解放時にオブジェクトを解放する。
 */
- (void)dealloc
{
    // メンバを解放する
    self.fontMap = nil;
    self.fontTexture = nil;
    
    // スーパークラスの解放処理を実行する
    [super dealloc];
}

/*!
 @brief 文字のテクスチャ内の位置を取得する
 
 文字のテクスチャ内の位置を取得する。
 @param c 文字
 @return テクスチャ内の位置
 */
- (CGRect)rectOfChar:(unichar)c
{
    // NSDictionaryのキーに使用するため、unicharからNSStringを生成する
    return [self rectByKey:[NSString stringWithCharacters:&c length:1]];
}

/*!
 @brief キーからテクスチャ内の位置を取得する
 
 キーからテクスチャ内の位置を取得する。
 @param key キー
 @return テクスチャ内の位置
 */
- (CGRect)rectByKey:(NSString *)key
{
    // 文字の位置情報を文字全体の情報から検索する
    NSDictionary *charInfo = [self.fontMap objectForKey:key];
    
    // 見つからない場合は一番左上のダミー文字を返す
    if (charInfo == nil) {
        return CGRectMake(0, 0, kAKFontSize, kAKFontSize);
    }
    
    // 位置情報を取得する
    NSNumber *x = [charInfo objectForKey:@"x"];
    NSNumber *y = [charInfo objectForKey:@"y"];
    
    // 位置情報から矩形座標を作成する
    CGRect rect = CGRectMake([x integerValue] * kAKFontSize,
                             [y integerValue] * kAKFontSize,
                             kAKFontSize, kAKFontSize);
    return rect;
}

/*!
 @brief 文字のスプライトフレームを取得する
 
 文字のスプライトフレームを取得する。
 @param c 文字
 @param isReverse 色反転するかどうか
 @return 文字のスプライトフレーム
 */
- (CCSpriteFrame *)spriteFrameOfChar:(unichar)c isReverse:(BOOL)isReverse
{
    AKLog(0, @"c=%c rect=(%f,%f) isReverse=%d", c, [self rectOfChar:c].origin.x, [self rectOfChar:c].origin.y, isReverse);
    
    // 文字の座標を取得する
    CGRect charRect = [self rectOfChar:c];
    
    // 色反転する場合は色反転の座標をプラスする
    if (isReverse) {
        CGRect reverseRect = [self rectByKey:kAKReversePosKey];
        
        charRect.origin.x += reverseRect.origin.x;
        charRect.origin.y += reverseRect.origin.y;
    }
    
    // フォントのテクスチャから文字の部分を切り出して返す
    return [CCSpriteFrame frameWithTexture:self.fontTexture rect:charRect];
}

/*!
 @brief キーからスプライトフレームを取得する
 
 キーからスプライトフレームを取得する。
 @param key キー
 @param isReverse 色反転するかどうか
 @return キーのスプライトフレーム
 */
- (CCSpriteFrame *)spriteFrameWithKey:(NSString *)key isReverse:(BOOL)isReverse
{
    AKLog(0, @"key=%@ rect=(%f,%f) isReverse=%d", key, [self rectByKey:key].origin.x, [self rectByKey:key].origin.y, isReverse);
    
    // 文字の座標を取得する
    CGRect charRect = [self rectByKey:key];
    
    // 色反転する場合は色反転の座標をプラスする
    if (isReverse) {
        CGRect reverseRect = [self rectByKey:kAKReversePosKey];
        
        charRect.origin.x += reverseRect.origin.x;
        charRect.origin.y += reverseRect.origin.y;
    }

    // フォントのテクスチャからキーに対応する部分を切り出して返す
    return [CCSpriteFrame frameWithTexture:self.fontTexture rect:charRect];
}
@end
