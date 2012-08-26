/*!
 @file AKLifeMark.m
 @brief 残機マーク表示クラス定義
 
 残機マークを表示するクラスを定義する。
 */

#import "AKLifeMark.h"

/// 残機マーク表示位置
static const CGPoint kAKLifeMarkPos = {10, 260};
/// 残機マーク表示位置のインターバル
static const NSInteger kAKLifeMarkInterval = 20;

/*!
 @brief 残機マーク表示クラス
 
 残機マークを表示するクラス。
 */
@implementation AKLifeMark

@synthesize imageArray = m_imageArray;

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
    
    // 残機マークの画像配列を生成する
    self.imageArray = [[[NSMutableArray alloc] init] autorelease];
    assert(self != nil);
    
    return self;
}
/*!
 @brief インスタンス解放時処理
 
 インスタンス解放時にオブジェクトを解放する。
 */
- (void)dealloc
{    
    // 残機マークを解放する
    self.imageArray = nil;
    [self removeAllChildrenWithCleanup:YES];
        
    // スーパークラスの解放処理を実行する
    [super dealloc];
}

/*!
 @brief 表示の更新
 
 渡された残機の個数に合わせて表示内容を更新する。
 @param life 残機の個数
 */
- (void)updateImage:(NSInteger)life
{
    int i = 0;                  // ループ変数
    float x = 0.0f;             // 画像表示のx座標
    float y = 0.0f;             // 画像表示のy座標
    NSInteger imageCount = 0;   // 現在表示中の画像の数
    CCSprite *image = nil;      // 残機マーク画像
    
    // 現在表示中の画像の数を取得する
    imageCount = self.imageArray.count;
    
    // 現在表示中の画像の数の方が少ない場合はマークを追加する
    if (imageCount < life) {
        
        // 足りない個数分画像を生成する
        for (i = 0; i < life - imageCount; i++) {
            
            // 画像を読み込む
            image = [CCSprite spriteWithFile:@"Life.png"];
            assert(image != nil);
            
            // 画像のx座標は原点から右側に現在の個数分ずらした位置とする
            x = kAKLifeMarkPos.x + (imageCount + i) * kAKLifeMarkInterval;
            
            // 画像のy座標はすべて共通とする
            y = kAKLifeMarkPos.y;
            
            // 画像の座標を設定する
            image.position = ccp(x, y);
            
            // 画像をノードに追加する
            [self addChild:image];
            
            // 画像を配列に追加する
            [self.imageArray addObject:image];
        }
    }
    // 現在表地中の画像の数の方が多い場合はマークを削除する
    else if (imageCount > life) {
        
        // 多すぎる個数分画像を解放する
        for (i = 0; i < imageCount - life; i++) {
            
            // 末尾の画像を取得する
            image = self.imageArray.lastObject;
            
            // 配列から末尾の画像を削除する
            [self.imageArray removeLastObject];
            
            // 画像をノードから削除する
            [self removeChild:image cleanup:YES];
        }
    }
    // 個数が変わらない場合は無処理
    else {
        // No operation.
    }
}
@end
