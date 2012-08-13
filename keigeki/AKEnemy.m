//
//  AKEnemy.m
//  keigeki:傾撃
//
//  Created by 金田 明浩 on 2012/08/09.
//  Copyright 2012 KANEDA Akihiro. All rights reserved.
//

#import "AKEnemy.h"

@implementation AKEnemy

/*!
 @method キャラクター固有の動作
 @abstruct 生成時に指定されたセレクタを呼び出す。
 @param dt フレーム更新間隔
 */
- (void)action:(ccTime)dt
{
    NSNumber *objdt = NULL;     // フレーム更新間隔(オブジェクト版)
    
    // 動作開始からの経過時間をカウントする
    m_time += dt;
    
    // id型として渡すためにNSNumberを作成する
    objdt = [NSNumber numberWithFloat:dt];
    
    // 敵種別ごとの処理を実行
    [self performSelector:m_action withObject:objdt];
}

/*!
 @method 破壊処理
 @abstruct HPが0になったときに敵種別固有の破壊処理を呼び出す。
 */
- (void)destroy
{
    // 敵種別ごとの処理を実行
    [self performSelector:m_destroy];
    
    // 画像の解放
    [self removeChild:m_image cleanup:YES];
    m_image = nil;
}

/*!
 @method 生成処理
 @abstruct 敵キャラを生成する。
 @param x 生成位置x座標
 @param y 生成位置y座標
 @param z 生成位置z座標
 @param angle 敵キャラの初期向き
 @param parent 敵キャラを配置する親ノード
 @param create 種別ごとの生成処理
 */
- (void)createWithX:(NSInteger)x Y:(NSInteger)y Z:(NSInteger)z Angle:(float)angle Parent:(CCNode *)parent CreateSel:(SEL)create
{
    // パラメータの内容をメンバに設定する
    self.absx = x;
    self.absy = y;
    self.angle = angle;
    
    // 配置フラグを立てる
    m_isStaged = YES;
    
    // 動作時間をクリアする
    m_time = 0;
    
    // 種別ごとの固有生成処理を実行する
    [self performSelector:create];
    
    // レイヤーに配置する
    [parent addChild:self z:z];
}
@end
