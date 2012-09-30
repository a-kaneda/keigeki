/*!
 @file AKScreenSize.h
 @brief 画面サイズ管理クラス
 
 画面サイズ管理クラスを定義する。
 */

#import <Foundation/Foundation.h>

// 画面サイズ管理クラス
@interface AKScreenSize : NSObject

// 画面サイズ取得
+ (CGSize)screenSize;
// ステージサイズ取得
+ (CGSize)stageSize;
// 中央座標取得
+ (CGPoint)center;
// 左からの比率で座標取得
+ (float)positionFromLeftRatio:(float)ratio;
// 右からの比率で座標取得
+ (float)positionFromRightRatio:(float)ratio;
// 上からの比率で座標取得
+ (float)positionFromTopRatio:(float)ratio;
// 下からの比率で座標取得
+ (float)positionFromBottomRatio:(float)ratio;
// 左からの位置で座標取得
+ (float)positionFromLeftPoint:(float)point;
// 右からの位置で座標取得
+ (float)positionFromRightPoint:(float)point;
// 上からの位置で座標取得
+ (float)positionFromTopPoint:(float)point;
// 下からの位置で座標取得
+ (float)positionFromBottomPoint:(float)point;
// 中心からの横方向の位置で座標取得
+ (float)positionFromHorizontalCenterPoint:(float)point;
// 中心からの縦方向の位置で座標取得
+ (float)positionFromVerticalCenterPoint:(float)point;
@end
