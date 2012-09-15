/*!
 @file AKLabel.m
 @brief ラベル表示クラス
 
 テキストラベルを表示するクラスを定義する。
 */

#import "AKLabel.h"
#import "AKFont.h"
#import "common.h"

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
/// ブランクのキー
static NSString *kAKBlank = @" ";

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
 @brief 初期文字列を指定した初期化
 
 初期文字列を指定して初期化を行う。
 @param str 表示文字列
 @param length 1行の文字数
 @param line 表示行数
 @param hasFrame 枠を持つかどうか
 @return 生成したオブジェクト。失敗時はnilを返す。
 */
- (id)initWithString:(NSString *)str maxLength:(NSInteger)length maxLine:(NSInteger)line hasFrame:(BOOL)hasFrame
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
    m_length = length;
    m_line = line;
    m_hasFrame = hasFrame;
    
    // 文字表示用バッチノードを生成する
    [self addChild:[CCSpriteBatchNode batchNodeWithTexture:[AKFont sharedInstance].fontTexture capacity:length * line]
                 z:kAKLabelBatchPosZ
               tag:kAKLabelBatchPosZ];
    
    // 枠付きの場合は枠の生成を行う
    if (m_hasFrame) {
        [self createFrame];
    }
    
    // 各文字のスプライトを生成し、バッチノードへ登録する
    for (int y = 0; y < m_line; y++) {
        
        for (int x = 0; x < m_length; x++) {
                
            // フォントクラスからスプライトフレームを生成する
            CCSpriteFrame *charSpriteFrame = [[AKFont sharedInstance] spriteFrameOfChar:' '];
            
            // スプライトを生成する
            CCSprite *charSprite = [CCSprite spriteWithSpriteFrame:charSpriteFrame];
            
            // 表示位置を設定する。
            // 左端が親ノードのアンカーポイント(中央)にくるようにするため、
            // 右に0.5文字分ずらす。
            // 行間に0.5文字分の隙間を入れるため、高さは1.5倍する。
            charSprite.position = ccp(x * kAKFontSize + kAKFontSize / 2, -y * kAKFontSize * 1.5);
            
            // 先頭からの文字数をタグにする
            charSprite.tag = x + y * m_length;
            
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
 @param hasFrame 枠を持つかどうか
 @return 生成したオブジェクト。失敗時はnilを返す。
 */
+ (id)labelWithString:(NSString *)str maxLength:(NSInteger)length maxLine:(NSInteger)line hasFrame:(BOOL)hasFrame
{
    return [[[[self class] alloc] initWithString:str maxLength:length maxLine:line hasFrame:hasFrame] autorelease];
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
    return m_labelString;
}

/*!
 @brief 表示文字列の設定
 
 表示文字列を変更する。
 @param label 表示文字列
 */
- (void)setString:(NSString *)label
{
    DBGLOG(0, @"start setString:");
    
    // 文字列が表示可能文字数を超えている場合はエラー
    assert(label.length <= m_length * m_line);
    
    // パラメータをメンバに設定する
    self.labelString = [[label copy] autorelease];
    
    // 各文字のスプライトを変更する
    int charpos = 0;
    BOOL isNewLine = NO;
    for (int y = 0; y < m_line; y++) {
        
        // 改行フラグを落とす
        isNewLine = NO;
        
        for (int x = 0; x < m_length; x++) {
            
            // バッチノードからスプライトを取り出す
            CCSprite *charSprite = (CCSprite *)[self.labelBatch getChildByTag:x + y * m_length];

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
            
            DBGLOG(0, @"x=%d y=%d c=%C", x, y, c);
            
            // フォントクラスからスプライトフレームを生成する
            CCSpriteFrame *charSpriteFrame = [[AKFont sharedInstance] spriteFrameOfChar:c];
            
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
 
 ラベルの幅を取得する。1行の表示文字数にフォントサイズをかけて返す。
 枠付きの場合は枠のサイズ2文字分をプラスして返す。
 @return ラベルの幅。
 */
- (NSInteger)width
{
    // 枠がある場合は枠の領域を2文字分プラスして返す
    if (m_hasFrame) {
        return (m_length + 2) * kAKFontSize;
    }
    // 枠がない場合は文字領域のサイズを返す
    else {
        return m_length * kAKFontSize;
    }
}

/*!
 @brief ラベルの矩形領域の取得
 
 ラベルの矩形領域を取得する。
 アンカーポイントがラベルの左端中央のため、
 x座標はアンカーポイント、y座標はアンカーポイント - 0.5文字、
 高さは行数、幅は文字数とする。
 枠付きの場合は1文字分一回り大きくして返す。
 @return ラベルの矩形領域
 */
- (CGRect)rect
{
    // 枠がある場合は枠の領域をプラスして返す
    if (m_hasFrame) {
        return CGRectMake(self.position.x - kAKFontSize,
                          self.position.y - kAKFontSize / 2 ,
                          self.width,
                          kAKFontSize);
    }
    return CGRectMake(self.position.x,
                      self.position.y - kAKFontSize / 2,
                      self.width,
                      kAKFontSize);
}

/*!
 @brief 枠の生成
 
 枠を生成する。
 */
- (void)createFrame
{
    // 枠示用バッチノードを生成する
    [self addChild:[CCSpriteBatchNode batchNodeWithTexture:[AKFont sharedInstance].fontTexture
                                                  capacity:(m_length + 2) * (m_line * 1.5 + 2)]
                 z:kAKFrameBatchPosZ
               tag:kAKFrameBatchPosZ];
    
    // 行間に0.5文字分の隙間を空けるため、行数の1.5倍の高さを用意する。
    // 枠を入れるため、上下+-1個分用意する。
    for (int y = -1; y < (int)(m_line * 1.5) + 1; y++) {
        
        // 枠を入れるため、左右+-1個分用意する。
        for (int x = -1; x < m_length + 1; x++) {
            
            // キー文字列
            NSString *key = nil;
            
            // 左上の場合
            if (y == -1 && x == -1) {
                DBGLOG(0, @"x=%d y=%d topleft", x, y);
                key = kAKTopLeft;
            }
            // 右上の場合
            else if (y == -1 && x == m_length) {
                DBGLOG(0, @"x=%d y=%d topright", x, y);
                key =kAKTopRight;
            }
            // 左下の場合
            else if (y == (int)(m_line * 1.5) && x == -1) {
                DBGLOG(0, @"x=%d y=%d bottomleft", x, y);
                key = kAKBottomLeft;
            }
            // 右下の場合
            else if (y == (int)(m_line * 1.5) && x == m_length) {
                DBGLOG(0, @"x=%d y=%d bottomright", x, y);
                key = kAKBottomRight;
            }
            // 上の場合
            else if (y == -1) {
                DBGLOG(0, @"x=%d y=%d topbar", x, y);
                key = kAKTopBar;
            }
            // 左の場合
            else if (x == -1) {
                DBGLOG(0, @"x=%d y=%d leftbar", x, y);
                key = kAKLeftBar;
            }
            // 右の場合
            else if (x == m_length) {
                DBGLOG(0, @"x=%d y=%d rightbar", x, y);
                key = kAKRightBar;
            }
            // 下の場合
            else if (y == (int)(m_line * 1.5)) {
                DBGLOG(0, @"x=%d y=%d bottombar", x, y);
                key = kAKBottomBar;
            }
            // 文字の部分の場合
            else {
                key = kAKBlank;
            }
            
            // フォントクラスからスプライトフレームを生成する
            CCSpriteFrame *charSpriteFrame = [[AKFont sharedInstance] spriteFrameWithKey:key];
            
            // スプライトを生成する
            CCSprite *charSprite = [CCSprite spriteWithSpriteFrame:charSpriteFrame];
            
            // 表示位置を設定する。
            // 左端が親ノードのアンカーポイント(中央)にくるようにするため、
            // 右に0.5文字分ずらす。
            charSprite.position = ccp(x * kAKFontSize + kAKFontSize / 2, -y * kAKFontSize);
            
            // バッチノードに登録する
            [self.frameBatch addChild:charSprite];
        }
    }
}
@end
