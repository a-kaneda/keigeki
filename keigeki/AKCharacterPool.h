/*!
 @file AKCharacterPool.h
 @brief キャラクタープールクラス定義
 
 複数のキャラクターのメモリ管理を行うクラスを定義する。
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AKCharacter.h"

// キャラクタープールクラス
@interface AKCharacterPool : NSObject {
    /// キャラクターを管理する配列
    NSMutableArray *m_pool;
    /// キャラクターのクラス
    Class m_class;
    /// 配列サイズ
    NSInteger m_size;
    /// 次にキャラクターを追加するインデックス
    NSInteger m_next;
}

/// キャラクターを管理する配列
@property (nonatomic, retain)NSMutableArray *pool;

// 初期化処理
- (id)initWithClass:(Class)characlass Size:(NSInteger)size;
// 未使用キャラクター取得
- (id)getNext;
@end
