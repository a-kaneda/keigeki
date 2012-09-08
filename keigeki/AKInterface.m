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
@synthesize enableItemTagStart = m_enableItemTagStart;
@synthesize enableItemTagEnd = m_enableItemTagEnd;

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
    self.enableItemTagStart = 0;
    self.enableItemTagEnd = 0;

    return self;
}

/*!
 @brief 項目数を指定した初期化処理
 
 メニュー項目数を指定した初期化処理。
 @return 初期化したオブジェクト。失敗時はnilを返す。
 */
- (id)initWithCapacity:(NSInteger)capacity
{
    // スーパークラスの初期化処理を実行する
    self = [super init];
    if (!self) {
        return nil;
    }
    
    // メンバの初期化を行う
    self.enableItemTagStart = 0;
    self.enableItemTagEnd = 0;
    
    // メニュー項目格納用配列を生成する
    self.menuItems = [NSMutableArray arrayWithCapacity:capacity];
    
    return self;
}

/*!
 @brief 項目数を指定したコンビニエンスコンストラクタ
 
 メニュー項目を指定したコンビニエンスコンストラクタ。
 @return 生成したオブジェクト。失敗時はnilを返す。
 */
+ (id)interfaceWithCapacity:(NSInteger)capacity
{
    return [[[[self class] alloc] initWithCapacity:capacity] autorelease];
}

/*!
 @brief インスタンス解放時処理
 
 インスタンス解放時にオブジェクトを解放する。
 */
- (void)dealloc
{
    // メンバを解放する
    self.menuItems = nil;
    
    // スーパークラスの解放処理を実行する
    [super dealloc];
}

/*!
 @brief 有効化するタグの取得
 
 有効化するアイテムのタグを取得する。
 タグ1個だけを有効化しているときに使用する。
 @return 有効化するアイテムのタグ
 */
- (NSInteger)enableItemTag
{
    return self.enableItemTagStart;
}

/*!
 @brief 有効化するタグの設定
 
 有効化するアイテムのタグを設定する。
 タグ1個だけを有効化するときに使用する。
 @param enableItemTag 有効化するアイテムのタグ
 */
- (void)setEnableItemTag:(NSInteger)enableItemTag
{
    self.enableItemTagStart = enableItemTag;
    self.enableItemTagEnd = enableItemTag;
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
    
    DBGLOG(0, @"location = (%f, %f)", location.x, location.y);
    
    // 各項目の選択処理を行う
    for (AKMenuItem *item in [self.menuItems objectEnumerator]) {
        
        // 有効な項目で選択されている場合は処理を行う
        if (item.tag >= self.enableItemTagStart &&
            item.tag <= self.enableItemTagEnd &&
            [item isSelectPos:location]) {
            
            DBGLOG(0, @"tag = %d action = %@", item.tag, NSStringFromSelector(item.action));
            
            // 選択されていれば親ノードにイベントを送信する
            [self.parent performSelector:item.action];
            
            return YES;
        }
    }
    
    return NO;
}

@end
