//
//  CharacterPool.h
//  keigeki
//
//  Created by 金田 明浩 on 2012/08/05.
//  Copyright 2012 KANEDA Akihiro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Character.h"

/*!
 @class キャラクタープールクラス
 @abstruct 複数のキャラクターのメモリ管理を行う。
 */
@interface CharacterPool : NSObject {
    // キャラクターを管理する配列
    NSMutableArray *m_pool;
    // キャラクターのクラス
    Class m_class;
    // 配列サイズ
    NSInteger m_size;
    // 次にキャラクターを追加するインデックス
    NSInteger m_next;
}

@property (nonatomic, retain)NSMutableArray *pool;

// 初期化処理
- (id)initWithClass:(Class)characlass Size:(NSInteger)size;
// 未使用キャラクター取得
- (id)getNext;
@end
