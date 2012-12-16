/*!
 @file AKTwitterHelper.h
 @brief Twitter管理
 
 Twitterのツイートを管理するクラスを定義する。
 */

#import <Foundation/Foundation.h>
#import <Accounts/Accounts.h>

/// Twitter設定
enum AKTwitterMode {
    kAKTwitterModeOff = 0,  ///< Twitter連携Off
    kAKTwitterModeManual,   ///< 手動ツイート
    kAKTwitterModeAuto      ///< 自動ツイート
};

/// Twitter管理
@interface AKTwitterHelper : NSObject {
    /// Twitter設定
    enum AKTwitterMode mode_;
    /// Twitterアカウント
    ACAccount *twitterAccount_;
}

/// Twitterアカウント
@property (nonatomic, retain)ACAccount *twitterAccount;

// シングルトンオブジェクト取得
+ (AKTwitterHelper *)sharedHelper;
// Twitter設定取得
- (enum AKTwitterMode)mode;
// Twitter設定変更
- (void)setMode:(enum AKTwitterMode)mode;
// Twitterアカウント取得
- (void)requestAccount;
// Twitter View表示
- (void)viewTwitterWithInitialString:(NSString *)string;
// 自動ツイート
- (void)tweet:(NSString *)string;
@end
