/*!
 @file AKGameIFLayer.m
 @brief ゲームプレイ画面インターフェース定義
 
 ゲームプレイ画面のインターフェースを管理するを定義する。
 */

#import "AKGameIFLayer.h"
#import "AKGameScene.h"
#import "common.h"

// 加速度センサーの値を比率換算する
static float Accel2Ratio(float accel);

/*!
 @brief ゲームプレイ画面インターフェースクラス
 
 ゲームプレイ画面のインターフェースを管理する。
 */
@implementation AKGameIFLayer

@synthesize shotButton = m_shotButton;

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
    
    // ショットボタンの画像を読み込む
    self.shotButton = [CCSprite spriteWithFile:@"ShotButton.png"];
    assert(m_shotButton != nil);
    
    // ショットボタンをレイヤーに配置する
    [self addChild:m_shotButton];
    
    // ショットボタンの位置を設定する
    m_shotButton.position = ccp(SHOT_BUTTON_POS_X, SHOT_BUTTON_POS_Y);

    // 加速度センサーを有効にする
    self.isAccelerometerEnabled = YES;
    
    return self;
}

/*!
 @brief インスタンス解放時処理

 インスタンス解放時にオブジェクトを解放する。
 */
- (void)dealloc
{
    // ショットボタンの画像の解放
    [self removeAllChildrenWithCleanup:YES];
    
    // スーパークラスの解放処理
    [super dealloc];
}

/*!
 @brief 加速度情報受信処理

 加速度センサーの情報を受信する。
 @param accelerometer 加速度センサー
 @param acceleration 加速度情報
 */
- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
    float ax = 0.0f;
    float ay = 0.0f;
    
    DBGLOG(0, @"x=%g,y=%g,z=%g",acceleration.x, acceleration.y, acceleration.z);
    
    // 加速度センサーの入力値を-1.0〜1.0の比率に変換
    // 画面を横向きに使用するのでx軸y軸を入れ替える
    // x軸は+-逆なので反転させる
    ax = Accel2Ratio(-acceleration.y);
    ay = Accel2Ratio(acceleration.x);
    
    DBGLOG(0, @"ax=%f,ay=%f", ax, ay);

    // 速度の変更
    [[AKGameScene sharedInstance] movePlayerByVX:ax VY:ay];
}

/*!
 @brief レイヤー表示時処理

 レイヤーが表示された際の処理。タッチイベント処理を開始する。
 */
- (void)onEnter
{
    DBGLOG(0, @"レイヤー表示");
    [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

/*!
 @brief レイヤー非表示時処理

 レイヤーが非表示になった際の処理。タッチイベント処理を終了する。
 */
- (void)onExit
{
    [[[CCDirector sharedDirector] touchDispatcher] removeDelegate:self];
}

/*!
 @brief タッチ開始処理

 タッチが開始されたときの処理。
 @param touch タッチ情報
 @param event イベント情報
 @return タッチイベントをこのメソッドで終了するかどうか
 */
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint locationInView; // タッチ位置。画面上の座標。
    CGPoint location;       // タッチ位置。cocos2dの座標系。
        
    DBGLOG(0, @"タッチ開始");
    
    // ゲームシーンの状態により処理を分岐する
    switch ([AKGameScene sharedInstance].state) {
        case GAME_STATE_PLAYING:    // プレイ中

            // タッチ位置を取得し、cocos2dの座標系に変換する。
            locationInView = [touch locationInView:[touch view]];
            location = [[CCDirector sharedDirector] convertToGL:locationInView];
            
            // タッチ位置判定
            // ショットボタンの内側の場合
            if (location.x >= SHOT_BUTTON_POS_X - SHOT_BUTTON_SIZE / 2 &&
                location.x <= SHOT_BUTTON_POS_X + SHOT_BUTTON_SIZE / 2 &&
                location.y >= SHOT_BUTTON_POS_Y - SHOT_BUTTON_SIZE / 2 &&
                location.y <= SHOT_BUTTON_POS_Y + SHOT_BUTTON_SIZE / 2) {
                
                // 自機弾を発射する
                [[AKGameScene sharedInstance] filePlayerShot];
                DBGLOG(0, "自機弾発射:x=%f y=%f", location.x, location.y);
            }
            
            break;
            
        case GAME_STATE_GAMEOVER:   // ゲームオーバー
            
            // 状態をリセットする
            [[AKGameScene sharedInstance] resetAll];
            
        default:
            break;
    }
    return YES;
}

/*!
 @brief タッチ移動処理

 タッチ場所が移動したときの処理。
 @param touch タッチ情報
 @param event イベント情報
 */
- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    DBGLOG(0, @"タッチ移動");
}

/*!
 @brief タッチ終了処理

 タッチが終了したときの処理。
 @param touch タッチ情報
 @param event イベント情報
 */
- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    DBGLOG(0, @"タッチ終了");        
}

/*!
 @brief タッチキャンセル処理

 タッチがキャンセルされたときの処理。
 @param touch タッチ情報
 @param event イベント情報
 */
- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event
{
    DBGLOG(0, @"タッチキャンセル");
}
@end

/*!
 @brief 加速度センサーの値を比率換算する

 加速度センサーの入力値を最大から最小までの比率に換算する。
 @param accel 加速度センサーの入力値
 @return 比率
 */
static float Accel2Ratio(float accel)
{
    const float MIN_VAL = 0.05f;
    const float MAX_VAL = 0.3f;

    // 最小値未満
    if (accel < -MAX_VAL) {
        return -1.0f;
    }
    // 最大値超過
    else if (accel > MAX_VAL) {
        return 1.0f;
    }
    // 水平状態
    else if (accel > -MIN_VAL && accel < MIN_VAL) { 
        return 0.0f;
    }
    // 傾き負
    else if (accel < 0) {
        return (accel + MIN_VAL) / (MAX_VAL - MIN_VAL);
    }
    // 傾き正
    else {
        return (accel - MIN_VAL) / (MAX_VAL - MIN_VAL);
    }    
}

