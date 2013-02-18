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
    /// 色反転するかどうか
    BOOL isReverse_;
}

/// 表示文字列
@property (nonatomic, retain)NSString *labelString;
/// 色反転するかどうか
@property (nonatomic)BOOL isReverse;

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
