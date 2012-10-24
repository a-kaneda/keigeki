/*!
 @file AKHiScoreFile.h
 @brief ハイスコアファイル管理クラス
 
 ハイスコアのファイル入出力を管理するクラスを定義する。
 */

#import <Foundation/Foundation.h>

// ハイスコアファイル管理クラス
@interface AKHiScoreFile : NSObject <NSCoding> {
    /// ハイスコア
    NSInteger hiScore_;
}

/// ハイスコア
@property (nonatomic)NSInteger hiscore;

@end
