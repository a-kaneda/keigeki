/*!
 @file AKInterface.h
 @brief 画面入力管理クラス
 
 画面のタッチ入力を管理するクラスを定義する。
 */

#import "AKInterface.h"
#import "common.h"

/*!
 @brief 画面入力管理クラス
 
 画面のタッチ入力を管理する。
 */
@implementation AKInterface

@synthesize menuItems = m_menuItems;
@synthesize enableItemTag = m_enableItemTag;

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
    
    // メンバの初期化を行う
    self.enableItemTag = 0;

    return self;
}

/*!
 @brief レイヤー表示時処理
 
 レイヤーが表示された際の処理。タッチイベント処理を開始する。
 */
- (void)onEnter
{
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
    // メニュー項目が登録されていない場合は処理を終了する
    if (self.menuItems == nil) {
        return NO;
    }
    
    // 画面上のタッチ位置を取得する
    CGPoint locationInView = [touch locationInView:[touch view]];
    
    // cocos2dの座標系に変換する
    CGPoint location = [[CCDirector sharedDirector] convertToGL:locationInView];
    
    // 各項目の選択処理を行う
    for (AKMenuItem *item in [self.menuItems objectEnumerator]) {
        
        // 有効な項目で選択されている場合は処理を行う
        if (item.tag == self.enableItemTag && [item isSelectPos:location]) {
            
            DBGLOG(1, @"tag = %d action = %@", item.tag, NSStringFromSelector(item.action));
            
            // 選択されていれば親ノードにイベントを送信する
            [self.parent performSelector:item.action];
            
            return YES;
        }
    }
    
    return NO;
}

@end
