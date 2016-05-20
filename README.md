# sweetlas
Simple and sweet Obj-C category for using Images.xcassets sprite atlas with cocos2d.

## Basic usage

This category allows you to use Apples sprite atlas format with cocos2d.
Which saves you from the trouble of relying on third-party tools to generate and maintain your sprite sheets.

Sprite atlases stored in .xcassets are generated when compiling the app and stored in the apps resource directory.

1. Add a sprite atlas by choosing 'New sprite atlas' when clicking the plus icon in the Images.xcassets browser view.

2. Add your images to the sprite atlas. Note: Sprite atlas seems to only support bitmap formats at the moment.

3. `#import CCSpriteFrameCache+XCAssetsCompatibility.h`

3. Load the sprite frames and the textures by calling: `[[CCSpriteFrameCache sharedSpriteFrameCache] loadSpriteFramesForSpriteAtlasNamed:@"name_of_sprite_atlas"]`

4. Add sprites by referencing the sprite frames as they appear in the .xcassets collection.
i.e: `CCSprite *polygon = [CCSprite spriteWithSpriteFrame:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:@"sprite_name"]]`

