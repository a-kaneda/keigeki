/*!
 @file AKResultLayer.m
 @brief ステージクリア結果レイヤー
 
 ステージクリア結果画面のレイヤーを定義する。
 */

#import "AKResultLayer.h"
#import "common.h"

/*!
 @brief ステージクリア結果レイヤー
 
 ステージクリア結果画面を表示する。
 */
@implementation AKResultLayer

@synthesize isFinish = m_isFinish;

/*!
 @brief オブジェクト生成処理
 
 オブジェクトの生成を行う。
 @return 生成したオブジェクト。失敗時はnilを返す。
 */
- (id)init
{
    CCSprite *background = nil; // 背景画像のスプライト
    
    // スーパークラスの生成処理を実行する
    self = [super init];
    if (!self) {
        return nil;
    }
    
    // 背景画像を読み込む
    background = [CCSprite spriteWithFile:@"Result.png"];
    assert(background != nil);
    
    // 背景画像の配置位置を画面中央にする
    background.position = ccp(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2);
    
    // レイヤーに配置する
    [self addChild:background z:0];
    
    // メンバの初期化
    m_isFinish = YES;
    
    return self;
}

/*!
 @brief インスタンス解放時処理
 
 インスタンス解放時にオブジェクトを解放する。
 */
- (void)dealloc
{
    // 配置されているオブジェクトを開放する
    [self removeAllChildrenWithCleanup:YES];
    
    // スーパークラスの開放処理を実行する
    [super dealloc];
}
@end
