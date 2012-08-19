/*!
 @file AKHiScoreFile.m
 @brief ハイスコアファイル管理クラス
 
 ハイスコアのファイル入出力を管理するクラスを定義する。
 */

#import "AKHiScoreFile.h"
#import "common.h"

/*!
 @brief ハイスコアファイル管理クラス
 
 ハイスコアのファイル入出力を管理する。
 */
@implementation AKHiScoreFile

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
    m_fileData.version = HISCORE_VERSION;
    m_fileData.hiscore = 0;

    return self;
}

/*!
 @brief ハイスコア取得
 
 ハイスコアを取得する。
 @return ハイスコア
 */
- (unsigned long)hiscore
{
    return m_fileData.hiscore;
}

/*!
 @brief ハイスコア設定
 
 ハイスコアを設定する。
 @param hiscore ハイスコア
 */
- (void)setHiscore:(unsigned long)hiscore
{
    m_fileData.hiscore = hiscore;
}

/*!
 @brief ファイルの読み込み
 
 ハイスコアファイルを読み込む。
 */
- (void)read
{
    NSString *homeDir = nil;    // ホームディレクトリ
    NSString *docDir = nil;     // ドキュメントディレクトリ
    NSString *filePath = nil;   // ファイルパス
    NSData *data = nil;         // ファイルデータ
    struct HISCOREFILE *dataStruct = NULL;  // ファイルデータ構造体
    
    // HOMEディレクトリのパスを取得する
    homeDir = NSHomeDirectory();
    
    // Documentsディレクトリへのパスを作成する
    docDir = [homeDir stringByAppendingPathComponent:@"Documents"];
    
    // ファイルパスを作成する
    filePath = [docDir stringByAppendingPathComponent:HISCORE_FILENAME];
    
    // ファイルを読み込む
    data = [NSData dataWithContentsOfFile:filePath];
    
    // ファイルが読み込めた場合はデータを取得する
    if (data != nil) {
        
        // ファイル入出力構造体にキャストする
        dataStruct = (struct HISCOREFILE *)[data bytes];
        
        // メンバに読み込む
        m_fileData.hiscore = dataStruct->hiscore;
        DBGLOG(0, @"hiscore = %lu", m_fileData.hiscore);
    }
}

/*!
 @brief ファイルの書き込み
 
 ハイスコアをファイルに書き込む。
 */
- (void)write
{
    NSString *homeDir = nil;    // ホームディレクトリ
    NSString *docDir = nil;     // ドキュメントディレクトリ
    NSString *filePath = nil;   // ファイルパス
    NSData *data = nil;         // ファイルデータ
    
    // HOMEディレクトリのパスを取得する
    homeDir = NSHomeDirectory();
    
    // Documentsディレクトリへのパスを作成する
    docDir = [homeDir stringByAppendingPathComponent:@"Documents"];
    
    // ファイルパスを作成する
    filePath = [docDir stringByAppendingPathComponent:HISCORE_FILENAME];
    
    DBGLOG(0, @"hiscore = %lu", m_fileData.hiscore);

    // 書き込み用データを作成する
    data = [NSData dataWithBytes:&m_fileData length:sizeof(m_fileData)];
    
    // ファイルを書き込む
    [data writeToFile:filePath atomically:YES];
}
@end
