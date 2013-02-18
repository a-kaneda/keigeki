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
 @file AKMenuItem.m
 @brief メニュー項目クラス
 
 画面入力管理クラスに登録するメニュー項目クラスを定義する。
 */

#import "AKMenuItem.h"
#import "AKCommon.h"

/*!
 @brief メニュー項目クラス
 
 画面入力管理クラスに登録するメニュー項目。
 メニューの位置、大きさ、処理を管理する。
 */
@implementation AKMenuItem

@synthesize action = action_;
@synthesize tag = tag_;

/*!
 @brief 矩形指定のメニュー項目生成
 
 矩形を指定してメニュー項目の生成を行う。
 @param rect 位置と大きさ
 @param action 項目処理時の処理
 @param tag タグ情報(任意に使用)
 @return 生成したオブジェクト。失敗時はnilを返す。
 */
- (id)initWithRect:(CGRect)rect action:(SEL)action tag:(NSInteger)tag
{
    // スーパークラスの生成処理
    self = [super init];
    if (!self) {
        return nil;
    }
    
    AKLog(0, "rect = (%f, %f, %f, %f)", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
    
    // 引数をメンバに設定する
    pos_ = rect;
    action_ = action;
    tag_ = tag;
    
    return self;
}

/*!
 @brief 座標指定のメニュー項目生成
 
 中心座標と矩形の1辺のサイズを指定してメニュー項目の生成を行う。
 @param point 中心座標
 @param size 矩形の1辺のサイズ
 @param action 項目処理時の処理
 @param tag タグ情報(任意に使用)
 @return 生成したオブジェクト。失敗時はnilを返す。
 */
- (id)initWithPoint:(CGPoint)point size:(NSInteger)size action:(SEL)action tag:(NSInteger)tag
{
    // スーパークラスの生成処理
    self = [super init];
    if (!self) {
        return nil;
    }
    
    // 引数をメンバに設定する
    pos_ = AKMakeRectFromCenter(point, size);
    action_ = action;
    tag_ = tag;
    
    return self;
}

/*!
 @brief 矩形指定のメニュー項目生成のコンビニエンスコンストラクタ
 
 矩形を指定してメニュー項目の生成を行う。
 @param rect 位置と大きさ
 @param action 項目処理時の処理
 @param tag タグ情報(任意に使用)
 @return 生成したオブジェクト。失敗時はnilを返す。
 */
+ (id)itemWithRect:(CGRect)rect action:(SEL)action tag:(NSInteger)tag
{
    return [[[[self class] alloc] initWithRect:rect action:action tag:tag] autorelease];
}

/*!
 @brief 座標指定のメニュー項目生成のコンビニエンスコンストラクタ
 
 中心座標と矩形の1辺のサイズを指定してメニュー項目の生成を行う。
 @param point 中心座標
 @param size 矩形の1辺のサイズ
 @param action 項目処理時の処理
 @param tag タグ情報(任意に使用)
 @return 生成したオブジェクト。失敗時はnilを返す。
 */
+ (id)itemWithPoint:(CGPoint)point size:(NSInteger)size action:(SEL)action tag:(NSInteger)tag
{
    return [[[[self class] alloc] initWithPoint:point size:size action:action tag:tag] autorelease];
}

/*!
 @brief 項目選択判定
 
 座標がメニュー項目の範囲内かどうかを判定する。
 @param pos 選択位置
 @return メニュー項目の範囲内かどうかを
 */
- (BOOL)isSelectPos:(CGPoint)pos
{
    // 座標がメニュー項目の範囲内の場合は処理を行う
    return AKIsInside(pos, pos_);
}

@end
