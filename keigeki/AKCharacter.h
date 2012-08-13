//
//  AKCharacter.h
//  keigeki:傾撃
//
//  Created by 金田 明浩 on 2012/05/06.
//  Copyright 2012 KANEDA Akihiro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

/*!
 @class キャラクタークラス
 @abstruct 当たり判定を持つオブジェクトの基本クラス。
 */
@interface AKCharacter : CCNode {
    // 画像
    CCSprite *m_image;
    // 当たり判定サイズ幅
    NSInteger m_width;
    // 当たり判定サイズ高さ
    NSInteger m_height;
    // 絶対座標x
    float m_absx;
    // 絶対座標y
    float m_absy;
    // 速度
    float m_speed;
    // 向き
    float m_angle;
    // 回転速度
    float m_rotSpeed;
    // HP
    NSInteger m_hitPoint;
    // ステージ上に存在しているかどうか
    BOOL m_isStaged;
}

@property (nonatomic, retain)CCSprite *image;
@property (nonatomic)NSInteger width;
@property (nonatomic)NSInteger height;
@property (nonatomic)float absx;
@property (nonatomic)float absy;
@property (nonatomic)float speed;
@property (nonatomic)float angle;
@property (nonatomic)float rotSpeed;
@property (nonatomic)NSInteger hitPoint;
@property (nonatomic)BOOL isStaged;

// 移動処理
- (void)move:(ccTime)dt ScreenX:(NSInteger)scrx ScreenY:(NSInteger)scry;
// キャラクター固有の動作
- (void)action:(ccTime)dt;
// 破壊処理
- (void)destroy;

@end
