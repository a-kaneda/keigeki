//
//  AKCharacterPool.m
//  keigeki:傾撃
//
//  Created by 金田 明浩 on 2012/08/05.
//  Copyright 2012 KANEDA Akihiro. All rights reserved.
//

#import "AKCharacterPool.h"
#import "common.h"

@implementation AKCharacterPool

@synthesize pool = m_pool;

/*!
 @method オブジェクト生成処理
 @abstruct オブジェクトの生成を行う。
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
 @method インスタンス解放時処理
 @abstruct インスタンス解放時にオブジェクトを解放する。
 */
- (void)dealloc
{
    NSEnumerator *enumerator = nil; // キャラクター解放作業用列挙子
    AKCharacter *character = nil;     // キャラクター
    
    // キャラクターのメモリを開放する
    enumerator = [m_pool objectEnumerator];
    for (character in enumerator) {
        [character removeFromParentAndCleanup:YES];
        [character release];
    }
    
    // プールのメモリを解放する
    [m_pool release];
    m_pool = nil;
    
    // スーパークラスの解放処理
    [super dealloc];
}

/*!
 @method 未使用キャラクター取得
 @abstruct キャラクタープールの中から未使用のキャラクターを検索して返す。
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
@end
