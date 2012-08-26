/*!
 @file AKHiScoreFile.m
 @brief ハイスコアファイル管理クラス
 
 ハイスコアのファイル入出力を管理するクラスを定義する。
 */

#import "AKHiScoreFile.h"
#import "common.h"

/// ファイルバージョン番号
static const NSInteger kAKDataFileVersion = 0x0100;
/// ファイルバージョン番号キー名
static NSString *kAKVersionKey = @"version";
/// ハイスコアキー名
static NSString *kAKHiScoreKey = @"hiScore";

/*!
 @brief ハイスコアファイル管理クラス
 
 ハイスコアのファイル入出力を管理する。
 */
@implementation AKHiScoreFile

@synthesize hiscore = m_hiScore;

/*!
 @brief オブジェクト生成処理
 
 オブジェクトの生成を行う。
 @return 生成したオブジェクト。失敗時はnilを返す。
 */
- (id)init
{
    // スーパークラスの生成処理を実行する
    self = [super init];
    if (!self) {
        return nil;
    }
    
    // データを初期化する
    m_hiScore = 0;

    return self;
}

/*!
 @brief アーカイブからの初期化
 
 アーカイバからオブジェクトを復元する。
 @param aDecoder アーカイバ
 */
- (id)initWithCoder:(NSCoder *)aDecoder
{
    // スーパークラスの生成処理を実行する
    self = [super init];
    if (!self) {
        return nil;
    }

    // ハイスコア
    m_hiScore = [aDecoder decodeIntegerForKey:kAKHiScoreKey];
    
    return self;
}

/*!
 @brief アーカイブへの格納
 
 アーカイバへオブジェクトを格納する。
 @param aCoder アーカイバ
 */
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    // バージョン番号
    [aCoder encodeInteger:kAKDataFileVersion forKey:kAKVersionKey];
    
    // ハイスコア
    [aCoder encodeInteger:m_hiScore forKey:kAKHiScoreKey];
}
@end
