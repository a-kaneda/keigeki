/*!
 @file AKPlayerShot.h
 @brief 自機弾クラス定義
 
 自機弾を管理するクラスを定義する。
 */

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "AKShot.h"

/// 自機弾のスピード
#define PLAYER_SHOT_SPEED   1200
/// 自機弾の幅
#define PLAYER_SHOT_WIDTH   2
/// 自機弾の高さ
#define PLAYER_SHOT_HEIGHT  8

// 自機弾クラス
@interface AKPlayerShot : AKShot {
    
}

@end
