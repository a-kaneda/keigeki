/*!
 @file AKPlayerShot.m
 @brief 自機弾クラス定義
 
 自機弾を管理するクラスを定義する。
 */

#import "AKPlayerShot.h"
#import "common.h"

/// 自機弾のスピード
static const NSInteger kAKPlayerShotSpeed = 1200;
/// 自機弾の幅
static const CGSize kAKPlayerShotSize = {2, 8};

/*!
 @brief 自機弾クラス

 自機弾を管理するクラス。
 */
@implementation AKPlayerShot

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
    
    // 画像の読込
    self.image = [CCSprite spriteWithFile:@"PlayerShot.png"];
    assert(m_image != nil);
    
    // 各種パラメータを設定する
    m_speed = kAKPlayerShotSpeed;
    m_width = kAKPlayerShotSize.width;
    m_height = kAKPlayerShotSize.height;
    
    return self;
}
@end
