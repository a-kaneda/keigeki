//
//  common.c
//  keigeki
//
//  Created by 金田 明浩 on 12/05/26.
//  Copyright (c) 2012年 KANEDA Akihiro. All rights reserved.
//

#include <stdio.h>
#include <math.h>

/*!
 @function 範囲チェック(実数)
 @abstruct 値が範囲内にあるかチェックし、範囲外にあれば範囲内の値に補正する。
 @param 値
 @param 最小値
 @param 最大値
 @return 補正結果
 */
float RangeCheckF(float val, float min, float max)
{
    // 最小値未満
    if (val < min) {
        return min;
    }
    // 最大値超過
    else if (val > max) {
        return max;
    }
    // 範囲内
    else {
        return val;
    }
}

/*!
 @function 範囲チェック(ループ、 実数)
 @abstruct 値が範囲内にあるかチェックし、範囲外にあれば反対側にループする。
 @param val 値
 @param min 最小値
 @param max 最大値
 @return 補正結果
 */
float RangeCheckLF(float val, float min, float max)
{
    // 最小値未満
    if (val < min) {
        return RangeCheckLF(val + (max - min), min, max);
    }
    // 最大値超過
    else if (val > max) {
        return RangeCheckLF(val - (max - min), min, max);
    }
    // 範囲内
    else {
        return val;
    }
}

/*!
 @function rad角度からスクリーン角度への変換
 @abstruct radianからdegreeへ変換し、上向きを0°とする。時計回りを正とする。
 @param radAngle rad角度
 @return スクリーン角度
 */
float CnvAngleRad2Scr(float radAngle)
{
    float srcAngle = 0.0f;
    
    // radianからdegreeへ変換する
    srcAngle = radAngle / (2 * M_PI) * 360;
    
    // 上向きを0°とするため、90°ずらす。
    srcAngle -= 90;
    
    // 時計回りを正とするため符号を反転する。
    srcAngle *= -1;
    
    return srcAngle;
}