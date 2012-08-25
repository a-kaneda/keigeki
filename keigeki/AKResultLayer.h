/*!
 @file AKResultLayer.h
 @brief ステージクリア結果レイヤー
 
 ステージクリア結果画面のレイヤーを定義する。
 */

#import <Foundation/Foundation.h>
#import "cocos2d.h"

// ステージクリア結果レイヤー
@interface AKResultLayer : CCNode {
    /// 表示が完了しているかどうか
    BOOL m_isFinish;
}

/// 表示が完了しているかどうか
@property (nonatomic, readonly)BOOL isFinish;

@end
