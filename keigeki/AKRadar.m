//
//  AKRadar.m
//  keigeki:傾撃
//
//  Created by 金田 明浩 on 2012/08/14.
//  Copyright 2012 KANEDA Akihiro. All rights reserved.
//

#import "AKRadar.h"
#import "AKCharacter.h"

@implementation AKRadar

@synthesize radarImage = m_radarImage;
@synthesize markerImage = m_markerImage;

/*!
 @method オブジェクト生成処理
 @abstruct オブジェクトの生成を行う。
 @return 生成したオブジェクト。失敗時はnilを返す。
 */
- (id)init
{
    int i = 0;              // ループ変数
    CCSprite *marker = nil; // マーカーの画像
    
    // スーパークラスの生成処理を実行する
    self = [super init];
    if (!self) {
        return nil;
    }
    
    // レーダーの画像を読み込む
    self.radarImage = [CCSprite spriteWithFile:@"Radar.png"];
    assert(self.radarImage != nil);
    
    // レーダーの画像をノードに配置する
    [self addChild:self.radarImage z:0];
    
    // レーダーの位置を設定する
    self.radarImage.position = ccp(RADAR_POS_X, RADAR_POS_Y);
    
    // マーカーを保存する配列を生成する
    self.markerImage = [NSMutableArray arrayWithCapacity:MAX_ENEMY_COUNT];
    
    // マーカーを生成する
    for (i = 0; i < MAX_ENEMY_COUNT; i++) {
        
        // マーカーの画像を読み込む
        marker = [CCSprite spriteWithFile:@"Marker.png"];
        
        // 初期状態は非表示とする
        marker.visible = NO;
        
        // レーダーの上に配置する
        [self.radarImage addChild:marker];
        
        // 配列に登録する
        [self.markerImage addObject:marker];
    }
    
    return self;
}

/*!
 @method インスタンス解放時処理
 @abstruct インスタンス解放時にオブジェクトを解放する。
 */
- (void)dealloc
{
    NSEnumerator *enumerator = nil; // マーカー処理用の列挙子
    CCNode *marker = nil;           // マーカー
    
    // マーカーを解放する
    enumerator = [self.markerImage objectEnumerator];
    for (marker in enumerator) {
        [self.radarImage removeChild:marker cleanup:YES];
    }
    
    // レーダーの画像を解放する
    [self removeChild:self.radarImage cleanup:YES];
    
    // スーパークラスの解放処理を実行する
    [super dealloc];
}

/*!
 @method マーカーの配置位置更新処理
 @abstruct マーカーの配置位置を敵の座標情報から更新する。
 @param enemys 敵情報配列
 @param screenAngle 画面の傾き
 */
- (void)updateMarker:(const NSArray *)enemys ScreenAngle:(float)screenAngle
{
    int i = 0;                  // ループ変数
    AKCharacter *enemy = nil;   // 敵
    CCNode *marker = nil;       // マーカー
    float angle = 0.0f;         // 敵のいる方向
    float posx = 0.0f;          // マーカーのx座標
    float posy = 0.0f;          // マーカーのy座標
    
    // 各敵の位置をマーカーに反映させる
    for (i = 0; i < MAX_ENEMY_COUNT; i++) {
        
        // 配列サイズのチェックを行う
        assert(i < enemys.count);
        assert(i < self.markerImage.count);
        
        // 配列から要素を取得する
        enemy = [enemys objectAtIndex:i];
        marker = [self.markerImage objectAtIndex:i];
        
        // 敵が画面に配置されていない場合はマーカーの表示を消す
        if (!enemy.isStaged) {
            marker.visible = NO;
            continue;
        }
        
        // 自機から見て敵の方向を調べる。
        // 絶対座標ではステージループの問題が発生するため
        // スクリーン座標を使用する。
        angle = AKCalcDestAngle(PLAYER_POS_X, PLAYER_POS_Y, enemy.position.x, enemy.position.y);
        
        // 自機の向いている方向を上向きとする。
        // 上向き(π/2)を0とするので、自機の角度 - π / 2をマイナスする。
        angle -= screenAngle - M_PI / 2;
        
        // 座標を計算する
        // レーダーの中心を原点とするため、xyそれぞれレーダーの幅の半分を加算する。
        posx = ((RADAR_SIZE / 2) * cos(angle)) + (RADAR_SIZE / 2);
        posy = ((RADAR_SIZE / 2) * sin(angle)) + (RADAR_SIZE / 2);
        DBGLOG(0, @"enemy=(%f,%f) angle=%f marker=(%f,%f)", enemy.position.x, enemy.position.y, AKCnvAngleRad2Deg(angle), posx, posy);
        
        // マーカーの配置位置を設定し、表示状態にする。
        marker.position = ccp(posx, posy);
        marker.visible = YES;
    }
}
@end
