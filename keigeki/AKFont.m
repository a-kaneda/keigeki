/*!
 @file AKFont.m
 @brief フォント管理クラス
 
 フォント情報を管理するクラスを定義する。
 */

#import "AKFont.h"
#import "common.h"

/// フォントサイズ
const NSInteger kAKFontSize = 16;

/// フォント画像のファイル名
static NSString *kAKFontImageName = @"Font.png";
/// フォント中の文字の位置情報のファイル名
static NSString *kAKFontMapName = @"Font";

// シングルトンオブジェクト
static AKFont *g_font;

/*!
 @brief フォント管理クラス
 
 フォントのテクスチャ情報を管理する。
 */
@implementation AKFont

@synthesize fontMap = m_fontMap;
@synthesize fontTexture = m_fontTexture;

/*!
 @brief シングルトンオブジェクト取得
 
 シングルトンオブジェクトを返す。初回呼び出し時はオブジェクトを作成して返す。
 @return シングルトンオブジェクト
 */
+ (AKFont *)sharedInstance
{
    // シングルトンオブジェクトが作成されていない場合は作成する。
    if (g_font == nil) {
        g_font = [[AKFont alloc] init];
    }
    
    // シングルトンオブジェクトを返す。
    return g_font;
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
    assert(self.fontTexture != nil);
    
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
 @return 文字のスプライトフレーム
 */
- (CCSpriteFrame *)spriteFrameOfChar:(unichar)c
{
    DBGLOG(0, @"c=%c rect=(%f,%f)", c, [self rectOfChar:c].origin.x, [self rectOfChar:c].origin.y);
    // フォントのテクスチャから文字の部分を切り出して返す
    return [CCSpriteFrame frameWithTexture:self.fontTexture rect:[self rectOfChar:c]];
}

/*!
 @brief キーからスプライトフレームを取得する
 
 キーからスプライトフレームを取得する。
 @param key キー
 @return キーのスプライトフレーム
 */
- (CCSpriteFrame *)spriteFrameWithKey:(NSString *)key
{
    DBGLOG(0, @"key=%@ rect=(%f,%f)", key, [self rectByKey:key].origin.x, [self rectByKey:key].origin.y);
    // フォントのテクスチャからキーに対応する部分を切り出して返す
    return [CCSpriteFrame frameWithTexture:self.fontTexture rect:[self rectByKey:key]];
}
@end
