//
//  CCSpriteFrameCache+XCAssetsCompatibility.h
//  Fishy
//
//  Created by Daniel Grönlund on 2016-05-19.
//  Copyright © 2016 Apportable. All rights reserved.
//

#import "cocos2d.h"

@interface CCSpriteFrameCache (XCAssetsCompatibility)
- (void)loadSpriteFramesForSpriteAtlasNamed:(NSString *)spriteAtlasName;
@end
