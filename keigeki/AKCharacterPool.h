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
    NSMutableArray *pool_;
    /// キャラクターのクラス
    Class class_;
    /// 配列サイズ
    NSInteger size_;
    /// 次にキャラクターを追加するインデックス
    NSInteger next_;
}

/// キャラクターを管理する配列
@property (nonatomic, retain)NSMutableArray *pool;

// 初期化処理
- (id)initWithClass:(Class)characlass Size:(NSInteger)size;
// 未使用キャラクター取得
- (id)getNext;
// 全キャラクター削除
- (void)reset;
@end
