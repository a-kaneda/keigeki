/*!
 @file AKEnemy.m
 @brief 敵クラス定義
 
 敵キャラクターのクラスの定義をする。
 */

#import "AKEnemy.h"
#import "AKGameScene.h"

/*!
 @brief 敵クラス
 
 敵キャラクターのクラス。
 */
@implementation AKEnemy

/*!
 @brief キャラクター固有の動作

 生成時に指定されたセレクタを呼び出す。
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
 @brief 破壊処理

 HPが0になったときに敵種別固有の破壊処理を呼び出す。
 */
- (void)destroy
{
    NSInteger score = 0;    // 加算スコア
    float destAngle = 0.0f; // 敵から自機への角度
    
    // 敵種別ごとの処理を実行
    [self performSelector:m_destroy];
    
    // 敵の向きによって加算するスコアを変える。
    // 後ろを向いている場合が最大とする。
    destAngle = AKCalcDestAngle(self.position.x, self.position.y, PLAYER_POS_X, PLAYER_POS_Y);
    score = ENEMY_SCORE * (2 - cos(destAngle - self.angle));
    
    // スコアを加算する
    [[AKGameScene sharedInstance] addScore:score];
    
    // 画像の解放
    [self removeChild:m_image cleanup:YES];
    m_image = nil;
    
    // スーパークラスの処理を行う
    [super destroy];
}

/*!
 @brief 生成処理

 敵キャラを生成する。
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
