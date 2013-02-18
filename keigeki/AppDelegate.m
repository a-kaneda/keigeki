/*
 * Copyright (c) 2012-2013 Akihiro Kaneda.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *   1.Redistributions of source code must retain the above copyright notice,
 *     this list of conditions and the following disclaimer.
 *   2.Redistributions in binary form must reproduce the above copyright notice,
 *     this list of conditions and the following disclaimer in the documentation
 *     and/or other materials provided with the distribution.
 *   3.Neither the name of the Monochrome Soft nor the names of its contributors
 *     may be used to endorse or promote products derived from this software
 *     without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */
/*!
 @file AppDelegate.m
 @brief Application controller定義
 
 Application controllerを定義する。
 */

#import "cocos2d.h"
#import "SimpleAudioEngine.h"

#import "AppDelegate.h"
#import "AKTitleScene.h"
#import "AKGameScene.h"
#import "AKGameCenterHelper.h"
#import "AKTwitterHelper.h"
#import "AKInAppPurchaseHelper.h"

/*!
 @brief Application controller
 
 Application controller。
 */
@implementation AppController

@synthesize window=window_, navController=navController_, director=director_;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	// Create the main window
	window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];


	// Create an CCGLView with a RGB565 color buffer, and a depth buffer of 0-bits
	CCGLView *glView = [CCGLView viewWithFrame:[window_ bounds]
								   pixelFormat:kEAGLColorFormatRGB565	//kEAGLColorFormatRGBA8
								   depthFormat:0	//GL_DEPTH_COMPONENT24_OES
							preserveBackbuffer:NO
									sharegroup:nil
								 multiSampling:NO
							   numberOfSamples:0];

	director_ = (CCDirectorIOS*) [CCDirector sharedDirector];

	director_.wantsFullScreenLayout = YES;

	// Display FSP and SPF
	[director_ setDisplayStats:NO];

	// set FPS at 60
	[director_ setAnimationInterval:1.0/60];

	// attach the openglView to the director
	[director_ setView:glView];

	// for rotation and other messages
	[director_ setDelegate:self];

	// 2D projection
	[director_ setProjection:kCCDirectorProjection2D];
//	[director setProjection:kCCDirectorProjection3D];

	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
//	if( ! [director_ enableRetinaDisplay:YES] )
//		CCLOG(@"Retina Display Not supported");

	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];

	// If the 1st suffix is not found and if fallback is enabled then fallback suffixes are going to searched. If none is found, it will try with the name without suffix.
	// On iPad HD  : "-ipadhd", "-ipad",  "-hd"
	// On iPad     : "-ipad", "-hd"
	// On iPhone HD: "-hd"
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
	[sharedFileUtils setEnableFallbackSuffixes:NO];				// Default: NO. No fallback suffixes are going to be used
	[sharedFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];		// Default on iPhone RetinaDisplay is "-hd"
	[sharedFileUtils setiPadSuffix:@"-ipad"];					// Default on iPad is "ipad"
	[sharedFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];	// Default on iPad RetinaDisplay is "-ipadhd"

	// Assume that PVR images have premultiplied alpha
	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
    
    // サウンド再生環境の初期化を行う
    // 他のアプリによるバックグラウンド再生を禁止する
    [CDAudioManager configure:kAMM_FxPlusMusic];
    
    // BGMとSEの音量を下げる
    [SimpleAudioEngine sharedEngine].backgroundMusicVolume = 0.5f;
    [SimpleAudioEngine sharedEngine].effectsVolume = 0.2f;
    
    // Twitterアカウントの認証ダイアログをアプリ起動時に表示するため、
    // ここでTwitter管理クラスのインスタンスを生成する。
    [AKTwitterHelper sharedHelper];

	// and add the scene to the stack. The director will run it when it automatically when the view is displayed.
	[director_ runWithScene:[AKTitleScene node]];
	
	// Create a Navigation Controller with the Director
	navController_ = [[AKNavigationController alloc] initWithRootViewController:director_];
	navController_.navigationBarHidden = YES;
	
	// set the Navigation Controller as the root view controller
//	[window_ addSubview:navController_.view];	// Generates flicker.
	[window_ setRootViewController:navController_];
	
	// make main window visible
	[window_ makeKeyAndVisible];
    
    // Game Centerの認証を行う
    [[AKGameCenterHelper sharedHelper] authenticateLocalPlayer];
        
	return YES;
}

// Supported orientations: Landscape. Customize it for your own needs
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    AKLog(1, @"interfaceOrientation=%d", interfaceOrientation);
    if (UIInterfaceOrientationLandscapeLeft == interfaceOrientation) {
        AKLog(1, @"return YES");
        return YES;
    } else {
        AKLog(1, @"return NO");
        return NO;
    }
}

// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	if( [navController_ visibleViewController] == director_ ) {
		[director_ pause];

        // 実行中のシーンを取得する
        CCScene *scene = [[CCDirector sharedDirector] runningScene];
        
        // ゲームプレイシーンでゲームプレイ中の場合は一時停止状態にする
        if ([scene isKindOfClass:[AKGameScene class]]) {
            
            // ゲームプレイシーンにキャストする
            AKGameScene *gameScene = (AKGameScene *)scene;
            
            // ゲームプレイ中の場合は一時停止状態にする
            if (gameScene.state == kAKGameStatePlaying) {

                // 一時停止する
                [gameScene pause:NO];
                
                // BGMは停止させる
                [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
            }
        }
    }
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ resume];
}

/*!
 @brief Tells the delegate that the application is now in the background.
 
 Tells the delegate that the application is now in the background.
 @param application The singleton application instance.
 */
-(void) applicationDidEnterBackground:(UIApplication*)application
{
    AKLog(1, @"applicationDidEnterBackground start.");
	if( [navController_ visibleViewController] == director_ ) {
		[director_ stopAnimation];
        
    }
}


-(void) applicationWillEnterForeground:(UIApplication*)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ startAnimation];
}

// application will be killed
- (void)applicationWillTerminate:(UIApplication *)application
{
	CC_DIRECTOR_END();
}

// purge memory
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[[CCDirector sharedDirector] purgeCachedData];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void) dealloc
{
	[window_ release];
	[navController_ release];

	[super dealloc];
}
@end

