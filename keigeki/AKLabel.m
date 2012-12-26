/*!
 @file AKLabel.m
 @brief ラベル表示クラス
 
 テキストラベルを表示するクラスを定義する。
 */

#import "AKLabel.h"
#import "AKFont.h"
#import "AKCommon.h"

/// 左上の枠のキー
static NSString *kAKTopLeft = @"TopLeft";
/// 右上の枠のキー
static NSString *kAKTopRight = @"TopRight";
/// 左下の枠のキー
static NSString *kAKBottomLeft = @"BottomLeft";
/// 右下の枠のキー
static NSString *kAKBottomRight = @"BottomRight";
/// 上の枠のキー
static NSString *kAKTopBar = @"TopBar";
/// 左の枠のキー
static NSString *kAKLeftBar = @"LeftBar";
/// 右の枠のキー
static NSString *kAKRightBar = @"RightBar";
/// 下の枠のキー
static NSString *kAKBottomBar = @"BottomBar";
/// ボタン左上の枠のキー
static NSString *kAKButtonTopLeft = @"ButtonTopLeft";
/// ボタン右上の枠のキー
static NSString *kAKButtonTopRight = @"ButtonTopRight";
/// ボタン左下の枠のキー
static NSString *kAKButtonBottomLeft = @"ButtonBottomLeft";
/// ボタン右下の枠のキー
static NSString *kAKButtonBottomRight = @"ButtonBottomRight";
/// ボタン上の枠のキー
static NSString *kAKButtonTopBar = @"ButtonTopBar";
/// ボタン左の枠のキー
static NSString *kAKButtonLeftBar = @"ButtonLeftBar";
/// ボタン右の枠のキー
static NSString *kAKButtonRightBar = @"ButtonRightBar";
/// ボタン下の枠のキー
static NSString *kAKButtonBottomBar = @"ButtonBottomBar";
/// ボタンブランクのキー
static NSString *kAKBlank = @" ";

/// 1行の高さ(単位：文字)
static const float kAKLabelLineHeight = 1.5f;

// バッチノードのz座標(タグ兼用)
enum {
    kAKFrameBatchPosZ = 0,  ///< 枠表示用バッチノードのz座標
    kAKLabelBatchPosZ       ///< 文字表示用バッチノードのz座標
};

/*!
 @brief ラベル表示クラス
 
 テキストラベルを表示する。
 */
@implementation AKLabel

/*!
 @brief 指定文字数の幅取得
 
 指定された文字数のラベルの幅を取得する。
 文字数にフォントサイズをかけて返す。
 枠付きが指定された場合は枠のサイズ2文字分をプラスする。
 @param length 文字数
 @param hasFrame 枠付きかどうか
 @return ラベルの幅
 */
+ (NSInteger)widthWithLength:(NSInteger)length hasFrame:(BOOL)hasFrame
{
    // 枠がある場合は枠の領域を2文字分プラスして返す
    if (hasFrame) {
        return (length + 2) * [AKFont fontSize];
    }
    // 枠がない場合は文字領域のサイズを返す
    else {
        return length * [AKFont fontSize];
    }
}

/*!
 @brief 指定行数の高さ取得
 
 指定された行数のラベルの高さを取得する。
 行数にフォントサイズをかけた値と行間の高さを足した値を返す。
 枠付きが指定された場合は枠のサイズ2文字分をプラスする。
 @param line 行数
 @param hasFrame 枠付きかどうか
 @return ラベルの高さ
 */
+ (NSInteger)heightWithLine:(NSInteger)line hasFrame:(BOOL)hasFrame
{
    // 枠がある場合は枠の領域を2文字分プラスして返す
    if (hasFrame) {
        return ((int)(line * kAKLabelLineHeight) + 2) * [AKFont fontSize];
    }
    // 枠がない場合は文字領域のサイズを返す
    else {
        return (int)(line * kAKLabelLineHeight) * [AKFont fontSize];
    }
}

/*!
 @brief 指定文字数、指定行数の指定位置の矩形範囲取得
 
 指定された文字数、行数、指定位置のラベルの矩形範囲を取得する。
 @param x ラベルの中心座標x座標
 @param y ラベルの中心座標y座標
 @param length 1行の文字数
 @param line 行数
 @param hasFrame 枠付きかどうか
 @return ラベルの矩形範囲
 */
+ (CGRect)rectWithCenterX:(float)x centerY:(float)y length:(NSInteger)length line:(NSInteger)line hasFrame:(BOOL)hasFrame
{
    return CGRectMake(x - [AKLabel widthWithLength:length hasFrame:hasFrame] / 2,
                      y - [AKLabel heightWithLine:line hasFrame:hasFrame] / 2,
                      [AKLabel widthWithLength:length hasFrame:hasFrame],
                      [AKLabel heightWithLine:line hasFrame:hasFrame]);
}

/*!
 @brief 初期文字列を指定した初期化
 
 初期文字列を指定して初期化を行う。
 @param str 表示文字列
 @param length 1行の文字数
 @param line 表示行数
 @param frame 枠の種類
 @return 生成したオブジェクト。失敗時はnilを返す。
 */
- (id)initWithString:(NSString *)str maxLength:(NSInteger)length maxLine:(NSInteger)line frame:(enum AKLabelFrame)frame
{
    // スーパークラスの生成処理を実行する
    self = [super init];
    if (!self) {
        return nil;
    }
    
    // 文字列が表示可能文字数を超えている場合はエラー
    assert(str.length <= length * line);
    
    // 行数、文字数は最低でも1以上とする
    assert(length > 0);
    assert(line > 0);
    
    // パラメータをメンバに設定する
    length_ = length;
    line_ = line;
    frame_ = frame;
    
    // 色反転はなしとする
    isReverse_ = NO;
    
    // 文字表示用バッチノードを生成する
    [self addChild:[CCSpriteBatchNode batchNodeWithTexture:[AKFont sharedInstance].fontTexture capacity:length * line]
                 z:kAKLabelBatchPosZ
               tag:kAKLabelBatchPosZ];
    
    // 枠付きの場合は枠の生成を行う
    if (frame_ != kAKLabelFrameNone) {
        
        // 枠示用バッチノードを生成する
        [self addChild:[CCSpriteBatchNode batchNodeWithTexture:[AKFont sharedInstance].fontTexture
                                                      capacity:(length_ + 2) * (line_ * 1.5 + 2)]
                     z:kAKFrameBatchPosZ
                   tag:kAKFrameBatchPosZ];
        

        // 枠を作成する
        [self createFrame];
    }
    
    // 各文字のスプライトを生成し、バッチノードへ登録する
    for (int y = 0; y < line_; y++) {
        
        for (int x = 0; x < length_; x++) {
                
            // フォントクラスからスプライトフレームを生成する
            CCSpriteFrame *charSpriteFrame = [[AKFont sharedInstance] spriteFrameOfChar:' ' isReverse:self.isReverse];
            
            // スプライトを生成する
            CCSprite *charSprite = [CCSprite spriteWithSpriteFrame:charSpriteFrame];
            
            // 表示位置を設定する。
            // テキスト領域の中央とバッチノードの中央を一致させるため、
            // 左に1行の長さの半分、上方向に行数の半分移動する。
            // 行間に0.5文字分の隙間を入れるため、高さは1.5倍する。
            charSprite.position = ccp((x - (length_ - 1) / 2.0f) * [AKFont fontSize],
                                      (-y + (line_ - 1) / 2.0f) * [AKFont fontSize] * kAKLabelLineHeight);
            
            // 先頭からの文字数をタグにする
            charSprite.tag = x + y * length_;
            
            // バッチノードに登録する
            [self.labelBatch addChild:charSprite];
        }
    }
    
    // ラベル文字列を設定する
    self.string = str;
    
    return self;
}

/*!
 @brief 初期文字列を指定したコンビニエンスコンストラクタ
 
 初期文字列を指定したコンビニエンスコンストラクタ。
 @param str 表示文字列
 @param length 1行の文字数
 @param line 表示行数
 @param frame 枠の種類
 @return 生成したオブジェクト。失敗時はnilを返す。
 */
+ (id)labelWithString:(NSString *)str maxLength:(NSInteger)length maxLine:(NSInteger)line frame:(enum AKLabelFrame)frame
{
    return [[[[self class] alloc] initWithString:str maxLength:length maxLine:line frame:frame] autorelease];
}

/*!
 @brief 色反転するかどうかの取得
 
 色反転するかどうかを取得する。
 @return 色反転するかどうか
 */
- (BOOL)isReverse
{
    return isReverse_;
}

/*!
 @brief 色反転するかどうかの設定
 
 色反転するかどうかを設定する。
 設定したあとに表示文字列の更新を行う。
 @param isReverse 色反転するかどうか
 */
- (void)setIsReverse:(BOOL)isReverse
{
    // 変更された場合のみ処理を行う
    if (isReverse_ != isReverse) {
        
        AKLog(1, @"色反転設定:%d", isReverse);

        // メンバに設定する
        isReverse_ = isReverse;
        
        // 枠を更新する
        [self createFrame];
        
        // 表示文字列を更新する
        [self setString:self.labelString];
    }
}

/*!
 @brief 枠表示用バッチノード取得
 
 枠表示用バッチノードを取得する
 @return 枠表示用バッチノード
 */
- (CCSpriteBatchNode *)frameBatch
{
    return (CCSpriteBatchNode *)[self getChildByTag:kAKFrameBatchPosZ];
}

/*!
 @brief 文字表示用バッチノード取得
 
 文字表示用バッチノードを取得する
 @return 文字表示用バッチノード
 */
- (CCSpriteBatchNode *)labelBatch
{
    return (CCSpriteBatchNode *)[self getChildByTag:kAKLabelBatchPosZ];
}

/*!
 @brief インスタンス解放時処理
 
 インスタンス解放時にオブジェクトを解放する。
 */
- (void)dealloc
{
    // メンバを解放する
    self.labelString = nil;
    
    // スーパークラスの解放処理を実行する
    [super dealloc];
}

/*!
 @brief 表示文字列の取得
 
 表示文字列を取得する。
 @return 表示文字列
 */
- (NSString *)string
{
    return labelString_;
}

/*!
 @brief 表示文字列の設定
 
 表示文字列を変更する。
 @param label 表示文字列
 */
- (void)setString:(NSString *)label
{
    AKLog(0, @"start setString:label.lengt=%d length_=%d line_=%d", label.length, length_, line_);
    
    // 文字列が表示可能文字数を超えている場合はエラー
    assert(label.length <= length_ * line_);
    
    // パラメータをメンバに設定する
    if (![self.labelString isEqualToString:label]) {
        self.labelString = [[label copy] autorelease];
    }
    
    // 各文字のスプライトを変更する
    int charpos = 0;
    BOOL isNewLine = NO;
    for (int y = 0; y < line_; y++) {
        
        // 改行フラグを落とす
        isNewLine = NO;
        
        for (int x = 0; x < length_; x++) {
            
            // バッチノードからスプライトを取り出す
            CCSprite *charSprite = (CCSprite *)[self.labelBatch getChildByTag:x + y * length_];

            unichar c = ' ';
            
            // 改行されておらず、文字列がまだ残っている場合、1文字切り出す
            if (!isNewLine && charpos < self.labelString.length) {
                c = [self.labelString characterAtIndex:charpos];
                charpos++;
                
                // 改行文字の場合はブランクに置き換え、改行フラグを立てる
                if (c == '\n') {
                    c = ' ';
                    isNewLine = YES;
                }
            }
            // 残っていない場合はブランクとする
            else {
                c = ' ';
            }
            
            AKLog(0, @"x=%d y=%d c=%C", x, y, c);
            
            // フォントクラスからスプライトフレームを生成する
            CCSpriteFrame *charSpriteFrame = [[AKFont sharedInstance] spriteFrameOfChar:c isReverse:self.isReverse];
            
            // スプライトを差し替える
            [charSprite setDisplayFrame:charSpriteFrame];
        }
        
        // 行末の改行文字は飛ばす
        if (charpos < self.labelString.length && [self.labelString characterAtIndex:charpos] == '\n') {
            charpos++;
        }
    }
}

/*!
 @brief char配列による表示文字列の設定
 
 表示文字列をchar配列で指定して設定する。
 @param 表示文字列
 */
- (void)setCString:(char *)label
{
    [self setString:[NSString stringWithUTF8String:label]];
}

/*!
 @brief ラベルの幅の取得
 
 ラベルの幅を取得する。
 クラスメソッドの幅取得処理にメンバの値を渡して計算を行う。
 @return ラベルの幅
 */
- (NSInteger)width
{
    return [[self class] widthWithLength:length_ hasFrame:(frame_ != kAKLabelFrameNone)];
}

/*!
 @brief ラベルの高さの取得
 
 ラベルの高さを取得する。
 クラスメソッドの高さ取得処理にメンバの値を渡して計算を行う。
 @return ラベルの高さ
 */
- (NSInteger)height
{
    return [[self class] heightWithLine:line_ hasFrame:(frame_ != kAKLabelFrameNone)];
}

/*!
 @brief ラベルの矩形領域の取得
 
 ラベルの矩形領域を取得する。
 @return ラベルの矩形領域
 */
- (CGRect)rect
{
    return CGRectMake(self.position.x - self.width / 2,
                      self.position.y - self.height / 2,
                      self.width,
                      self.height);
}

/*!
 @brief 枠の生成
 
 枠を生成する。
 */
- (void)createFrame
{
    NSString *keyTopLeft = nil;
    NSString *keyTopRight = nil;
    NSString *keyBottomLeft = nil;
    NSString *keyBottomRight = nil;
    NSString *keyTopBar = nil;
    NSString *keyBottomBar = nil;
    NSString *keyLeftBar = nil;
    NSString *keyRightBar = nil;
    
    // 枠の種類に応じてキー文字列を切り替える
    switch (frame_) {
            
        case kAKLabelFrameMessage:  // メッセージボックス
            
            keyTopLeft = kAKTopLeft;
            keyTopRight = kAKTopRight;
            keyBottomLeft = kAKBottomLeft;
            keyBottomRight = kAKBottomRight;
            keyTopBar = kAKTopBar;
            keyBottomBar = kAKBottomBar;
            keyLeftBar = kAKLeftBar;
            keyRightBar = kAKRightBar;
            
            break;
            
        case kAKLabelFrameButton:   // ボタン
        
            keyTopLeft = kAKButtonTopLeft;
            keyTopRight = kAKButtonTopRight;
            keyBottomLeft = kAKButtonBottomLeft;
            keyBottomRight = kAKButtonBottomRight;
            keyTopBar = kAKButtonTopBar;
            keyBottomBar = kAKButtonBottomBar;
            keyLeftBar = kAKButtonLeftBar;
            keyRightBar = kAKButtonRightBar;

            break;
            
        default:
            NSAssert(0, @"枠の種類が異常:m_frame=%d", frame_);
            return;
    }
    
    // 行間に0.5文字分の隙間を空けるため、行数の1.5倍の高さを用意する。
    // 枠を入れるため、上下+-1個分用意する。
    for (int y = -1; y < (int)(line_ * kAKLabelLineHeight) + 1; y++) {
        
        AKLog(0, @"y=%d pos=%f", y, (-y + line_ * kAKLabelLineHeight / 2.0f) * [AKFont fontSize]);
        
        // 枠を入れるため、左右+-1個分用意する。
        for (int x = -1; x < length_ + 1; x++) {
            
            AKLog(0 && y == -1, @"x=%d pos=%f", x, (x - length_ / 2.0f) * [AKFont fontSize]);
            
            // キー文字列
            NSString *key = nil;
            
            // 左上の場合
            if (y == -1 && x == -1) {
                AKLog(0, @"x=%d y=%d topleft", x, y);
                key = keyTopLeft;
            }
            // 右上の場合
            else if (y == -1 && x == length_) {
                AKLog(0, @"x=%d y=%d topright", x, y);
                key = keyTopRight;
            }
            // 左下の場合
            else if (y == (int)(line_ * 1.5) && x == -1) {
                AKLog(0, @"x=%d y=%d bottomleft", x, y);
                key = keyBottomLeft;
            }
            // 右下の場合
            else if (y == (int)(line_ * 1.5) && x == length_) {
                AKLog(0, @"x=%d y=%d bottomright", x, y);
                key = keyBottomRight;
            }
            // 上の場合
            else if (y == -1) {
                AKLog(0, @"x=%d y=%d topbar", x, y);
                key = keyTopBar;
            }
            // 左の場合
            else if (x == -1) {
                AKLog(0, @"x=%d y=%d leftbar", x, y);
                key = keyLeftBar;
            }
            // 右の場合
            else if (x == length_) {
                AKLog(0, @"x=%d y=%d rightbar", x, y);
                key = keyRightBar;
            }
            // 下の場合
            else if (y == (int)(line_ * 1.5)) {
                AKLog(0, @"x=%d y=%d bottombar", x, y);
                key = keyBottomBar;
            }
            // 文字の部分の場合
            else {
                key = kAKBlank;
            }
            
            // 先頭からの文字数をタグとする
            // xとyはそれぞれ-1からスタートしているため、+1して0からスタートするように補正する。
            NSInteger tag = (x + 1) + (y + 1) * (length_ + 1 + 1);
            AKLog(0, @"tag=%d", tag);
            
            // フォントクラスからスプライトフレームを生成する
            CCSpriteFrame *charSpriteFrame = [[AKFont sharedInstance] spriteFrameWithKey:key isReverse:self.isReverse];
            
            // バッチノードからスプライトを取り出す
            CCSprite *charSprite = (CCSprite *)[self.frameBatch getChildByTag:tag];
            
            // 取得できない場合はスプライトを生成する
            if (charSprite == nil) {
                
                //　スプライトを生成する
                charSprite = [CCSprite spriteWithSpriteFrame:charSpriteFrame];
                
                // 表示位置を設定する。
                // テキスト領域の中央とバッチノードの中央を一致させるため、
                // 左に1行の長さの半分、上方向に行数の半分移動する。
                charSprite.position = ccp((x - (length_ - 1) / 2.0f) * [AKFont fontSize],
                                          (-y + (line_ - 1) * kAKLabelLineHeight / 2.0f) * [AKFont fontSize]);
                
                // バッチノードに登録する
                [self.frameBatch addChild:charSprite z:0 tag:tag];
            }
            else {
            
                // スプライトを差し替える
                [charSprite setDisplayFrame:charSpriteFrame];
            }
        }
    }
}
@end
