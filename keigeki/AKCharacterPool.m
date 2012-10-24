/*!
 @file AKCharacterPool.m
 @brief キャラクタープールクラス定義
 
 複数のキャラクターのメモリ管理を行うクラスを定義する。
 */

#import "AKCharacterPool.h"
#import "AKCommon.h"

/*!
 @brief キャラクタープールクラス

 複数のキャラクターのメモリ管理を行う。
 */
@implementation AKCharacterPool

@synthesize pool = pool_;

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
    
    AKLog(0, @"class=%@ size=%d", characlass, size);
    
    // スーパークラスの生成処理
    self = [super init];
    if (!self) {
        return nil;
    }
    
    // パラメータをメンバに設定する
    class_ = characlass;
    size_ = size;
    
    // プールの生成
    self.pool = [NSMutableArray arrayWithCapacity:size_];

    // キャラクターの生成
    for (i = 0; i < size_; i++) {
        character = [[[class_ alloc] init] autorelease];
        [pool_ addObject:character];
    }
    
    // 次にキャラクターを生成するインデックスを初期化する
    next_ = 0;
    
    return self;
}

/*!
 @brief インスタンス解放時処理

 インスタンス解放時にオブジェクトを解放する。
 */
- (void)dealloc
{
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
    
    AKLog(0, @"m_size=%d", size_);
    
    // 未使用のキャラクターを検索する
    for (i = 0; i < size_; i++) {
        
        // キャラクターを取得する
        work = [pool_ objectAtIndex:next_];
        
        // インデックスを進める
        next_ = (next_ + 1) % size_;
        
        AKLog(0, @"i=%d work.isStaged=%d", i, work.isStaged);
        
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
            [character.image removeFromParentAndCleanup:YES];
        }
    }
    
    // インデックスを初期化する
    next_ = 0;
}
@end
