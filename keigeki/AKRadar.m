//
//  AKRadar.m
//  keigeki:傾撃
//
//  Created by 金田 明浩 on 2012/08/14.
//  Copyright 2012 KANEDA Akihiro. All rights reserved.
//

#import "AKRadar.h"

@implementation AKRadar

@synthesize image = m_image;

/*!
 @method オブジェクト生成処理
 @abstruct オブジェクトの生成を行う。
 @return 生成したオブジェクト。失敗時はnilを返す。
 */
- (id)init
{
    // スーパークラスの生成処理
    self = [super init];
    if (!self) {
        return nil;
    }
    
    // タイルの生成
    self.image = [CCSprite spriteWithFile:@"Radar.png"];
    assert(self.image != nil);
    
    // 画像をノードに配置する
    [self addChild:self.image z:0];
    
    // 位置の設定
    self.image.position = ccp(RADAR_POS_X, RADAR_POS_Y);
    
    return self;
}

/*!
 @method インスタンス解放時処理
 @abstruct インスタンス解放時にオブジェクトを解放する。
 */
- (void)dealloc
{
    // 背景画像の解放
    [self removeChild:self.image cleanup:YES];
    
    // スーパークラスの解放処理
    [super dealloc];
}

@end
