/*!
 @file AKNavigationController.m
 @brief UINavigationControllerのカスタマイズ
 
 UINavigationControllerのカスタマイズクラスを定義する。
 */


#import "AKNavigationController.h"

/*!
 @brief UINavigationControllerのカスタマイズ
 
 UINavigationControllerのカスタマイズ。
 画面回転処理とGame Centerのdelegateを実装。
 */
@implementation AKNavigationController

/*!
 @brief 初期化処理
 
 初期化処理を行う。
 スーパークラスの処理をそのまま実行する。
 @param nibNameOrNil xibファイル名
 @param nibBundleOrNil バンドル
 @return 初期化されたインスタンス
 */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

/*!
 @brief 読み込み時処理
 
 ビューが読み込まれたときの処理。
 スーパークラスの処理をそのまま実行する。
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

/*!
 @brief メモリ不足時の処理
 
 メモリが不足したときの処理。
 スーパークラスの処理をそのまま実行する。
 */
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*!
 @brief 回転可否判定
 
 画面回転処理を行うかどうかを判定する。
 常にYESを返す。
 @return 回転処理を行う場合YES、行わない場合NO
 */
- (BOOL)shouldAutorotate
{
    return YES;
}

/*!
 @brief 回転できる画面の向き
 
 回転できる画面の向きを返す。
 右側にホームボタンを配置した横向きのみを許可する。
 @return 回転できる画面の向き
 */
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeRight;
}

/*!
 @brief Leaderboard終了処理
 
 Leaderboard終了時にLeaderboardを閉じる。
 @param viewController LeaderboardのView Controller
 */
- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
    [self dismissModalViewControllerAnimated:YES];
}

/*!
 @brief Achievements終了処理
 
 Achievemets終了時にAchievementsを閉じる。
 @param viewController AchievementsのView Controller
 */
- (void)achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
    [self dismissModalViewControllerAnimated:YES];
}
@end
