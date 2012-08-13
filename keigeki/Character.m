//
//  Character.m
//  keigeki
//
//  Created by 金田 明浩 on 12/05/06.
//  Copyright 2012 KANEDA Akihiro. All rights reserved.
//

#import <math.h>
#import "Character.h"
#import "common.h"

@implementation Character

@synthesize image = m_image;
@synthesize width = m_width;
@synthesize height = m_height;
@synthesize speed = m_speed;
@synthesize angle = m_angle;
@synthesize rotSpeed = m_rotSpeed;
@synthesize hitPoint = m_hitPoint;
@synthesize isStaged = m_isStaged;

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
    
    // 各メンバを0で初期化する
    self.image = nil;
    self.width = 0;
    self.height = 0;
    self.absx = 0;
    self.absy = 0;
    self.speed = 0.0f;
    self.angle = 0.0f;
    self.rotSpeed = 0.0f;
    self.hitPoint = 0;
    self.isStaged = NO;
    
    return self;
}

/*!
 @method インスタンス解放時処理
 @abstruct インスタンス解放時にオブジェクトを解放する。
 */
- (void)dealloc
{
    // 画像を読み込んでいる場合はスプライトを解放する
    if (self.image != nil) {
        [self removeChild:m_image cleanup:YES];
        self.image = nil;
    }
    
    // スーパークラスの解放処理
    [super dealloc];
}

/*!
 @method 絶対座標xのgetter
 @abstruct 絶対座標xを返す
 @return 絶対座標x
 */
- (float)absx
{
    return m_absx;
}

/*!
 @method 絶対座標xのsetter
 @abstruct 絶対座標xに値を設定する。ステージサイズの範囲内に収まるように調整する。
 @param 絶対座標x
 */
- (void)setAbsx:(float)absx
{
    // ステージの範囲内に収まるように値を設定する
    m_absx = RangeCheckLF(absx, 0.0f, STAGE_WIDTH);
}

/*!
 @method 絶対座標yのgetter
 @abstruct 絶対座標yを返す
 @return 絶対座標y
 */
- (float)absy
{
    return m_absy;
}

/*!
 @method 絶対座標yのsetter
 @abstruct 絶対座標yに値を設定する。ステージサイズの範囲内に収まるように調整する。
 @param 絶対座標y
 */
- (void)setAbsy:(float)absy
{
    // ステージの範囲内に収まるように値を設定する
    m_absy = RangeCheckLF(absy, 0.0f, STAGE_HEIGHT);
}
/*!
 @method 移動処理
 @abstruct 速度によって位置を移動する。
 @param dt フレーム更新間隔
 @param scrx スクリーン座標x
 @param scry スクリーン座標y
 */
- (void)move:(ccTime)dt ScreenX:(NSInteger)scrx ScreenY:(NSInteger)scry
{
    float posx = 0.0f;      // スクリーン座標x
    float posy = 0.0f;      // スクリーン座標y
    float velx = 0.0f;      // x方向の速度
    float vely = 0.0f;      // y方向の速度

    // 画面に配置されていない場合は無処理
    if (!self.isStaged) {
        return;
    }
    
    // HPが0になった場合は破壊処理を行う
    if (self.hitPoint <= 0) {
        [self destroy];
        return;
    }
        
    // 向きを更新する
    self.angle += (self.rotSpeed * dt);
    
    // 速度をx方向、y方向に分解する
    velx = self.speed * cosf(self.angle);
    vely = self.speed * sinf(self.angle);
    
    DBGLOG(0, @"angle=%f vx=%f vy=%f", self.angle / M_PI * 180, velx / self.speed, vely / self.speed);
    
    // 座標の移動
    self.absx += (velx * dt);
    self.absy += (vely * dt);
        
    // 表示位置の計算
    // スクリーン位置中心からの距離 + スクリーンサイズの半分
    // スクリーン位置中心からの距離はステージサイズの半分を超えているときは反対側にいるものとして判定する。
    // これはマーカーの表示のため。
    posx = RangeCheckLF(self.absx - scrx + SCREEN_WIDTH / 2, -(STAGE_WIDTH / 2), STAGE_WIDTH / 2);
    posy = RangeCheckLF(self.absy - scry + SCREEN_HEIGHT / 2, -(STAGE_HEIGHT / 2), STAGE_HEIGHT / 2);
    
    DBGLOG(0, @"vx=%f vy=%f ax=%f ay=%f px=%f py=%f sx=%d sy=%d", velx, vely, self.absx, self.absy, posx, posy, scrx, scry);
        
    // 表示座標の設定
    self.position = ccp(posx, posy);
    
    // 回転処理
    [self setRotation:CnvAngleRad2Scr(self.angle)];
    
    // キャラクター固有の動作を行う
    [self action:dt];
}

/*!
 @method キャラクター固有の動作
 @abstruct キャラクター種別ごとの動作を行う。
 @param dt フレーム更新間隔
 */
- (void)action:(ccTime)dt
{
    // 派生クラスで動作を定義する
}

/*!
 @method 破壊処理
 @abstruct HPが0になったときの処理
 */
- (void)destroy
{
    // ステージ配置フラグを落とす
    self.isStaged = NO;
    
    // 画面から取り除く
    [self removeFromParentAndCleanup:YES];
}
@end
