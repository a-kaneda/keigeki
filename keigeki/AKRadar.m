/*!
 @file AKRadar.m
 @brief レーダークラス定義
 
 敵のいる方向を示すレーダーを管理するクラスを定義する。
 */

#import "AKRadar.h"
#import "AKCharacter.h"
#import "AKScreenSize.h"
#import "AKGameScene.h"

/// レーダーのサイズ
static const NSInteger kAKRadarSize = 128;
/// レーダーの配置位置
static const CGPoint kAKRadarPos = {400, 190};
/// レーダーの配置位置、右からの位置
static const float kAKRadarPosRightPoint = 80.0f;
/// レーダーの配置位置、上からの位置
static const float kAKRadarPosTopPoint = 130.0f;

/*!
 @brief レーダークラス

 敵のいる方向を示すレーダーを管理するクラス。
 */
@implementation AKRadar

@synthesize radarImage = radarImage_;
@synthesize markerImage = markerImage_;

/*!
 @brief オブジェクト生成処理

 オブジェクトの生成を行う。
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
    self.radarImage.position = ccp([AKScreenSize positionFromRightPoint:kAKRadarPosRightPoint],
                                   [AKScreenSize positionFromTopPoint:kAKRadarPosTopPoint]);
    
    // 自機用のマーカーの画像を読み込む
    marker = [CCSprite spriteWithFile:@"Marker.png"];
    
    // 自機のマーカーはレーダーの中心とする
    marker.position = ccp(kAKRadarSize / 2, kAKRadarSize / 2);
    
    // レーダーの上に配置する
    [self.radarImage addChild:marker];

    // マーカーを保存する配列を生成する
    self.markerImage = [NSMutableArray arrayWithCapacity:kAKMaxEnemyCount];
    
    // マーカーを生成する
    for (i = 0; i < kAKMaxEnemyCount; i++) {
        
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
 @brief インスタンス解放時処理

 インスタンス解放時にオブジェクトを解放する。
 */
- (void)dealloc
{
    // マーカーを解放する
    self.markerImage = nil;
    [self.radarImage removeAllChildrenWithCleanup:YES];
    
    // レーダーの画像を解放する
    [self removeChild:self.radarImage cleanup:YES];
    
    // スーパークラスの解放処理を実行する
    [super dealloc];
}

/*!
 @brief マーカーの配置位置更新処理

 マーカーの配置位置を敵の座標情報から更新する。
 @param enemys 敵情報配列
 @param screenAngle 画面の傾き
 */
- (void)updateMarker:(const NSArray *)enemys ScreenAngle:(float)screenAngle
{
    // 各敵の位置をマーカーに反映させる
    for (int i = 0; i < kAKMaxEnemyCount; i++) {
        
        // 配列サイズのチェックを行う
        assert(i < enemys.count);
        assert(i < self.markerImage.count);
        
        // 配列から要素を取得する
        AKCharacter *enemy = [enemys objectAtIndex:i];
        CCNode *marker = [self.markerImage objectAtIndex:i];
        
        // 敵が画面に配置されていない場合はマーカーの表示を消す
        if (!enemy.isStaged) {
            AKLog(0 && marker.visible, @"visible=NO i=%d", i);
            marker.visible = NO;
            continue;
        }
        
        // 自機から見て敵の方向を調べる。
        // 絶対座標ではステージループの問題が発生するため
        // スクリーン座標を使用する。
        float angle = AKCalcDestAngle(AKPlayerPosX(), AKPlayerPosY(),
                                      enemy.image.position.x, enemy.image.position.y);
        
        // 自機の向いている方向を上向きとする。
        // 上向き(π/2)を0とするので、自機の角度 - π / 2をマイナスする。
        angle -= screenAngle - M_PI / 2;
        
        AKLog(0, @"angle=%f", angle);
        
        // マーカーの向きを計算する
        // 敵の向いている向きから自機の向いている向きをマイナスして画面の向きに補正する
        float makerAngle =  enemy.angle - [AKGameScene getInstance].player.angle + M_PI / 2.0f;
                
        // 座標を計算する
        // レーダーの中心を原点とするため、xyそれぞれレーダーの幅の半分を加算する。
        float posx = ((kAKRadarSize / 2) * cos(angle)) + (kAKRadarSize / 2);
        float posy = ((kAKRadarSize / 2) * sin(angle)) + (kAKRadarSize / 2);
        AKLog(0, @"enemy=(%f,%f) angle=%f marker=(%f,%f)",
               enemy.image.position.x, enemy.image.position.y,
               AKCnvAngleRad2Deg(angle), posx, posy);
        
        // マーカーの配置位置と角度を設定し、表示状態にする。
        marker.position = ccp(posx, posy);
        marker.rotation = AKCnvAngleRad2Scr(makerAngle);
        marker.visible = YES;
    }
}
@end
