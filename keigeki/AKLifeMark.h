/*!
 @file AKLifeMark.h
 @brief 残機マーク表示クラス定義
 
 残機マークを表示するクラスを定義する。
 */

#import <Foundation/Foundation.h>
#import "cocos2d.h"

// 残機マーク表示クラス
@interface AKLifeMark : CCNode {
    /// 残機マークの画像配列
    NSMutableArray *m_imageArray;
}

/// 残機マークの画像配列
@property (nonatomic, retain)NSMutableArray *imageArray;

// 表示の更新
- (void)updateImage:(NSInteger)life;

@end
