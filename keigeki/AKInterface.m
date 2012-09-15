/*!
 @file AKInterface.h
 @brief 画面入力管理クラス
 
 画面のタッチ入力を管理するクラスを定義する。
 */

#import "AKInterface.h"
#import "common.h"
#import "AKLabel.h"

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

/*!
 @brief 画像ファイルからメニュー項目作成
 
 画像ファイルを読み込んでスプライトを作成し、同じ位置にメニュー項目を作成する。
 @param filename 画像ファイル名
 @param pos メニュー項目の位置
 @param action ボタンタップ時の処理
 @param z メニュー項目のz座標
 @param tag メニュー項目のタグ
 */
- (void)addMenuWithFile:(NSString *)filename atPos:(CGPoint)pos action:(SEL)action z:(NSInteger)z tag:(NSInteger)tag
{
    // メニュー項目の位置と大きさ
    CGRect rect;
    
    // ファイル名が指定されている場合は画像ファイルを読み込む
    if (filename != nil) {
        
        // ボタンの画像を読み込む
        CCSprite *item = [CCSprite spriteWithFile:filename];
        assert(item != nil);
        
        // ボタンの位置を設定する
        item.position = pos;
        
        // ボタンをレイヤーに配置する
        [self addChild:item z:z tag:tag];
        
        // メニュー項目の大きさにスプライトのサイズを設定する
        rect.size = item.contentSize;
        
        // メニュー項目の位置をスプライトの左上の端を設定する
        rect.origin = ccp(item.position.x - item.contentSize.width / 2,
                          item.position.y - item.contentSize.height / 2);
    }
    // ファイル名が指定されていない場合、メニュー項目の位置と大きさは画面全体とする
    else {
        rect = CGRectMake(0, 0, kAKScreenSize.width, kAKScreenSize.height);
    }
    
    // メニュー項目を追加する
    [self.menuItems addObject:[AKMenuItem itemWithRect:rect
                                                action:action
                                                   tag:tag]];
}

/*!
 @brief メニュー項目の追加
 
 メニュー項目のラベルを作成し、インターフェースに項目を追加する。
 @param menuString メニューのキャプション
 @param pos メニューの位置
 @param isCenter 中央揃えにするかどうか
 @param action メニュー選択時の処理
 @param z メニュー項目のz座標
 @param tag メニュー項目のタグ
 */
- (void)addMenuWithString:(NSString *)menuString atPos:(CGPoint)pos isCenter:(BOOL)isCenter
                   action:(SEL)action z:(NSInteger)z tag:(NSInteger)tag
{
    // ラベルを作成する
    AKLabel *label = [AKLabel labelWithString:menuString maxLength:menuString.length maxLine:1 hasFrame:NO];
    
    // ラベルの位置を設定する
    label.position = pos;
    
    // 中央揃えの場合は左へ幅の半分移動する
    if (isCenter) {
        label.position = ccp(label.position.x - label.width / 2, label.position.y);
    }
    
    // ラベルを画面に配置する
    [self addChild:label z:z tag:tag];
    
    // メニュー項目をインターフェースに追加する
    [self.menuItems addObject:[AKMenuItem itemWithRect:label.rect action:action tag:tag]];
}
@end
