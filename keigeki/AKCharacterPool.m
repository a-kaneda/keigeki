/*!
 @file AKCharacterPool.m
 @brief キャラクタープールクラス定義
 
 複数のキャラクターのメモリ管理を行うクラスを定義する。
 */

#import "AKCharacterPool.h"
#import "common.h"

/*!
 @brief キャラクタープールクラス

 複数のキャラクターのメモリ管理を行う。
 */
@implementation AKCharacterPool

@synthesize pool = m_pool;

/*!
 @brief オブジェクト生成処理

 オブジェクトの生成を行う。
 @param characlass 管理するキャラクターのクラス
 @param size 管理するプールのサイズ
 @return 生成したオブジェクト。失敗時はnilを返す。
 */
- (id)initWithClass:(Class)characlass Size:(NSInteger)size
{
    int i = 0;                  // ループ変数
    AKCharacter *character = nil; // キャラクター生成用バッファ
    
    DBGLOG(0, @"class=%@ size=%d", characlass, size);
    
    // スーパークラスの生成処理
    self = [super init];
    if (!self) {
        return nil;
    }
    
    // パラメータをメンバに設定する
    m_class = characlass;
    m_size = size;
    
    // プールの生成
    self.pool = [NSMutableArray arrayWithCapacity:m_size];

    // キャラクターの生成
    for (i = 0; i < m_size; i++) {
        character = [m_class node];
        [m_pool addObject:character];
    }
    
    // 次にキャラクターを生成するインデックスを初期化する
    m_next = 0;
    
    return self;
}

/*!
 @brief インスタンス解放時処理

 インスタンス解放時にオブジェクトを解放する。
 */
- (void)dealloc
{
    NSEnumerator *enumerator = nil; // キャラクター解放作業用列挙子
    AKCharacter *character = nil;   // キャラクター
    
    // キャラクターのメモリを開放する
    enumerator = [self.pool objectEnumerator];
    for (character in enumerator) {
        [character removeFromParentAndCleanup:YES];
    }
    
    // プールのメモリを解放する
    self.pool = nil;
    
    // スーパークラスの解放処理
    [super dealloc];
}

/*!
 @brief 未使用キャラクター取得

 キャラクタープールの中から未使用のキャラクターを検索して返す。
 @return 未使用キャラクター。見つからないときはnilを返す。
 */
- (id)getNext
{
    int i = 0;              // ループ変数
    AKCharacter *ret = nil;   // 戻り値
    AKCharacter *work = nil;  // ワーク変数
    
    DBGLOG(0, @"m_size=%d", m_size);
    
    // 未使用のキャラクターを検索する
    for (i = 0; i < m_size; i++) {
        
        // キャラクターを取得する
        work = [m_pool objectAtIndex:m_next];
        
        // インデックスを進める
        m_next = (m_next + 1) % m_size;
        
        DBGLOG(0, @"i=%d work.isStaged=%d", i, work.isStaged);
        
        // 使用中かどうか調べる
        if (!work.isStaged) {
            // 戻り値に設定する
            ret = work;
            // 処理を終了する
            break;
        }
    }
    
    return ret;
}

/*!
 @brief 全キャラクター削除
 
 すべてのキャラクターを画面から取り除く。
 */
- (void)reset
{
    NSEnumerator *enumerator = nil; // キャラクター解放作業用列挙子
    AKCharacter *character = nil;   // キャラクター
    
    // 各キャラクターを画面から取り除く
    enumerator = [self.pool objectEnumerator];
    for (character in enumerator) {
        
        // 画面上に配置されている場合は削除する
        if (character.isStaged) {
            
            // 配置フラグを落とす
            character.isStaged = NO;
            
            // 親ノードから取り除く
            [character removeFromParentAndCleanup:YES];
        }
    }
    
    // インデックスを初期化する
    m_next = 0;
}
@end
