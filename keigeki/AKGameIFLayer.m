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
 @file AKGameIFLayer.m
 @brief ゲームプレイ画面インターフェース定義
 
 ゲームプレイ画面のインターフェースを管理するを定義する。
 */

#import "AKGameIFLayer.h"
#import "AKGameScene.h"
#import "AKCommon.h"
#import "AKTwitterHelper.h"
#import "AKScreenSize.h"
#import "AKInAppPurchaseHelper.h"

/// ゲームプレイ中のタグ
NSUInteger kAKGameIFTagPlaying = 0x01;
/// 一時停止中のタグ
NSUInteger kAKGameIFTagPause = 0x02;
/// 終了メニュー表示中のタグ
NSUInteger kAKGameIFTagQuit = 0x04;
/// ゲームオーバー時のタグ
NSUInteger kAKGameIFTagGameOver = 0x08;
/// ゲームクリア時のタグ
NSUInteger kAKGameIFTagGameClear = 0x10;
/// リザルト表示時のタグ
NSUInteger kAKGameIFTagResult = 0x20;
/// 待機中のタグ
NSUInteger kAKGameIFTagWait = 0x80;

// 加速度センサーの値を比率換算する
static float AKAccel2Ratio(float accel);

/*!
 @brief ゲームプレイ画面インターフェースクラス
 
 ゲームプレイ画面のインターフェースを管理する。
 */
@implementation AKGameIFLayer

@synthesize resumeButton = resumeButton_;
@synthesize quitButton = quitButton_;
@synthesize quitNoButton = quitNoButton_;

/*!
 @brief 項目数を指定した初期化処理
 
 メニュー項目数を指定した初期化処理。
 @return 初期化したオブジェクト。失敗時はnilを返す。
 */
- (id)initWithCapacity:(NSInteger)capacity
{
    // スーパークラスの初期化処理を実行する
    self = [super initWithCapacity:capacity];
    if (!self) {
        return nil;
    }
    
    // 加速度センサーを有効にする
    self.isAccelerometerEnabled = YES;
    
    // ゲームプレイ中のメニュー項目を作成する
    [self createPlayingMenu];
    
    // ポーズ時のメニュー項目を作成する
    [self createPauseMenu];
    
    // 終了メニューを作成する
    [self createQuitMenu];
    
    // ゲームオーバー時のメニュー項目を作成する
    [self createGameOverMenu];
    
    // ゲームクリア時のメニュー項目を作成する
    [self createGameClearMenu];
    
    // リザルト表示時のメニュー項目を作成する
    [self createResultMenu];
    
    return self;
}

/*!
 @brief インスタンス解放処理
 
 インスタンス解放時の処理を行う。
 メンバの解放を行う。
 */
- (void)dealloc
{
    // メンバを解放する
    self.resumeButton = nil;
    self.quitButton = nil;
    self.quitNoButton = nil;
    
    // スーパークラスの処理を実行する
    [super dealloc];
}

/*!
 @brief ゲームプレイ中のメニュー項目作成
 
 ゲームプレイ中のメニュー項目を作成する。
 */
- (void)createPlayingMenu
{
    // ショットボタンの画像ファイル名
    NSString *kAKShotButtonImageFile = @"ShotButton.png";
    // ポーズボタンの画像ファイル名
    NSString *kAKPauseButtonImageFile = @"PauseButton.png";
    // ショットボタンの配置位置、右からの位置
    const float kAKShotButtonPosRightPoint = 50.0f;
    // ショットボタンの配置位置、下からの位置
    const float kAKShotButtonPosBottomPoint = 50.0f;
    // ポーズボタンの配置位置、右からの位置
    const float kAKPauseButtonPosRightPoint = 26.0f;
    // ポーズボタンの配置位置、上からの位置
    const float kAKPauseButtonPosTopPoint = 34.0f;

    // ショットボタンを追加する
    [self addMenuWithFile:kAKShotButtonImageFile
                    atPos:ccp([AKScreenSize positionFromRightPoint:kAKShotButtonPosRightPoint],
                              [AKScreenSize positionFromBottomPoint:kAKShotButtonPosBottomPoint])
                   action:@selector(firePlayerShot)
                        z:0
                      tag:kAKGameIFTagPlaying];
    
    // ポーズボタンを追加する
    [self addMenuWithFile:kAKPauseButtonImageFile
                    atPos:ccp([AKScreenSize positionFromRightPoint:kAKPauseButtonPosRightPoint],
                              [AKScreenSize positionFromTopPoint:kAKPauseButtonPosTopPoint])
                   action:@selector(pause)
                        z:0
                      tag:kAKGameIFTagPlaying];
}

/*!
 @brief ポーズ時のメニュー項目作成
 
 ポーズ時のメニュー項目を作成する。
 */
- (void)createPauseMenu
{
    // 一時停止中の表示文字列
    NSString *kAKPauseString = @"  PAUSE  ";
    // 一時停止解除のボタンの文字列
    NSString *kAKResumeString = @"RESUME";
    // 終了ボタンの文字列
    NSString *kAKQuitButtonString = @" QUIT ";
    /// 一時停止メッセージの表示位置、下からの比率
    const float kAKPauseMessagePosBottomRatio = 0.6f;
    /// 一時停止メニュー項目の表示位置、下からの比率
    const float kAKPauseMenuPosBottomRatio = 0.4f;
    /// レジュームボタンの表示位置、左からの比率
    const float kAKResumeButtonPosLeftRatio = 0.3f;
    /// 終了ボタンの表示位置、右からの比率
    const float kAKQuitButtonPosRightRatio = 0.3f;
    
    // ゲームオーバーラベルを生成する
    AKLabel *label = [AKLabel labelWithString:kAKPauseString maxLength:kAKPauseString.length maxLine:1 frame:kAKLabelFrameMessage];
    
    // ゲームオーバーラベルの位置を設定する
    label.position = ccp([AKScreenSize center].x, [AKScreenSize positionFromBottomRatio:kAKPauseMessagePosBottomRatio]);
    
    // ゲームオーバーラベルをレイヤーに配置する
    [self addChild:label z:0 tag:kAKGameIFTagPause];

    // ポーズ解除ボタンを作成する
    self.resumeButton = [self addMenuWithString:kAKResumeString
                                          atPos:ccp([AKScreenSize positionFromLeftRatio:kAKResumeButtonPosLeftRatio],
                                                    [AKScreenSize positionFromBottomRatio:kAKPauseMenuPosBottomRatio])
                                         action:@selector(selectResumeButton)
                                              z:0
                                            tag:kAKGameIFTagPause
                                      withFrame:YES];
    
    
    // 終了ボタンを作成する
    self.quitButton = [self addMenuWithString:kAKQuitButtonString
                                        atPos:ccp([AKScreenSize positionFromRightRatio:kAKQuitButtonPosRightRatio],
                                                  [AKScreenSize positionFromBottomRatio:kAKPauseMenuPosBottomRatio])
                                       action:@selector(selectQuitButton)
                                            z:0
                                          tag:kAKGameIFTagPause
                                    withFrame:YES];
}

/*!
 @brief 終了メニュー項目作成
 
 終了メニューを作成する。
 */
- (void)createQuitMenu
{
    // 終了確認メッセージ
    NSString *kAKQuitMessageString = @"QUIT GAME?";
    // YESボタンの文字列
    NSString *kAKQuitYesString = @" YES ";
    // NOボタンの文字列
    NSString *kAKQuitNoString = @" N O ";
    // 終了メニューキャプションの表示位置、下からの比率
    const float kAKQuitMessagePosBottomRatio = 0.6f;
    // 終了メニューボタンの表示位置、下からの比率
    const float kAKQuitButtonPosBottomRatio = 0.4f;
    // 終了メニューYESボタンの表示位置、左からの比率
    const float kAKQuitYesButtonPosLeftRatio = 0.3f;
    // 終了メニューNOボタンの表示位置、右からの比率
    const float kAKQuitNoButtonPosRightRatio = 0.3f;
    
    // 終了確認メッセージラベルを生成する
    AKLabel *label = [AKLabel labelWithString:kAKQuitMessageString maxLength:kAKQuitMessageString.length maxLine:1 frame:kAKLabelFrameMessage];
    
    // 終了確認メッセージラベルの位置を設定する
    label.position = ccp([AKScreenSize center].x, [AKScreenSize positionFromBottomRatio:kAKQuitMessagePosBottomRatio]);
    
    // 終了確認メッセージラベルをレイヤーに配置する
    [self addChild:label z:0 tag:kAKGameIFTagQuit];
    
    // YESボタンを作成する
    [self addMenuWithString:kAKQuitYesString
                      atPos:ccp([AKScreenSize positionFromLeftRatio:kAKQuitYesButtonPosLeftRatio],
                                [AKScreenSize positionFromBottomRatio:kAKQuitButtonPosBottomRatio])
                     action:@selector(execQuitMenu)
                          z:0
                        tag:kAKGameIFTagQuit
                  withFrame:YES];
    
    
    // NOボタンを作成する
    quitNoButton_ = [self addMenuWithString:kAKQuitNoString
                                      atPos:ccp([AKScreenSize positionFromRightRatio:kAKQuitNoButtonPosRightRatio],
                                                [AKScreenSize positionFromBottomRatio:kAKQuitButtonPosBottomRatio])
                                     action:@selector(selectQuitNoButton)
                                          z:0
                                        tag:kAKGameIFTagQuit
                                  withFrame:YES];
}

/*!
 @brief ゲームオーバー時のメニュー項目作成
 
 ゲームオーバー時のメニュー項目を作成する。
 */
- (void)createGameOverMenu
{
    // ゲームオーバー時の表示文字列
    NSString *kAKGameOverString = @"GAME OVER";
    // タイトルへ戻るボタンのキャプション
    NSString *kAKGameOverQuitButtonCaption = @"QUIT";
    // コンティニューボタンのキャプション
    NSString *kAKGameOverContinueButtonCaption = @"RETRY";
    // Twitterボタンの画像ファイル名
    NSString *kAKTwitterButtonImageFile = @"Twitter.png";
    // ゲームオーバーキャプションの表示位置、下からの比率
    const float kAKGameOverCaptionPosBottomRatio = 0.6f;
    // タイトルへ戻るボタンの位置、下からの比率
    const float kAKGameOverQuitButtonPosBottomRatio = 0.4f;
    // タイトルへ戻るボタンの位置、左からの比率
    const float kAKGameOverQuitButtonPosLeftRatio = 0.3f;
    // コンティニューボタンの位置、右からの比率
    const float kAKGameOverContinueButtonPosRightRatio = 0.3f;
    // Twitterボタンの配置位置、中心からの横方向の位置
    const float kAKTwitterButtonPosHorizontalCenterPoint = 120.0f;
    // Twitterボタンの配置位置、下からの位置
    const float kAKTwitterButtonPosBottomRatio = 0.6f;
    
    // ゲームオーバーラベルを生成する
    AKLabel *label = [AKLabel labelWithString:kAKGameOverString maxLength:kAKGameOverString.length maxLine:1 frame:kAKLabelFrameMessage];
        
    // ゲームオーバーラベルの位置を設定する
    label.position = ccp([AKScreenSize center].x, [AKScreenSize positionFromBottomRatio:kAKGameOverCaptionPosBottomRatio]);
        
    // ゲームオーバーラベルをレイヤーに配置する
    [self addChild:label z:0 tag:kAKGameIFTagGameOver];
    
    // タイトルへ戻るボタンの位置を設定する
    float quitButtonPos = [AKScreenSize center].x;
    
    // コンティニュー機能が有効な場合はタイトルへ戻るボタンを左にずらす
    if ([AKInAppPurchaseHelper sharedHelper].isEnableContinue) {
        quitButtonPos = [AKScreenSize positionFromLeftRatio:kAKGameOverQuitButtonPosLeftRatio];
    }
    
    // タイトルへ戻るボタンを作成する
    [self addMenuWithString:kAKGameOverQuitButtonCaption
                      atPos:ccp(quitButtonPos,
                                [AKScreenSize positionFromBottomRatio:kAKGameOverQuitButtonPosBottomRatio])
                     action:@selector(execQuitMenu)
                          z:0
                        tag:kAKGameIFTagGameOver
                  withFrame:YES];
    
    AKLog(1, @"コンティニュー機能:%d", [AKInAppPurchaseHelper sharedHelper].isEnableContinue);
    
    // コンティニュー機能が有効な場合はコンティニューボタンを作成する
    if ([AKInAppPurchaseHelper sharedHelper].isEnableContinue) {

        [self addMenuWithString:kAKGameOverContinueButtonCaption
                          atPos:ccp([AKScreenSize positionFromRightRatio:kAKGameOverContinueButtonPosRightRatio],
                                    [AKScreenSize positionFromBottomRatio:kAKGameOverQuitButtonPosBottomRatio])
                         action:@selector(selectContinueButton)
                              z:0
                            tag:kAKGameIFTagGameOver
                      withFrame:YES];
    }
    
    // Twitter設定が手動の場合はTwitterボタンを作成する
    if ([AKTwitterHelper sharedHelper].mode == kAKTwitterModeManual) {

        [self addMenuWithFile:kAKTwitterButtonImageFile
                        atPos:ccp([AKScreenSize positionFromHorizontalCenterPoint:kAKTwitterButtonPosHorizontalCenterPoint],
                                  [AKScreenSize positionFromBottomRatio:kAKTwitterButtonPosBottomRatio])
                       action:@selector(selectTweetButton)
                            z:0
                          tag:kAKGameIFTagGameOver];
    }
}

/*!
 @brief ゲームクリア時のメニュー項目作成
 
 ゲームクリア時のメニュー項目を作成する。
 */
- (void)createGameClearMenu
{
    // ゲームクリア時の表示文字列1
    NSString *kAKGameClearCaption1 = @"CONGRATULATIONS!!";
    // ゲームクリア時の表示文字列2
    NSString *kAKGameClearCaption2 = @"ALL STAGE CLEAR";
    // タイトルへ戻るボタンのキャプション
    NSString *kAKGameOverQuitButtonCaption = @"BACK TO TITLE";
    // Twitterボタンの画像ファイル名
    NSString *kAKTwitterButtonImageFile = @"Twitter.png";
    // ゲームクリア時の表示文字列1の表示位置、下からの比率
    const float kAKGameClearCaption1PosBottomRatio = 0.7f;
    // ゲームクリア時の表示文字列2の表示位置、下からの比率
    const float kAKGameClearCaption2PosBottomRatio = 0.6f;
    // タイトルへ戻るボタンの位置、下からの比率
    const float kAKGameOverQuitButtonPosBottomRatio = 0.4f;
    // Twitterボタンの配置位置、中心からの横方向の位置
    const float kAKTwitterButtonPosHorizontalCenterPoint = 150.0f;
    
    // ゲームクリア時の表示文字列1のラベルを作成する
    AKLabel *label1 = [AKLabel labelWithString:kAKGameClearCaption1 maxLength:kAKGameClearCaption1.length maxLine:1 frame:kAKLabelFrameNone];
    
    // ゲームクリア時の表示文字列1の位置を設定する
    label1.position = ccp([AKScreenSize center].x, [AKScreenSize positionFromBottomRatio:kAKGameClearCaption1PosBottomRatio]);
    
    // ゲームクリア時の表示文字列1をレイヤーに配置する
    [self addChild:label1 z:0 tag:kAKGameIFTagGameClear];

    // ゲームクリア時の表示文字列2のラベルを作成する
    AKLabel *label2 = [AKLabel labelWithString:kAKGameClearCaption2 maxLength:kAKGameClearCaption2.length maxLine:1 frame:kAKLabelFrameNone];
        
    // ゲームクリア時の表示文字列2の位置を設定する
    label2.position = ccp([AKScreenSize center].x, [AKScreenSize positionFromBottomRatio:kAKGameClearCaption2PosBottomRatio]);
        
    // ゲームクリア時の表示文字列2をレイヤーに配置する
    [self addChild:label2 z:0 tag:kAKGameIFTagGameClear];
    
    // タイトルへ戻るボタンを作成する
    [self addMenuWithString:kAKGameOverQuitButtonCaption
                      atPos:ccp([AKScreenSize center].x,
                                [AKScreenSize positionFromBottomRatio:kAKGameOverQuitButtonPosBottomRatio])
                     action:@selector(execQuitMenu)
                          z:0
                        tag:kAKGameIFTagGameClear
                  withFrame:YES];
        
    // Twitter設定が手動の場合はTwitterボタンを作成する
    if ([AKTwitterHelper sharedHelper].mode == kAKTwitterModeManual) {
        
        [self addMenuWithFile:kAKTwitterButtonImageFile
                        atPos:ccp([AKScreenSize positionFromHorizontalCenterPoint:kAKTwitterButtonPosHorizontalCenterPoint],
                                  [AKScreenSize positionFromBottomRatio:kAKGameOverQuitButtonPosBottomRatio])
                       action:@selector(selectTweetButton)
                            z:0
                          tag:kAKGameIFTagGameClear];
    }
}

/*!
 @brief リザルト表示時のメニュー項目作成
 
 リザルト表示時のメニュー項目を作成する。
 */
- (void)createResultMenu
{
    // 画面全体をリザルトスキップボタンとする
    CGRect rect = CGRectMake(0, 0, [AKScreenSize screenSize].width, [AKScreenSize screenSize].height);
    [self.menuItems addObject:[AKMenuItem itemWithRect:rect
                                                action:@selector(skipResult)
                                                   tag:kAKGameIFTagResult]];
}

/*!
 @brief メニュー項目表示非表示設定
 
 メニュー項目の表示非表示を有効化タグ範囲をもとに設定する。
 有効化タグ範囲内の項目は表示、範囲外の項目は非表示とする。
 待機処理中は表示内容を保持するためにスーパークラスの処理を抑止する。
 */
- (void)updateVisible;
{
    // 待機中以外の場合はスーパークラスの処理を実行する
    if (self.enableTag != kAKGameIFTagWait) {
        [super updateVisible];
    }
}

/*!
 @brief メニュー項目個別表示設定
 
 メニュー項目の表示非表示を有効タグとは別に設定したい場合に個別に設定を行う。
 プレイ中の項目はゲームクリア時、リザルト表示時以外の場合に表示する。
 @param item 設定するメニュー項目
 */
- (void)updateVisibleItem:(CCNode *)item
{
    // プレイ中の項目はゲームクリア時、リザルト表示時以外の場合に表示する。
    if (item.tag == kAKGameIFTagPlaying && (self.enableTag != kAKGameIFTagGameClear && self.enableTag != kAKGameIFTagResult)) {
        item.visible = YES;
    }
}

/*!
 @brief 加速度情報受信処理

 加速度センサーの情報を受信する。
 @param accelerometer 加速度センサー
 @param acceleration 加速度情報
 */
- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
    float ax = 0.0f;
    float ay = 0.0f;
    
    AKLog(0, @"x=%g,y=%g,z=%g",acceleration.x, acceleration.y, acceleration.z);
    
    // 加速度センサーの入力値を-1.0〜1.0の比率に変換
    // 画面を横向きに使用するのでx軸y軸を入れ替える
    ax = AKAccel2Ratio(acceleration.y);
    ay = AKAccel2Ratio(-acceleration.x + 0.3);
    
    AKLog(0, @"ax=%f,ay=%f", ax, ay);
    
    // 親クラスをゲームシーンクラスにキャストする
    AKGameScene *gameScene = (AKGameScene *)self.parent;

    // 速度の変更
    [gameScene movePlayerByVX:ax VY:ay];
}
@end

/*!
 @brief 加速度センサーの値を比率換算する

 加速度センサーの入力値を最大から最小までの比率に換算する。
 @param accel 加速度センサーの入力値
 @return 比率
 */
static float AKAccel2Ratio(float accel)
{
    const float MIN_VAL = 0.05f;
    const float MAX_VAL = 0.3f;

    // 最小値未満
    if (accel < -MAX_VAL) {
        return -1.0f;
    }
    // 最大値超過
    else if (accel > MAX_VAL) {
        return 1.0f;
    }
    // 水平状態
    else if (accel > -MIN_VAL && accel < MIN_VAL) { 
        return 0.0f;
    }
    // 傾き負
    else if (accel < 0) {
        return (accel + MIN_VAL) / (MAX_VAL - MIN_VAL);
    }
    // 傾き正
    else {
        return (accel - MIN_VAL) / (MAX_VAL - MIN_VAL);
    }    
}