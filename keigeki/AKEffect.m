/*!
 @file AKEffect.m
 @brief 画面効果クラス定義
 
 爆発等の画面効果を生成するクラスを定義する。
 */

#import "AKEffect.h"
#import "common.h"

/*!
 @brief 画面効果クラス
 
 爆発等の画面効果を生成する。
 */
@implementation AKEffect

/*!
 @brief キャラクター固有の動作
 
 生存時間を経過している場合は画面から取り除く。
 @param dt フレーム更新間隔
 */
- (void)action:(ccTime)dt
{
    DBGLOG(0, @"lifetime=%f dt=%f", m_lifetime, dt);
    DBGLOG(0, @"position=(%f, %f)", self.position.x, self.position.y);
    DBGLOG(0, @"abspos=(%f, %f)", self.absx, self.absy);
    
    // 生存時間を減らす
    m_lifetime -= dt;
    
    // 生存時間がつきた場合は削除する
    if (m_lifetime < 0) {
        DBGLOG(0, @"effect end");
        m_hitPoint = -1.0f;
    }
}

/*!
 @brief 画面効果開始
 
 画面効果を開始する。指定した時間経過後に消滅する。
 @param time 画面効果の生存時間
 @param posx 画面効果の絶対座標x座標
 @param posy 画面効果の絶対座標y座標
 @param posz 画面効果のz座標
 @param parent 追加先のノード
 */
- (void)startEffect:(float)time PosX:(float)posx PosY:(float)posy PosZ:(NSInteger)posz
             Parent:(CCNode *)parent
{
    DBGLOG(0, @"startEffect start : time=%f pos=(%f, %f)", time, posx, posy);

    // メンバにパラメータの内容を設定する
    m_lifetime = time;
    self.absx = posx;
    self.absy = posy;
    
    // 画面配置フラグとHPを設定する
    self.isStaged = YES;
    self.hitPoint = 1;
    
    // 親ノードに追加する
    [parent addChild:self z:posz];
}
@end
