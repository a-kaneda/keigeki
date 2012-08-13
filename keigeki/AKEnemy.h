//
//  AKEnemy.h
//  keigeki:傾撃
//
//  Created by 金田 明浩 on 2012/08/09.
//  Copyright 2012 KANEDA Akihiro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AKCharacter.h"
#import "common.h"

/*!
 @class 敵クラス
 @abstruct 敵キャラクターのクラス。
 */
@interface AKEnemy : AKCharacter {
    // 動作開始からの経過時間(各敵種別で使用)
    ccTime m_time;
    // 動作処理のセレクタ
    SEL m_action;
    // 破壊処理のセレクタ
    SEL m_destroy;
}

// 生成処理
- (void)createWithX:(NSInteger)x Y:(NSInteger)y Z:(NSInteger)z Angle:(float)angle
             Parent:(CCNode*)parent CreateSel:(SEL)create;
@end
