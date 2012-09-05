/*!
 @file AKLabel.m
 @brief ラベル表示クラス
 
 テキストラベルを表示するクラスを定義する。
 */

#import "AKLabel.h"
#import "AKFont.h"

/*!
 @brief ラベル表示クラス
 
 テキストラベルを表示する。
 */
@implementation AKLabel

@synthesize batch = m_batch;
@synthesize labelString = m_labelString;

/*!
 @brief 初期文字列を指定した初期化
 
 初期文字列を指定して初期化を行う。
 @param str 表示文字列
 @param length 1行の文字数
 @param line 表示行数
 @return 生成したオブジェクト。失敗時はnilを返す。
 */
- (id)initWithString:(NSString *)str maxLength:(NSInteger)length maxLine:(NSInteger)line
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
    self.labelString = [[str copy] autorelease];
    m_length = length;
    m_line = line;
    
    // バッチノードを生成する
    self.batch = [CCSpriteBatchNode batchNodeWithTexture:[AKFont sharedInstance].fontTexture
                                                capacity:length * line];
    [self addChild:self.batch];
    
    // 各文字のスプライトを生成し、バッチノードへ登録する
    for (int i = 0; i < m_length * m_line; i++) {
        
        unichar c = ' ';
        
        // 文字列がまだ残っている場合、1文字切り出す
        if (i < self.labelString.length) {
            c = [self.labelString characterAtIndex:i];
        }
        
        // フォントクラスからスプライトフレームを生成する
        CCSpriteFrame *charSpriteFrame = [[AKFont sharedInstance] getSpriteFrameOfChar:c];
        
        // スプライトを生成する
        CCSprite *charSprite = [CCSprite spriteWithSpriteFrame:charSpriteFrame];
        
        // 表示位置を設定する。
        // 左端が親ノードのアンカーポイント(中央)にくるようにするため、
        // 右に0.5文字分ずらす。
        float x = (i % m_length) * kAKFontSize + kAKFontSize / 2;
        float y = (i / m_length) * kAKFontSize;
        charSprite.position = ccp(x, y);
        
        // 先頭からの文字数をタグにする
        charSprite.tag = i;
        
        // 表示する文字がない場合は非表示とする。
        if (i >= str.length) {
            charSprite.visible = NO;
        }
        
        // バッチノードに登録する
        [self.batch addChild:charSprite];
    }
    
    return self;
}

/*!
 @brief 初期文字列を指定したコンビニエンスコンストラクタ
 
 初期文字列を指定したコンビニエンスコンストラクタ。
 @param str 表示文字列
 @param length 1行の文字数
 @param line 表示行数
 @return 生成したオブジェクト。失敗時はnilを返す。
 */
+ (id)labelWithString:(NSString *)str maxLength:(NSInteger)length maxLine:(NSInteger)line
{
    return [[[[self class] alloc] initWithString:str maxLength:length maxLine:line] autorelease];
}

/*!
 @brief インスタンス解放時処理
 
 インスタンス解放時にオブジェクトを解放する。
 */
- (void)dealloc
{
    // メンバを解放する
    [self.batch removeAllChildrenWithCleanup:YES];
    [self removeAllChildrenWithCleanup:YES];
    self.labelString = nil;
    self.batch = nil;
    
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
    // 文字列が表示可能文字数を超えている場合はエラー
    assert(label.length <= m_length * m_line);
    
    // パラメータをメンバに設定する
    self.labelString = [[label copy] autorelease];
    
    // 各文字のスプライトを変更する
    for (int i = 0; i < m_length * m_line; i++) {
        
        // バッチノードからスプライトを取り出す
        CCSprite *charSprite = (CCSprite *)[self.batch getChildByTag:i];
        
        // 文字列がまだ残っている場合、表示文字を変更する
        if (i < self.labelString.length) {
            
            // 文字列から1文字切り出す
            unichar c = [self.labelString characterAtIndex:i];
        
            // フォントクラスからスプライトフレームを生成する
            CCSpriteFrame *charSpriteFrame = [[AKFont sharedInstance] getSpriteFrameOfChar:c];
        
            // スプライトを差し替える
            [charSprite setDisplayFrame:charSpriteFrame];
        
            // 表示状態にする
            charSprite.visible = YES;
        }
        // 文字列をすべて表示し終わっている場合は残りのスプライトは非表示とする
        else {
            charSprite.visible = NO;
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
 @return ラベルの幅。
 */
- (NSInteger)width
{
    return m_length * kAKFontSize;
}
@end
