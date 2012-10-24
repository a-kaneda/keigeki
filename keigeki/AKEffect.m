/*!
 @file AKEffect.m
 @brief 画面効果クラス定義
 
 爆発等の画面効果を生成するクラスを定義する。
 */

#import "AKEffect.h"
#import "AKCommon.h"

/*!
 @brief 画面効果クラス
 
 爆発等の画面効果を生成する。
 */
@implementation AKEffect

/*!
 @brief オブジェクト生成処理
 
 オブジェクトの生成を行う。
 @return 生成したオブジェクト。失敗時はnilを返す。
 */
- (id)init
{
    // スーパークラスの生成処理
    self = [super init];
    if (!self) {
        return nil;
    }
    
    // パーティクルを配置するためダミーのノードを作成する
    self.image = [CCNode node];
    assert(image_ != nil);
        
    return self;
}

/*!
 @brief キャラクター固有の動作
 
 生存時間を経過している場合は画面から取り除く。
 @param dt フレーム更新間隔
 */
- (void)action:(ccTime)dt
{
    AKLog(0, @"lifetime=%f dt=%f", lifetime_, dt);
    AKLog(0, @"position=(%f, %f)", self.image.position.x, self.image.position.y);
    AKLog(0, @"abspos=(%f, %f)", self.absx, self.absy);
    
    // 生存時間を減らす
    lifetime_ -= dt;
    
    // 生存時間がつきた場合は削除する
    if (lifetime_ < 0) {
        AKLog(0, @"effect end");
        hitPoint_ = -1.0f;
        
        // 画面効果を削除する
        [self.image removeAllChildrenWithCleanup:YES];
    }
}

/*!
 @brief 画面効果開始
 
 画面効果を開始する。指定された画像ファイルからアニメーションを作成する。
 アニメーションは画像内で横方向に同じサイズで並んでいることを前提とする。
 @param fileName 画像ファイル名
 @param rect アニメーション開始時の画像範囲
 @param count アニメーションフレームの個数
 @param delay フレームの間隔
 @param posx x座標
 @param posy y座標
 */
- (void)startEffectWithFile:(NSString *)fileName startRect:(CGRect)rect
                 frameCount:(NSInteger)count delay:(float)delay
                       posX:(float)posx posY:(float)posy
{
    // バッチノードを作成する
    CCSpriteBatchNode *batch = [CCSpriteBatchNode batchNodeWithFile:fileName capacity:count];
    NSAssert(batch != nil, @"can not create CCSpriteBatchNode from %@", fileName);
    
    // 最初の1フレーム目のスプライトを作成する
    CCSprite *sprite = [CCSprite spriteWithTexture:batch.texture rect:rect];
    
    // バッチノードにスプライトを登録する
    [batch addChild:sprite];

    // ファイルからスプライトフレームをアニメーションのフレーム数分作成する
    NSMutableArray *animationFrames = [NSMutableArray arrayWithCapacity:count];
    for (int i = 1; i < count; i++) {
        
        // ファイルからスプライトフレームを作成する
        CCSpriteFrame *spriteFrame = [CCSpriteFrame frameWithTextureFilename:fileName
                                                                        rect:CGRectMake(rect.origin.x + rect.size.width * i,
                                                                                        rect.origin.y,
                                                                                        rect.size.width,
                                                                                        rect.size.height)];
        
        // 配列に追加する
        [animationFrames addObject:spriteFrame];
    }

    // アニメーションフレームからアニメーションを作成する
    CCAnimation *animation = [CCAnimation animationWithSpriteFrames:animationFrames delay:delay];
    
    // アニメーションからアクションを作成する
    CCAnimate *animate = [CCAnimate actionWithAnimation:animation];
    
    // アニメーションを開始する
    [sprite runAction:animate];
    
    // バッチノードを自分のイメージに登録する
    [self.image addChild:batch];
    
    // 表示座標を設定する
    self.absx = posx;
    self.absy = posy;
    
    // フレーム数 * ディレイ時間を生存時間とする
    lifetime_ = count * delay;
    
    // 画面配置フラグとHPを設定する
    self.isStaged = YES;
    self.hitPoint = 1;
}
@end
