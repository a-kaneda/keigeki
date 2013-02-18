/*
 * Copyright (c) 2012-2013 Akihiro Kaneda.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *   1.Redistributions of source code must retain the above copyright notice,
 *     this list of conditions and the following disclaimer.
 *   2.Redistributions in binary form must reproduce the above copyright notice,
 *     this list of conditions and the following disclaimer in the documentation
 *     and/or other materials provided with the distribution.
 *   3.Neither the name of the Monochrome Soft nor the names of its contributors
 *     may be used to endorse or promote products derived from this software
 *     without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */
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
 @brief フォントサイズ取得
 
 フォントサイズを取得する。
 iPadの場合は倍のサイズを返す。
 @return フォントサイズ
 */
+ (NSInteger)fontSize
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return kAKFontSize * 2;
    }
    else {
        return kAKFontSize;
    }
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
    
    // iPadの場合は文字サイズを倍にする
    NSInteger fontSize = kAKFontSize;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        fontSize *= 2;
    }
    
    // 見つからない場合は一番左上のダミー文字を返す
    if (charInfo == nil) {
        return CGRectMake(0, 0, fontSize, fontSize);
    }
    
    // 位置情報を取得する
    NSNumber *xobj = [charInfo objectForKey:@"x"];
    NSNumber *yobj = [charInfo objectForKey:@"y"];
    
    // オブジェクトから数値に変換する
    NSInteger xValue = [xobj integerValue];
    NSInteger yValue = [yobj integerValue];
        
    // 位置情報から矩形座標を作成する
    CGRect rect = CGRectMake(xValue * fontSize,
                             yValue * fontSize,
                             fontSize, fontSize);
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
