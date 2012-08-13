//
//  AKPlayerShot.m
//  keigeki:傾撃
//
//  Created by 金田 明浩 on 2012/07/23.
//  Copyright 2012 KANEDA Akihiro. All rights reserved.
//

#import "AKPlayerShot.h"
#import "common.h"

@implementation AKPlayerShot

/*!
 @method オブジェクト生成処理
 @abstruct オブジェクトの生成を行う。
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
    
    // 画像をノードに追加する
    [self addChild:m_image];
    
    return self;
}

/*!
 @method キャラクター固有の動作
 @abstruct 射程距離を外れたとき画面から取り除く。
 @param dt フレーム更新間隔
 */
- (void)action:(ccTime)dt
{
    // 移動距離をカウントする
    m_distance += m_speed * dt;
    
    // 移動距離が射程距離を超えた場合は弾を削除する
    if (m_distance > PLAYER_SHOT_RANGE) {
        m_hitPoint = -1.0f;
    }
}

/*!
 @method 生成処理
 @abstruct 自機弾を生成する。
 @param x 生成位置x座標
 @param y 生成位置y座標
 @param z 生成位置z座標
 @param angle 自機弾の進行方向
 @param parent 自機弾を配置する親ノード
 */
- (void)createWithX:(NSInteger)x Y:(NSInteger)y Z:(NSInteger)z Angle:(float)angle
              Parent:(CCNode *)parent
{
    // パラメータの内容をメンバに設定する
    self.absx = x;
    self.absy = y;
    self.angle = angle;
    
    // メンバの初期値を設定する
    m_hitPoint = 1;
    m_speed = PLAYER_SHOT_SPEED;
    m_width = PLAYER_SHOT_WIDTH;
    m_height = PLAYER_SHOT_HEIGHT;
    m_isStaged = YES;
    m_distance = 0.0f;
    
    // レイヤーに配置する
    [parent addChild:self z:z];
}
@end
