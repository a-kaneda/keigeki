/*!
 @file AKScreenSize.m
 @brief 画面サイズ管理クラス
 
 画面サイズ管理クラスを定義する。
 */

#import "AKScreenSize.h"

/*!
 @brief 画面サイズ管理クラス
 
 画面サイズを管理する。
 */
@implementation AKScreenSize

/*!
 @brief 画面サイズ取得
 
 デバイスの画面サイズを取得する。
 @return 画面サイズ
 */
+ (CGSize)screenSize
{
    // Landscapeのため、画面の幅と高さを入れ替えて返す
    return CGSizeMake([[UIScreen mainScreen] bounds].size.height,
                      [[UIScreen mainScreen] bounds].size.width);
}

/*!
 @brief ステージサイズ取得
 
 ゲームステージのサイズを取得する。
 @return ステージサイズ
 */
+ (CGSize)stageSize
{
    // ステージサイズは画面サイズの64倍とする
    const NSInteger kAKStageSizeParam = 64;
    
    return CGSizeMake([AKScreenSize screenSize].width * kAKStageSizeParam,
                      [AKScreenSize screenSize].height * kAKStageSizeParam);
}

/*!
 @brief 中央座標取得
 
 画面の中央の座標を取得する。
 @return 中央座標
 */
+ (CGPoint)center
{
    return CGPointMake([AKScreenSize screenSize].width / 2,
                       [AKScreenSize screenSize].height / 2);
}

/*!
 @brief 左からの比率で座標取得
 
 左からの画面サイズの比率で距離を指定したときのデバイススクリーン座標を返す。
 @return デバイススクリーン座標
 */
+ (NSInteger)positionFromLeftRatio:(float)ratio
{
    return [AKScreenSize screenSize].width * ratio;
}

/*!
 @brief 右からの比率で座標取得
 
 右からの画面サイズの比率で距離を指定したときのデバイススクリーン座標を返す。
 @return デバイススクリーン座標
 */
+ (NSInteger)positionFromRightRatio:(float)ratio
{
    return [AKScreenSize screenSize].width * (1 - ratio);
}

/*!
 @brief 上からの比率で座標取得
 
 上からの画面サイズの比率で距離を指定したときのデバイススクリーン座標を返す。
 @return デバイススクリーン座標
 */
+ (NSInteger)positionFromTopRatio:(float)ratio
{
    return [AKScreenSize screenSize].height * (1 - ratio);
}

/*!
 @brief 下からの比率で座標取得
 
 下からの画面サイズの比率で距離を指定したときのデバイススクリーン座標を返す。
 @return デバイススクリーン座標
 */
+ (NSInteger)positionFromBottomRatio:(float)ratio
{
    return [AKScreenSize screenSize].height * ratio;
}

/*!
 @brief 左からの位置で座標取得
 
 左からの座標で距離を指定したときのデバイススクリーン座標を返す。
 @return デバイススクリーン座標
 */
+ (NSInteger)positionFromLeftPoint:(float)point
{
    return point;
}

/*!
 @brief 右からの位置で座標取得
 
 右からの座標で距離を指定したときのデバイススクリーン座標を返す。
 @return デバイススクリーン座標
 */
+ (NSInteger)positionFromRightPoint:(float)point
{
    return [AKScreenSize screenSize].width - point;
}

/*!
 @brief 上からの位置で座標取得
 
 上からの座標で距離を指定したときのデバイススクリーン座標を返す。
 @return デバイススクリーン座標
 */
+ (NSInteger)positionFromTopPoint:(float)point
{
    return [AKScreenSize screenSize].height - point;
}

/*!
 @brief 下からの位置で座標取得
 
 下からの座標で距離を指定したときのデバイススクリーン座標を返す。
 @return デバイススクリーン座標
 */
+ (NSInteger)positionFromBottomPoint:(float)point
{
    return point;
}

/*!
 @brief 中心からの横方向の位置で座標取得

 中心からの横方向の座標で距離を指定したときのデバイススクリーン座標を返す。
 @return デバイススクリーン座標
 */
+ (NSInteger)positionFromHorizontalCenterPoint:(float)point
{
    return [AKScreenSize center].x + point;
}

/*!
 @brief 中心からの縦方向の位置で座標取得
 
 中心からの縦方向の座標で距離を指定したときのデバイススクリーン座標を返す。
 @return デバイススクリーン座標
 */
+ (NSInteger)positionFromVerticalCenterPoint:(float)point
{
    return [AKScreenSize center].y + point;
}

@end
