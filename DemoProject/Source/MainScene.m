#import "MainScene.h"
#import "CCSpriteFrameCache+XCAssetsCompatibility.h"

@implementation MainScene

- (id)init
{
    self = [super init];
    if (self) {
        [[CCSpriteFrameCache sharedSpriteFrameCache] loadSpriteFramesForSpriteAtlasNamed:@"Sprites"];
        
        CCSprite *star = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"star"]];
        star.positionType = CCPositionTypeNormalized;
        star.position = CGPointMake(0.2, 0.5);
        [self addChild:star];

        CCSprite *polygon = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"polygon"]];
        polygon.positionType = CCPositionTypeNormalized;
        polygon.position = CGPointMake(0.5, 0.5);
        [self addChild:polygon];
        
        CCSprite *triangle = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"triangle"]];
        triangle.positionType = CCPositionTypeNormalized;
        triangle.position = CGPointMake(0.8, 0.5);
        [self addChild:triangle];
    }
    return self;
}
@end
