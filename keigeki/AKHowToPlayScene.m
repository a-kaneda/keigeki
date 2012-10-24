/*!
 @file AKHowToPlayScene.m
 @brief プレイ方法画面シーンクラスの定義
 
 プレイ方法画面シーンクラスを定義する。
 */

#import "AKHowToPlayScene.h"
#import "AKCommon.h"
#import "AKTitleScene.h"
#import "AKScreenSize.h"
#import "SimpleAudioEngine.h"

// シーンに配置するノードのz座標
enum {
    kAKHowToBackPosZ = 0,   ///< 背景のz座標
    kAKHowToItemPosZ        ///< 背景以外のz座標
};

// シーンに配置するノードのタグ
enum {
    kAKHowToIntarfeceTag = 0,   ///< インターフェースのタグ
    kAKHowToMessageTag,         ///< メッセージのタグ
    kAKHowToPageTag,            ///< ページ番号のタグ
    kAKHowToPrevTag,            ///< 前ページボタンのタグ
    kAKHowToBackTag,            ///< 戻るボタンのタグ
    kAKHowToNextTag             ///< 次ページボタンのタグ
};

/// 前ページボタンの画像ファイル名
static NSString *kAKHowToPrevImage = @"PrevButton.png";
/// 次ページボタンの画像ファイル名
static NSString *kAKHowToNextImage = @"NextButton.png";
/// 戻るボタンの画像ファイル名
static NSString *kAKHowToBackImage = @"BackButton.png";
/// ページ数表示のフォーマット
static NSString *kAKHowToPageFormat = @"%d / %d";

/// 前ページボタンの位置、左からの位置
static const float kAKHowToPrevPosLeftPoint = 40.0f;
/// 前ページボタンの位置、下からの位置
static const float kAKHowToPrevPosBottomPoint = 80.0f;
/// 次ページボタンの位置、右からの位置
static const float kAKHowToNextPosRightPoint = 40.0f;
/// 次ページボタンの位置、下からの位置
static const float kAKHowToNextPosBottomPoint = 80.0f;
/// ページ番号の位置、下からの位置
static const float kAKHowToPagePosBottomPoint = 20.0f;
/// 戻るボタンの位置、右からの位置
static const float kAKHowToBackPosRightPoint = 26.0f;
/// 戻るボタンの位置、上からの位置
static const float kAKHowToBackPosTopPoint = 26.0f;

/// メッセージボックスの1行の文字数
static const NSInteger kAKHowToMsgLength = 20;
/// メッセージボックスの行数
static const NSInteger kAKHowToMsgLineCount = 5;
/// メッセージボックスの位置、下からの位置
static const float kAKHowToMsgPosBottomPoint = 110.0f;

/// ページ数
static const NSInteger kAKHowToPageCount = 3;

/*!
 @brief プレイ方法画面シーン
 
 プレイ方法画面のシーンを実現する。
 */
@implementation AKHowToPlayScene

/*!
 @brief オブジェクト生成処理
 
 オブジェクトの生成を行う。
 @return 生成したオブジェクト。失敗時はnilを返す。
 */
- (id)init
{
    // メニュー項目数
    const NSInteger kAKMenuItemCount = 3;
    
    // スーパークラスの生成処理
    self = [super init];
    if (!self) {
        return nil;
    }
    
    // インターフェースを作成する
    AKInterface *interface = [AKInterface interfaceWithCapacity:kAKMenuItemCount];
    
    // シーンへ配置する
    [self addChild:interface z:0 tag:kAKHowToIntarfeceTag];
    
    // 背景色レイヤーを作成する
    CCLayerColor *backColor = AKCreateBackColorLayer();
  
    // インターフェースに配置する
    [interface addChild:backColor z:kAKHowToBackPosZ];
    
    // メッセージボックスを作成する
    AKLabel *message = [AKLabel labelWithString:@"" maxLength:kAKHowToMsgLength maxLine:kAKHowToMsgLineCount frame:kAKLabelFrameMessage];
    
    // 配置位置を設定する
    message.position = ccp([AKScreenSize center].x,
                           [AKScreenSize positionFromBottomPoint:kAKHowToMsgPosBottomPoint]);
    
    // インターフェースに配置する
    [interface addChild:message z:kAKHowToItemPosZ tag:kAKHowToMessageTag];
    
    // 前ページボタンをインターフェースに配置する
    [interface addMenuWithFile:kAKHowToPrevImage
                         atPos:ccp([AKScreenSize positionFromLeftPoint:kAKHowToPrevPosLeftPoint],
                                   [AKScreenSize positionFromBottomPoint:kAKHowToPrevPosBottomPoint])
                        action:@selector(goPrevPage)
                             z:kAKHowToItemPosZ
                           tag:kAKHowToPrevTag];

    // 次ページボタンをインターフェースに配置する
    [interface addMenuWithFile:kAKHowToNextImage
                         atPos:ccp([AKScreenSize positionFromRightPoint:kAKHowToNextPosRightPoint],
                                   [AKScreenSize positionFromBottomPoint:kAKHowToNextPosBottomPoint])
                        action:@selector(goNextPage)
                             z:kAKHowToItemPosZ
                           tag:kAKHowToNextTag];
    
    // 戻るボタンをインターフェースに配置する
    [interface addMenuWithFile:kAKHowToBackImage
                         atPos:ccp([AKScreenSize positionFromRightPoint:kAKHowToBackPosRightPoint],
                                   [AKScreenSize positionFromTopPoint:kAKHowToBackPosTopPoint])
                        action:@selector(backToTitle)
                             z:kAKHowToItemPosZ
                           tag:kAKHowToBackTag];

    // ページ番号の初期文字列を作成する
    NSString *pageString = [NSString stringWithFormat:kAKHowToPageFormat, 1, kAKHowToPageCount];
    
    // ページ番号のラベルを作成する
    AKLabel *pageLabel = [AKLabel labelWithString:pageString maxLength:pageString.length maxLine:1 frame:kAKLabelFrameNone];
    
    // ページ番号の位置を設定する
    pageLabel.position = ccp([AKScreenSize center].x,
                             [AKScreenSize positionFromBottomPoint:kAKHowToPagePosBottomPoint]);
    
    // ページ番号のラベルをインターフェースに配置する
    [interface addChild:pageLabel z:kAKHowToItemPosZ tag:kAKHowToPageTag];
    
    // 初期ページ番号を設定する
    self.pageNo = 1;
    
    return self;
}

/*!
 @brief インターフェース取得
 
 インターフェースを取得する
 @return インターフェース
 */
- (AKInterface *)interface
{
    NSAssert([self getChildByTag:kAKHowToIntarfeceTag] != nil, @"interface is nil");
    return (AKInterface *)[self getChildByTag:kAKHowToIntarfeceTag];
}

/*!
 @brief 前ページボタン取得
 
 前ページボタンを取得する
 @return 前ページボタン
 */
- (CCNode *)prevButton
{
    NSAssert([self.interface getChildByTag:kAKHowToPrevTag] != nil, @"prev button is nil");
    return [self.interface getChildByTag:kAKHowToPrevTag];
}

/*!
 @brief 次ページボタン取得
 
 次ページボタンを取得する
 @return 次ページボタン
 */
- (CCNode *)nextButton
{
    NSAssert([self.interface getChildByTag:kAKHowToNextTag] != nil, @"next button is nil");
    return [self.interface getChildByTag:kAKHowToNextTag];
}

/*!
 @brief ページ番号ラベル取得
 
 ページ番号ラベルを取得する
 @return ページ番号ラベル
 */
- (AKLabel *)pageLabel
{
    NSAssert([self.interface getChildByTag:kAKHowToPageTag] != nil, @"page label is nil");
    return (AKLabel *)[self.interface getChildByTag:kAKHowToPageTag];
}

/*!
 @brief メッセージラベル取得
 
 メッセージラベルを取得する
 @return メッセージラベル
 */
- (AKLabel *)messageLabel
{
    NSAssert([self.interface getChildByTag:kAKHowToMessageTag] != nil, @"message label is nil");
    return (AKLabel *)[self.interface getChildByTag:kAKHowToMessageTag];
}

/*!
 @brief ページ番号取得
 
 ページ番号を取得する。
 @return ページ番号
 */
- (NSInteger)pageNo
{
    return pageNo_;
}

/*! 
 @brief ページ番号設定
 
 ページ番号を設定する。
 @param pageNo ページ番号
 */
- (void)setPageNo:(NSInteger)pageNo
{
    NSAssert(pageNo > 0 || pageNo <= kAKHowToPageCount, @"ページ番号が範囲外");
    
    // ページ番号を変更する
    pageNo_ = pageNo;
    
    // 前ページ次ページボタンの表示を更新する
    [self updatePageButton];
    
    // ページ番号のラベルを更新する
    [self updatePageLabel];
    
    // 表示文字列のキーを生成する
    NSString *key = [NSString stringWithFormat:@"HowToPlay_%d", pageNo_];
    
    // 表示文字列を取得する
    NSString *string = NSLocalizedString(key, @"プレイ方法の説明");
    
    // 表示文字列を変更する
    self.messageLabel.string = string;
}

/*!
 @brief 前ページ次ページボタン表示非表示更新
 
 前ページ、次ページボタンの表示非表示を現在のページ番号に応じて更新する。
 最初のページの場合は前ページボタンを無効にする。
 最後のページの場合は次ページボタンを無効にする。
 */
- (void)updatePageButton
{
    // 最初のページの場合は前ページボタンを無効にする
    if (pageNo_ == 1) {
        
        // インターフェースの有効タグを前ページの次の項目からとする
        [self.interface setEnableItemTagStart:kAKHowToPrevTag + 1];
        
        // 前ページボタンを非表示にする
        self.prevButton.visible = NO;
    }
    // 最初のページ以外の場合は前ページボタンを有効にする
    else {
        
        // インターフェースの有効タグを前ページからとする
        [self.interface setEnableItemTagStart:kAKHowToPrevTag];
        
        // 前ページボタンを表示する
        self.prevButton.visible = YES;
    }
    
    // 最後のページの場合は次ページボタンを無効にする
    if (pageNo_ == kAKHowToPageCount) {
        
        // インターフェースの有効タグを次ページの前の項目までとする
        [self.interface setEnableItemTagEnd:kAKHowToNextTag - 1];
        
        // 次ページボタンを非表示にする
        self.nextButton.visible = NO;
    }
    // 最後のページ以外の場合は次ページボタンを有効にする
    else {
        
        // インターフェースの有効タグを次ページまでとする
        [self.interface setEnableItemTagEnd:kAKHowToNextTag];
        
        // 次ページボタンを表示する
        self.nextButton.visible = YES;
    }
}

/*!
 @brief ページ番号表示更新
 
 ページ番号のラベルを更新する。
 */
- (void)updatePageLabel
{
    // ページ番号の文字列を作成する
    NSString *pageString = [NSString stringWithFormat:kAKHowToPageFormat, pageNo_, kAKHowToPageCount];
    
    // ページ番号のラベルを更新する
    [self.pageLabel setString:pageString];
}

/*!
 @brief 前ページ表示
 
 前ページを表示する。ページ番号を一つ減らす。
 */
- (void)goPrevPage
{
    AKLog(0, @"goPrevPage開始");
    
    // メニュー選択時の効果音を鳴らす
    [[SimpleAudioEngine sharedEngine] playEffect:kAKMenuSelectSE];

    self.pageNo = self.pageNo - 1;
}

/*!
 @brief 次ページ表示
 
 次ページを表示する。ページ番号を一つ増やす。
 */
- (void)goNextPage
{
    AKLog(0, @"goNextPage開始");
    
    // メニュー選択時の効果音を鳴らす
    [[SimpleAudioEngine sharedEngine] playEffect:kAKMenuSelectSE];

    self.pageNo = self.pageNo + 1;
}

/*!
 @brief タイトルへ戻る
 
 タイトル画面シーンへ遷移する。
 */
- (void)backToTitle
{
    AKLog(0, @"backToTitle開始");

    // メニュー選択時の効果音を鳴らす
    [[SimpleAudioEngine sharedEngine] playEffect:kAKMenuSelectSE];

    // タイトルシーンへの遷移を作成する
    CCTransitionFade *transition = [CCTransitionFade transitionWithDuration:0.5f scene:[AKTitleScene node]];
    
    // タイトルシーンへ遷移する
    [[CCDirector sharedDirector] replaceScene:transition];
}
@end
