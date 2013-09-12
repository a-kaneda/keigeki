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
 @file AKCreditScene.h
 @brief クレジット画面シーンの定義
 
 クレジット画面のシーンクラスを定義する。
 */

#import "SimpleAudioEngine.h"
#import "AKCreditScene.h"
#import "AKInterface.h"
#import "AKScreenSize.h"
#import "AKCommon.h"
#import "AKTitleScene.h"
#import "AKLabel.h"

/// クレジット画面シーンに配置するノードのタグ
enum {
    kAKCreditSceneBackColor = 0,    ///< 背景色のタグ
    kAKCreditSceneInterface,        ///< インターフェースレイヤーのタグ
    kAKCreditSceneMessage           ///< メッセージレイヤーのタグ
};

/*!
 @brief クレジット画面シーン
 
 クレジット画面シーンを管理するクラス。
 */
@implementation AKCreditScene

/*!
 @brief インスタンス初期化処理
 
 インスタンスの初期化を行う。
 @return 初期化したインスタンス。失敗時はnilを返す。
 */
- (id)init
{
    // スーパークラスの生成処理を実行する
    self = [super init];
    if (!self) {
        return nil;
    }
    
    // 背景色レイヤーを作成する
    CCLayerColor *backColor = AKCreateBackColorLayer();
    
    // シーンへ配置する
    [self addChild:backColor z:kAKCreditSceneBackColor tag:kAKCreditSceneBackColor];
    
    // インターフェースレイヤーの初期化を行う
    [self initInterface];
    
    // メッセージレイヤーの初期化を行う
    [self initMessage];
    
    return self;
}

/*!
 @brief インターフェースレイヤー初期化
 
 インターフェースレイヤーの初期化処理を行う。
 インターフェースレイヤーの生成、戻るボタン、リンクボタンの配置を行う。
 */
- (void)initInterface
{
    // メニュー項目の数
    // 共通:戻る、単一色制作過程、ユウラボ、美咲フォント
    const NSInteger kAKMenuItemCount = 4;
    // 戻るボタンの画像ファイル名
    NSString *kAKBackImage = @"BackButton.png";
    // 戻るボタンの位置、右からの位置
    const float kAKBackPosRightPoint = 26.0f;
    // 戻るボタンの位置、上からの位置
    const float kAKBackPosTopPoint = 26.0f;
    // リンクボタンのキャプション
    NSString *kAKLinkCaption = @"WEB SITE";
    // ボタンの位置、左からの比率
    const float kAKLabelPosLeftRatio = 0.75f;
    // 製作者ボタンの位置、上からの比率
    const float kAKLabel1PosTopRatio = 0.25f;
    // 音楽素材ボタンの位置、上からの比率
    const float kAKLabel2PosTopRatio = 0.5f;
    // フォントボタンの位置、上からの比率
    const float kAKLabel3PosTopRatio = 0.75f;
    
    // インターフェースを作成する
    AKInterface *interface = [AKInterface interfaceWithCapacity:kAKMenuItemCount];
    
    // シーンへ配置する
    [self addChild:interface z:kAKCreditSceneInterface tag:kAKCreditSceneInterface];
    
    // 戻るボタンをインターフェースに配置する
    [interface addMenuWithFile:kAKBackImage
                         atPos:ccp([AKScreenSize positionFromRightPoint:kAKBackPosRightPoint],
                                   [AKScreenSize positionFromTopPoint:kAKBackPosTopPoint])
                        action:@selector(selectBack)
                             z:0
                           tag:0];
    
    // 製作者ボタンをインターフェースに配置する
    [interface addMenuWithString:kAKLinkCaption
                           atPos:ccp([AKScreenSize positionFromLeftRatio:kAKLabelPosLeftRatio],
                                     [AKScreenSize positionFromTopRatio:kAKLabel1PosTopRatio])
                          action:@selector(selectLink1)
                               z:0
                             tag:0
                       withFrame:YES];

    // 音楽素材ボタンをインターフェースに配置する
    [interface addMenuWithString:kAKLinkCaption
                           atPos:ccp([AKScreenSize positionFromLeftRatio:kAKLabelPosLeftRatio],
                                     [AKScreenSize positionFromTopRatio:kAKLabel2PosTopRatio])
                          action:@selector(selectLink2)
                               z:0
                             tag:0
                       withFrame:YES];

    // フォントボタンをインターフェースに配置する
    [interface addMenuWithString:kAKLinkCaption
                           atPos:ccp([AKScreenSize positionFromLeftRatio:kAKLabelPosLeftRatio],
                                     [AKScreenSize positionFromTopRatio:kAKLabel3PosTopRatio])
                          action:@selector(selectLink3)
                               z:0
                             tag:0
                       withFrame:YES];
}

/*!
 @brief メッセージレイヤー初期化
 
 メッセージレイヤーを初期化する。
 メッセージレイヤーを作成し、各Webサイトの説明のラベルを配置する。
 */
- (void)initMessage
{
    // ラベルの位置、左からの比率
    const float kAKLabelPosLeftRatio = 0.1f;
    // 製作者ラベルの位置、上からの比率
    const float kAKLabel1PosTopRatio = 0.25f;
    // 音楽素材ラベルの位置、上からの比率
    const float kAKLabel2PosTopRatio = 0.5f;
    // フォントラベルの位置、上からの比率
    const float kAKLabel3PosTopRatio = 0.75f;
    // 制作者ラベルメッセージのキー
    NSString *kAKMessageKey1 = @"Credit_1";
    // 音楽素材ラベルメッセージのキー
    NSString *kAKMessageKey2 = @"Credit_2";
    // フォントラベルメッセージのキー
    NSString *kAKMessageKey3 = @"Credit_3";
    // メッセージの1行の最大長
    NSInteger kAKMessageLength = 14;
    
    // メッセージレイヤーを作成する
    CCLayer *messageLayer = [CCLayer node];
    
    // シーンへ配置する
    [self addChild:messageLayer z:kAKCreditSceneMessage tag:kAKCreditSceneMessage];
    
    // 製作者ラベルメッセージを作成する
    NSString *message1 = NSLocalizedString(kAKMessageKey1, @"製作者ラベルメッセージ");
    
    // 製作者ラベルを作成する
    AKLabel *label1 = [AKLabel labelWithString:message1 maxLength:kAKMessageLength maxLine:3 frame:kAKLabelFrameNone];
    
    // 製作者ラベルの位置を設定する
    label1.position = ccp([AKScreenSize positionFromLeftRatio:kAKLabelPosLeftRatio] + [label1 width] / 2,
                          [AKScreenSize positionFromTopRatio:kAKLabel1PosTopRatio]);
    
    // 製作者ラベルをメッセージレイヤーへ配置する
    [messageLayer addChild:label1];
    
    // 音楽素材ラベルメッセージを作成する
    NSString *message2 = NSLocalizedString(kAKMessageKey2, @"音楽素材ラベルメッセージ");
    
    // 音楽素材ラベルを作成する
    AKLabel *label2 = [AKLabel labelWithString:message2 maxLength:kAKMessageLength maxLine:3 frame:kAKLabelFrameNone];
    
    // 音楽素材ラベルの位置を設定する
    label2.position = ccp([AKScreenSize positionFromLeftRatio:kAKLabelPosLeftRatio] + [label2 width] / 2,
                          [AKScreenSize positionFromTopRatio:kAKLabel2PosTopRatio]);
    
    // 音楽素材ラベルをメッセージレイヤーへ配置する
    [messageLayer addChild:label2];
    
    // フォントラベルメッセージを作成する
    NSString *message3 = NSLocalizedString(kAKMessageKey3, @"フォントラベルメッセージ");
    
    // フォントラベルを作成する
    AKLabel *label3 = [AKLabel labelWithString:message3 maxLength:kAKMessageLength maxLine:3 frame:kAKLabelFrameNone];
    
    // フォントラベルの位置を設定する
    label3.position = ccp([AKScreenSize positionFromLeftRatio:kAKLabelPosLeftRatio] + [label3 width] / 2,
                          [AKScreenSize positionFromTopRatio:kAKLabel3PosTopRatio]);
    
    // フォントラベルをメッセージレイヤーへ配置する
    [messageLayer addChild:label3];
}

/*!
 @brief 戻るボタン選択時の処理
 
 戻るボタンを選択した時の処理を行う。
 効果音を鳴らし、タイトルシーンへと戻る。
 */
- (void)selectBack
{
    // メニュー選択時の効果音を鳴らす
    [[SimpleAudioEngine sharedEngine] playEffect:kAKMenuSelectSE];
    
    // タイトルシーンへの遷移を作成する
    CCTransitionFade *transition = [CCTransitionFade transitionWithDuration:0.5f scene:[AKTitleScene node]];
    
    // タイトルシーンへ遷移する
    [[CCDirector sharedDirector] replaceScene:transition];
}

/*!
 @brief リンクボタン1選択時の処理
 
 リンクボタン1を選択した時の処理を行う。
 単一色制作過程のサイトを開く。
 */
- (void)selectLink1
{
    // 単一色制作過程のサイトのURL
    NSString *kAKURL = @"http://blog.monochrome-soft.com";
    
    AKLog(1, @"製作者ボタン選択");
    
    // メニュー選択時の効果音を鳴らす
    [[SimpleAudioEngine sharedEngine] playEffect:kAKMenuSelectSE];
    
    // 単一色制作過程のサイトを開く
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kAKURL]];
}

/*!
 @brief リンクボタン2選択時の処理
 
 リンクボタン2を選択した時の処理を行う。
 ユウラボ8bitサウンド工房のサイトを開く。
 */
- (void)selectLink2
{
    // ユウラボ8bitサウンド工房のサイトのURL
    NSString *kAKURL = @"http://www.skipmore.com/sound/";

    AKLog(1, @"音楽素材ボタン選択");
    
    // メニュー選択時の効果音を鳴らす
    [[SimpleAudioEngine sharedEngine] playEffect:kAKMenuSelectSE];

    // ユウラボ8bitサウンド工房のサイトを開く
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kAKURL]];
}

/*!
 @brief リンクボタン3選択時の処理
 
 リンクボタン3を選択した時の処理を行う。
 美咲フォントのサイトを開く。
 */
- (void)selectLink3
{
    // 美咲フォントのサイトのURL
    NSString *kAKURL = @"http://www.geocities.jp/littlimi/misaki.htm";

    AKLog(1, @"フォントボタン選択");
    
    // メニュー選択時の効果音を鳴らす
    [[SimpleAudioEngine sharedEngine] playEffect:kAKMenuSelectSE];

    // 美咲フォントのサイトを開く
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kAKURL]];
}

@end
