/*!
 @file AKPlayerShot.m
 @brief 自機弾クラス定義
 
 自機弾を管理するクラスを定義する。
 */

#import "AKPlayerShot.h"
#import "AKGameScene.h"
#import "AKCommon.h"

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
    assert(image_ != nil);
    
    // 各種パラメータを設定する
    speed_ = kAKPlayerShotSpeed;
    width_ = kAKPlayerShotSize.width;
    height_ = kAKPlayerShotSize.height;
    
    return self;
}

/*!
 @brief 破壊処理
 
 ショット発射数をカウントする。
 射程距離がまだ残っている場合は敵に命中したと判断して命中数をカウントする。
 */
- (void)destroy
{
    // ショット発射数をカウントする
    [AKGameScene sharedInstance].shotCount++;
    
    // 射程距離が残っていれば命中数をカウントする
    if (distance_ > 0.0f) {
        [AKGameScene sharedInstance].hitCount++;
    }
    AKLog(0, @"hitCount=%d shotCount=%d", [AKGameScene sharedInstance].hitCount, [AKGameScene sharedInstance].shotCount);
    
    // スーパークラスの処理を行う
    [super destroy];
}
@end
