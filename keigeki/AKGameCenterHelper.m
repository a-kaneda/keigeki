/*!
 @file AKGameCenterHelper.m
 @brief Game Center管理
 
 Game Centerの入出力を管理するクラスを定義する。
 */

#import "AKGameCenterHelper.h"
#import "AKNavigationController.h"
#import "common.h"

/// 実績ノーミスクリアのID
NSString *kAKGCNoMissID = @"keigeki_no_miss";
/// 実績短時間クリアのID
NSString *kAKGCShortTimeID = @"keigeki_short_time";
/// 実績背後からの撃墜のID
NSString *kAKGCBackShootID = @"keigeki_back_shoot";
/// 実績命中率100%のID
NSString *kAKGCInfallibleShoot = @"keigeki_infallible_shoot";
/// 実績1UPのID
NSString *kAKGC1UpID = @"keigeki_1up";
/// 実績プレイ回数のID
NSString *kAKGCPlayCountID = @"keigeki_play_count";

/// 解除済みの実績を保存するファイル
static NSString *kAKGCLocalAchievementsFile = @"LocalAchievements.dat";
/// 解除済みの実績をアーカイブする時のキー
static NSString *kAKGCLocalAchievementsKey = @"LocalAchievements";
/// 送信に失敗した実績とスコアを保存するファイル
static NSString *kAKGCSendErrorDataFile = @"SendErrorData.dat";
/// 送信に失敗した実績をアーカイブする時のキー
static NSString *kAKGCSendErrorAchievementsKey = @"SendErrorAchievements";
/// 送信に失敗したスコアをアーカイブする時のキー
static NSString *kAKGCSendErrorScore = @"SendErrorScore";
/// 傾撃ハイスコアのカテゴリ
static NSString *kAKGCScoreID = @"keigeki_score";
/// 実績ステージクリアのIDフォーマット
static NSString *kAKGCStargeClearID = @"keigeki_stage%d_clear";

/*!
 @brief GameCenter管理
 
 Game Centerの入出力を管理する。
 */
@implementation AKGameCenterHelper

// シングルトンオブジェクト
static AKGameCenterHelper *sharedHelper_ = nil;

// 解除済みの実績
@synthesize localAchievements = localAchievments_;

/*!
 @brief シングルトンオブジェクト取得
 
 シングルトンオブジェクトを取得する。
 まだ生成されていない場合は生成を行う。
 @return シングルトンオブジェクト
 */
+ (AKGameCenterHelper *)sharedHelper
{
    // 他のスレッドで同時に実行されないようにする
    @synchronized(self) {
     
        // シングルトンオブジェクトが生成されていない場合は生成する
        if (!sharedHelper_) {
            sharedHelper_ = [[AKGameCenterHelper alloc] init];
        }
        
        return sharedHelper_;
    }
    
    return nil;
}

/*!
 @brief インスタンス生成処理
 
 インスタンス生成処理。
 シングルトンのため、二重に生成された場合はアサーションを出力する。
 */
+ (id)alloc
{
    // 他のスレッドで同時に実行されないようにする
    @synchronized(self) {

		NSAssert(sharedHelper_ == nil, @"Attempted to allocate a second instance of a singleton.");
        return [super alloc];
    }
    
    return nil;
}

/*!
 @brief インスタンス初期化処理
 
 インスタンス初期化。
 解除済みの実績と送信に失敗した実績とスコアをファイルから読み込む。
 */
- (id)init
{
    // スーパークラスの初期化処理を実行する
    self = [super init];
    if (!self) {
        return nil;
    }
    
    // 解除済みの実績を読み込む
    [self readLocalAchievements];
    
    return self;
}

/*!
 @brief インスタンス解放処理
 
 インスタンス解放処理。
 メンバを解放する。
 */
- (void)dealloc
{
    // 解除済みの実績を解放する
    self.localAchievements = nil;
    
    // スーパークラスの解放処理を実行する
    [super dealloc];
}

/*!
 @brief 解除済みの実績読み込み
 
 ローカルに保存している解除済みの実績をファイルから読み込み、メンバに格納する。
 ファイル読み込みに失敗した場合は空の辞書を作成する。
 */
- (void)readLocalAchievements
{
    // HOMEディレクトリのパスを取得する
    NSString *homeDir = NSHomeDirectory();
    
    // Documentsディレクトリへのパスを作成する
    NSString *docDir = [homeDir stringByAppendingPathComponent:@"Documents"];
    
    // ファイルパスを作成する
    NSString *filePath = [docDir stringByAppendingPathComponent:kAKGCLocalAchievementsFile];
    
    // ファイルを読み込む
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    
    // ファイルが読み込めた場合はデータを取得する
    if (data != nil) {
        
        DBGLOG(1, @"ファイル読み込み成功");
        
        // ファイルからデコーダーを生成する
        NSKeyedUnarchiver *decoder = [[[NSKeyedUnarchiver alloc] initForReadingWithData:data] autorelease];
        
        // 解除済みの実績を保存した辞書を読み込む
        NSMutableDictionary *localAchievements = [decoder decodeObjectForKey:kAKGCLocalAchievementsKey];
        
#ifdef DEBUG
        for (GKAchievement *achievement in [localAchievements objectEnumerator]) {
            DBGLOG(1, @"identifier=%@", achievement.identifier);
        }
#endif
        
        // デコードを完了する
        [decoder finishDecoding];
        
        // 読み込んだ辞書を格納する
        self.localAchievements = localAchievements;
    }
    // ファイルが読み込めなかった場合は新規に辞書を作成する
    else {
        DBGLOG(1, @"ファイル読み込み失敗");
        
        self.localAchievements = [[[NSMutableDictionary alloc] init] autorelease];
    }
}

/*!
 @brief 解除済みの実績書き込み
 
 解除済みの実績をファイルに保存する。
 */
- (void)writeLocalAchievements
{

    DBGLOG(1, @"ファイル書き込み開始");
    
#ifdef DEBUG
    for (GKAchievement *achievement in [self.localAchievements objectEnumerator]) {
        DBGLOG(1, @"identifier=%@", achievement.identifier);
    }
#endif
    
    // HOMEディレクトリのパスを取得する
    NSString *homeDir = NSHomeDirectory();
    
    // Documentsディレクトリへのパスを作成する
    NSString *docDir = [homeDir stringByAppendingPathComponent:@"Documents"];
    
    // ファイルパスを作成する
    NSString *filePath = [docDir stringByAppendingPathComponent:kAKGCLocalAchievementsFile];
    
    // エンコーダーを生成する
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *encoder = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    
    // ファイル内容をエンコードする
    [encoder encodeObject:self.localAchievements forKey:kAKGCLocalAchievementsKey];
    
    // エンコードを完了する
    [encoder finishEncoding];
    
    // ファイルを書き込む
    [data writeToFile:filePath atomically:YES];
}

/*!
 @brief ユーザー認証
 
 ユーザー認証を行う。
 */
- (void)authenticateLocalPlayer
{
    // ローカルプレイヤーを取得する
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    // すでに認証済みならば処理を終了する
    if (localPlayer.isAuthenticated) {
        DBGLOG(1, @"すでに認証済み");
        return;
    }
    
    // 認証を行う
    [localPlayer authenticateWithCompletionHandler:^(NSError *error) {
        
        // 認証ができた場合
        if (localPlayer.isAuthenticated) {
            
            DBGLOG(1, @"Game Center認証に成功");
            
            // 実績データを取得する
            [self loadAchievements];
        }
        
        DBGLOG(!localPlayer.isAuthenticated, @"Game Center認証に失敗");
    }];
}

/*!
 @brief 送信に失敗したデータを再送信する
 
 送信に失敗した内容を再送信する。
 Game Centerから取得した実績になく、ローカルに保存されている実績を送信する。
 @param networkAchievements Game Centerから取得した実績
 */
- (void)reSendData:(NSDictionary *)networkAchievements
{
    // 送信に失敗した実績を送信する
    for (GKAchievement *achievement in [self.localAchievements objectEnumerator]) {
        
        // Game Centerに実績が登録されているいて、達成率がローカルのもの以上の場合は処理しない
        if ([networkAchievements objectForKey:achievement.identifier] != nil) {
            
            GKAchievement *networkAchievement = [networkAchievements objectForKey:achievement.identifier];
            
            // ローカルの実績の達成率とGame Center上の実績の達成率を比較する
            if (achievement.percentComplete <= networkAchievement.percentComplete) {
                continue;
            }
        }
        
        // 通知バナーはオフにする
        achievement.showsCompletionBanner = NO;
        
        // 実績を送信する
        [achievement reportAchievementWithCompletionHandler:^(NSError *error) {
            
            // 送信に失敗した場合のログを出力する
            DBGLOG(error != nil, @"実績送信に失敗:identifier=%@ [%@]", achievement.identifier, [error localizedDescription]);
            
            // 送信に成功した場合のログを出力する
            DBGLOG(error == nil, @"実績送信完了:identifier=%@", achievement.identifier);
        }];
    }
}

/*!
 @brief 実績取得
 
 解除済みの実績をGame Centerから取得する。
 */
- (void)loadAchievements
{
    DBGLOG(1, @"start loadAchievements");
    
    // 実績データを取得する
    [GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *achievements, NSError *error) {
        
        DBGLOG(error != nil, @"error=%@", error.description);
        
        // エラーがない場合は実績をローカル辞書に格納する
        if (error == nil) {
            
            // あとでローカルにのみ存在する実績がないかチェックするために
            // Game Centerの実績の配列を辞書に入れ込む。
            // 作業用辞書を作成する。
            NSMutableDictionary *work = [NSMutableDictionary dictionaryWithCapacity:achievements.count];
            
            for (GKAchievement *achivement in achievements) {
                DBGLOG(1, @"achivement.identifier=%@", achivement.identifier);
                
                // ローカル辞書の実績を検索する
                GKAchievement *localAchievement = [self.localAchievements objectForKey:achivement.identifier];
                
                // ローカル辞書に保存されていない場合は格納する
                if (localAchievement == nil) {
                    DBGLOG(1, @"ローカル辞書に登録");
                    [self.localAchievements setObject:achivement forKey:achivement.identifier];
                }
                // ローカル辞書の達成率が低い場合は入れ替える
                else if (localAchievement.percentComplete < achivement.percentComplete) {
                    [self.localAchievements removeObjectForKey:localAchievement.identifier];
                    [self.localAchievements setObject:achivement forKey:achivement.identifier];
                }
                // その他の場合はローカル辞書はそのままとする
                else {
                    // 無処理
                }
                
                // 作業用辞書に入れる
                [work setObject:achivement forKey:achivement.identifier];
            }
            
            // 送信済み実績データのファイルの内容を更新する
            [self writeLocalAchievements];
            
            // ローカルにのみ存在する実績を再送信する
            [self reSendData:work];
        }
    }];
}

/*!
 @brief ハイスコア送信
 
 ハイスコアをGame Centerに送信する。
 @param score スコア
 */
- (void)reportHiScore:(NSInteger)score
{
    // スコア送信クラスを生成する
    GKScore *scoreReporter = [[[GKScore alloc] initWithCategory:kAKGCScoreID] autorelease];
    
    // スコアを設定する
    scoreReporter.value = score;
    
    // スコアを送信する
    [scoreReporter reportScoreWithCompletionHandler:^(NSError *error) {
        
        // 送信に失敗した場合のログを出力する
        DBGLOG(error != nil, @"ハイスコア送信に失敗:score=%d [%@]", score, [error localizedDescription]);

        // 送信に成功した場合のログを出力する
        DBGLOG(error == nil, @"ハイスコア送信完了:score=%d", score);
    }];
}

/*!
 @brief 実績送信
 
 実績解除をGame Centerに送信する。
 達成率増加分に100%を指定して実績送信処理を呼び出す。
 @param identifier 実績のID
 */
- (void)reportAchievements:(NSString *)identifier
{
    [self reportAchievements:identifier percentIncrement:100.0f];
}

/*!
 @brief 達成率増加分を指定して実績送信
 
 達成率増加分を指定して実績をGame Centerに送信する。
 送信済みの実績データを取得し、達成率を増加させてGame Centerに送信する。
 送信済みの実績データが存在しない場合は新規に作成し、指定された増加分を達成率に設定する。
 送信済みの実績データの達成率がすでに100%の場合は無処理とする。
 達成率が100%未満から100%以上になった場合は100%にして、バナーを表示する。
 送信済み実績データのファイルの内容を更新する。
 @param identifier 実績のID
 @param percent 達成率増加分
 */
- (void)reportAchievements:(NSString *)identifier percentIncrement:(float)percent
{
    // 送信済みの実績データを取得する
    GKAchievement *achievement = [self.localAchievements objectForKey:identifier];
    
    // 送信済みの実績データが存在しない場合は生成する
    if (achievement == nil) {
        
        // 実績データを新規に生成する
        achievement = [[[GKAchievement alloc] initWithIdentifier:identifier] autorelease];
        
        // 達成率は0%とする
        achievement.percentComplete = 0.0f;
        
        // 送信済み実績辞書に登録する
        [self.localAchievements setObject:achievement forKey:achievement.identifier];
    }
    
    // 送信済みの実績の達成率が100%になっていない場合は処理を行う
    if (achievement.percentComplete < 100.0f) {
        
        // 達成率を増加させる
        achievement.percentComplete += percent;
        
        // 100%に到達した場合、送信後にバナーを表示するようにする
        if (achievement.percentComplete >= 100.0f) {
            
            // バナーの表示を有効にする
            achievement.showsCompletionBanner = YES;
            
            // 100%を超えている分は100%に補正する
            achievement.percentComplete = 100.0f;
        }
        
        // 実績を送信する
        [achievement reportAchievementWithCompletionHandler:^(NSError *error) {
            
            // 送信に失敗した場合のログを出力する
            DBGLOG(error != nil, @"実績送信に失敗:identifier=%@ [%@]", identifier, [error localizedDescription]);
            
            // 送信に成功した場合のログを出力する
            DBGLOG(error == nil, @"実績送信完了:identifier=%@ percent=%f", identifier, achievement.percentComplete);
        }];
        
        // 送信済み実績データのファイルの内容を更新する
        [self writeLocalAchievements];
    }
}

/*!
 @brief ステージクリア送信

 ステージクリアの実績解除をGame Centerに送信する。
 ステージ番号から実績のIDを作成し、実績送信処理を呼び出す。
 @param stage クリアしたステージの番号
 */
- (void)reportStageClear:(NSInteger)stage
{
    // ステージ番号から実績のIDを作成する
    NSString *identifier = [NSString stringWithFormat:kAKGCStargeClearID, stage];

    // 実績送信を行う。
    [self reportAchievements:identifier];
}

/*!
 @brief Leaderboard表示
 
 Leaderboardを表示する。
 */
- (void) showLeaderboard
{
    // LeaderboardのView Controllerを生成する
    GKLeaderboardViewController *leaderboard = [[[GKLeaderboardViewController alloc] init] autorelease];
    
    // LeaderboardのView Controllerの生成に失敗した場合は処理を終了する
    if (leaderboard == nil) {
        DBGLOG(1, @"LeaderboardのView Controller生成に失敗");
        return;
    }
    
    // View Controllerを取得する
    AKNavigationController *viewController = (AKNavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    
    // delegateを設定する
    leaderboard.leaderboardDelegate = viewController;
    
    // Leaderboardを表示する
    [viewController presentModalViewController:leaderboard animated:YES];
}

/*!
 @brief Achievements表示
 
 Achievementsを表示する。
 */
- (void)showAchievements
{
    // AchievementsのVew Controllerを生成する
    GKAchievementViewController *achievements = [[[GKAchievementViewController alloc] init] autorelease];
    
    // AchievementsのView Controllerの生成に失敗した場合は処理を終了する
    if (achievements == nil) {
        DBGLOG(1, @"AchievementsのView Controller生成に失敗");
        return;
    }
    
    // View Controllerを取得する
    AKNavigationController *viewController = (AKNavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    
    // delegateを設定する
    achievements.achievementDelegate = viewController;
    
    // Achievementsを表示する
    [viewController presentModalViewController:achievements animated:YES];    
}
@end
