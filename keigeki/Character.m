//
//  Character.m
//  keigeki
//
//  Created by 金田 明浩 on 12/05/06.
//  Copyright 2012年 KANEDA Akihiro. All rights reserved.
//

#import <math.h>
#import "Character.h"
#import "common.h"

@implementation Character

@synthesize width = m_width;
@synthesize height = m_height;
@synthesize speed = m_speed;
@synthesize angle = m_angle;
@synthesize rotSpeed = m_rotSpeed;
@synthesize hitPoint = m_hitPoint;

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
    m_image = nil;
    m_width = 0;
    m_height = 0;
    m_absx = 0;
    m_absy = 0;
    m_speed = 0.0f;
    m_angle = 0.0f;
    m_rotSpeed = 0.0f;
    m_hitPoint = 0;
    
    // ステージ配置フラグを立てる
    m_isStaged = YES;
    
    return self;
}

/*!
 @method インスタンス解放時処理
 @abstruct インスタンス解放時にオブジェクトを解放する。
 */
- (void)dealloc
{
    // 画像を読み込んでいる場合はスプライトを解放する
    if (m_image != nil) {
        [m_image release];
        m_image = nil;
    }
    
    // スーパークラスの解放処理
    [super dealloc];
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
    float absx = 0.0f;      // 絶対座標x
    float absy = 0.0f;      // 絶対座標y
    float posx = 0.0f;      // スクリーン座標x
    float posy = 0.0f;      // スクリーン座標y
    float velx = 0.0f;      // x方向の速度
    float vely = 0.0f;      // y方向の速度
    float angle = 0.0f;     // 角度

    // 画面に配置されていない場合は無処理
    if (!m_isStaged) {
        return;
    }
    
    // HPが0になった場合は破壊処理を行う
    if (m_hitPoint <= 0) {
        [self destroy];
        return;
    }
    
    // 現在位置、角度の取得
    absx = m_absx;
    absy = m_absy;
    angle = m_angle;
    
    // 向きを更新する
    angle += (m_rotSpeed * dt);
    
    // 速度をx方向、y方向に分解する
    velx = m_speed * cosf(angle);
    vely = m_speed * sinf(angle);
    
    DBGLOG(0, @"angle=%f vx=%f vy=%f", angle / M_PI * 180, velx / m_speed, vely / m_speed);
    
    // 座標の移動
    absx += (velx * dt);
    absy += (vely * dt);
    
    // ステージの外に出ているかチェックする
    absx = RangeCheckLI(absx, STAGE_WIDTH);
    absy = RangeCheckLI(absy, STAGE_HEIGHT);
    
    // 表示位置の計算
    // スクリーン位置中心からの距離 + スクリーンサイズの半分
    // スクリーン位置中心からの距離はステージサイズの半分を超えているときは反対側にいるものとして判定する。
    // これはマーカーの表示のため。
    posx = RangeCheckLI(absx - scrx, STAGE_WIDTH / 2) + SCREEN_WIDTH / 2;
    posy = RangeCheckLI(absy - scry, STAGE_HEIGHT / 2) + SCREEN_HEIGHT / 2;
    
    DBGLOG(0, @"vx=%f vy=%f ax=%f ay=%f px=%f py=%f sx=%d sy=%d", velx, vely, absx, absy, posx, posy, scrx, scry);
    
    // メンバ変数への反映
    m_absx = absx;
    m_absy = absy;
    m_angle = angle;
    
    // 表示座標の設定
    self.position = ccp(posx, posy);
    
    // 回転処理
    [self setRotation:CnvAngleRad2Scr(m_angle)];
}

/*!
 @method 破壊処理
 @abstruct HPが0になったときの処理
 */
- (void)destroy
{
    // ステージ配置フラグを落とす
    m_isStaged = NO;
    
    // 画面から取り除く
    [self removeFromParentAndCleanup:YES];
}
@end
