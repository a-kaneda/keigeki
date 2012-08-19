/*!
 @file AKHiScoreFile.h
 @brief ハイスコアファイル管理クラス
 
 ハイスコアのファイル入出力を管理するクラスを定義する。
 */

#import <Foundation/Foundation.h>

/// ファイルバージョン番号
#define HISCORE_VERSION     0x0100
/// ハイスコアファイル名
#define HISCORE_FILENAME    @"hiscore.dat"

/// ファイル入出力構造体
struct HISCOREFILE {
    /// バージョン番号
    unsigned long version;
    /// ハイスコア
    unsigned long hiscore;
};

// ハイスコアファイル管理クラス
@interface AKHiScoreFile : NSObject {
    /// ファイルのデータ
    struct HISCOREFILE m_fileData;
}

/// ハイスコア
@property (nonatomic)unsigned long hiscore;

// ファイルの読み込み
- (void)read;
// ファイルの書き込み
- (void)write;

@end
