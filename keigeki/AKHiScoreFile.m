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
 @file AKHiScoreFile.m
 @brief ハイスコアファイル管理クラス
 
 ハイスコアのファイル入出力を管理するクラスを定義する。
 */

#import "AKHiScoreFile.h"
#import "AKCommon.h"

/// ファイルバージョン番号
static const NSInteger kAKDataFileVersion = 0x0100;
/// ファイルバージョン番号キー名
static NSString *kAKVersionKey = @"version";
/// ハイスコアキー名
static NSString *kAKHiScoreKey = @"hiScore";

/*!
 @brief ハイスコアファイル管理クラス
 
 ハイスコアのファイル入出力を管理する。
 */
@implementation AKHiScoreFile

@synthesize hiscore = hiScore_;

/*!
 @brief オブジェクト生成処理
 
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
    
    // データを初期化する
    hiScore_ = 0;

    return self;
}

/*!
 @brief アーカイブからの初期化
 
 アーカイバからオブジェクトを復元する。
 @param aDecoder アーカイバ
 */
- (id)initWithCoder:(NSCoder *)aDecoder
{
    // スーパークラスの生成処理を実行する
    self = [super init];
    if (!self) {
        return nil;
    }

    // ハイスコア
    hiScore_ = [aDecoder decodeIntegerForKey:kAKHiScoreKey];
    
    return self;
}

/*!
 @brief アーカイブへの格納
 
 アーカイバへオブジェクトを格納する。
 @param aCoder アーカイバ
 */
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    // バージョン番号
    [aCoder encodeInteger:kAKDataFileVersion forKey:kAKVersionKey];
    
    // ハイスコア
    [aCoder encodeInteger:hiScore_ forKey:kAKHiScoreKey];
}
@end
