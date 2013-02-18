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
 @file AKInterface.h
 @brief 画面入力管理クラス
 
 画面のタッチ入力を管理するクラスを定義する。
 */

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AKMenuItem.h"
#import "AKLabel.h"

// 画面入力管理クラス
@interface AKInterface : CCLayer {
    /// メニュー項目
    NSMutableArray *menuItems_;
    /// 有効タグ
    NSUInteger enableTag_;
}

/// メニュー項目
@property (nonatomic, retain)NSMutableArray *menuItems;
/// 有効タグ
@property (nonatomic)NSUInteger enableTag;

// 項目数を指定した初期化処理
- (id)initWithCapacity:(NSInteger)capacity;
// 項目数を指定したコンビニエンスコンストラクタ
+ (id)interfaceWithCapacity:(NSInteger)capacity;
// 画像ファイルからメニュー項目作成
- (CCSprite *)addMenuWithFile:(NSString *)filename
                        atPos:(CGPoint)pos
                       action:(SEL)action
                            z:(NSInteger)z
                          tag:(NSInteger)tag;
// 文字列からメニュー項目作成
- (AKLabel *)addMenuWithString:(NSString*)menuString
                         atPos:(CGPoint)pos
                        action:(SEL)action
                             z:(NSInteger)z
                           tag:(NSInteger)tag
                     withFrame:(BOOL)withFrame;
// メニュー項目表示非表示設定
- (void)updateVisible;
// メニュー項目個別表示設定
- (void)updateVisibleItem:(CCNode *)item;

@end
