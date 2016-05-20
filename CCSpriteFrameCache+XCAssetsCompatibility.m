//
//  CCSpriteFrameCache+XCAssetsCompatibility.m
//  Fishy
//
//  Created by Daniel Grönlund on 2016-05-19.
//  Copyright © 2016 Apportable. All rights reserved.
//

#import "CCSpriteFrameCache+XCAssetsCompatibility.h"

@implementation CCSpriteFrameCache (XCAssetsCompatibility)

- (NSDictionary *) dictionaryForResourceName:(NSString *)filename
{
    //NOTE: Some file structure assumptions may be incorrect
    //NOTE: Currently assumes that the asset file is located in project resource root.
    NSString *resourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:[NSString stringWithFormat:@"/%@.atlasc/%@.plist",filename,filename]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:resourcePath]) {
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:resourcePath];
        
        return dict;
    }
    return nil;
}

- (UIImage *)imageForSpriteAtlasName:(NSString *)spriteSheetName resourceName:(NSString *)filename
{
    NSString *resourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:[NSString stringWithFormat:@"/%@.atlasc/%@",spriteSheetName,filename]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:resourcePath]) {
        UIImage *image = [UIImage imageWithContentsOfFile:resourcePath];
        
        return image;
    }
    return nil;
}

- (void)loadSpriteFramesForSpriteAtlasNamed:(NSString *)spriteAtlasName
{
    // Parsing the sprite frame data.
    NSDictionary *dictionary = [self dictionaryForResourceName:spriteAtlasName];
    if (dictionary != nil) {
        NSInteger version = [[dictionary objectForKey:@"version"] integerValue];
        if (version != 1) {
            CCLOG(@"cocos2d: WARNING: Unsupported version of sprite sheet data file version: %ld filename: %@", (long)version, spriteAtlasName);
            return;
        }
        
        int scale = [[UIScreen mainScreen] scale];
        NSString *scaleSuffix = [NSString stringWithFormat:@"@%dx",scale];
        
        NSArray *images = [dictionary objectForKey:@"images"];
        NSArray *imagePaths = [images valueForKeyPath:@"path"];
        NSMutableIndexSet *indexes = [self indexesForImagePaths:imagePaths forFilename:spriteAtlasName withSuffix:scaleSuffix].mutableCopy;
      
        if (indexes.count == 0) {
            // Tries falling back to using @1x graphics if the expected resolution is not found.
            [indexes addIndexes:[self indexesForImagePaths:imagePaths forFilename:spriteAtlasName withSuffix:nil]];
            scaleSuffix = nil;
        }
        
        for (NSDictionary *imageDict in [images objectsAtIndexes:indexes]) {
            NSArray *spriteFrames = [imageDict objectForKey:@"subimages"];
            // Loading the image into texture cache.
            NSString *imageFileName = [imageDict objectForKey:@"path"];
            UIImage *image = [self imageForSpriteAtlasName:spriteAtlasName resourceName:imageFileName];
            
            CCTexture *texture =  [[CCTexture alloc] initWithCGImage:image.CGImage contentScale:scaleSuffix.length > 0 ? [[UIScreen mainScreen] scale] : 1.0];
            for (NSDictionary *frameDict in spriteFrames) {
                [self xcassets_addSpriteFramesWithDictionary:frameDict textureReference:texture scaleSuffix:scaleSuffix];
            }
        }
        
    } else {
         CCLOG(@"cocos2d: WARNING: Plist file not found filename: %@", spriteAtlasName);
    }
}

- (NSIndexSet *)indexesForImagePaths:(NSArray *)imagePaths forFilename:(NSString *)filename withSuffix:(NSString *)scaleSuffix
{
    NSMutableIndexSet *indexes = [[NSMutableIndexSet alloc] init];
    for (NSString * searchString in imagePaths) {
        NSString *strippedString = [searchString stringByDeletingPathExtension];
        strippedString = [strippedString stringByReplacingOccurrencesOfString:filename withString:@""];
        strippedString = [strippedString stringByReplacingCharactersInRange:NSMakeRange(0, 2) withString:@""];
        if ([strippedString isEqualToString:scaleSuffix]) {
            [indexes addIndex:[imagePaths indexOfObject:searchString]];
        }
    }
    return indexes;
}

-(void) xcassets_addSpriteFramesWithDictionary:(NSDictionary*)frameDict textureReference:(id)textureReference scaleSuffix:(NSString *)scaleSuffix
{
    // Re-write of cocos2d implementation for adding sprite frames from dictionary
    NSString *frameName = [[frameDict objectForKey:@"name"] stringByDeletingPathExtension];
    NSString *frameDictKey = frameName;

    if (frameName.length > 3) {
        NSString *resolutionComponent = [frameName substringWithRange:NSMakeRange(frameName.length -3, 3)];
        if ([resolutionComponent isEqualToString:scaleSuffix]) {
            frameDictKey = [frameDictKey stringByReplacingCharactersInRange:NSMakeRange(frameDictKey.length - 3, 3) withString:@""];
        }
        
    }
    // SpriteFrame info
    CGRect rectInPixels;
    BOOL isRotated;
    CGPoint frameOffset;
    CGSize originalSize;
    
    // add real frames

    CCSpriteFrame *spriteFrame=nil;
    
    // get values
    CGSize spriteSize = CCRectFromString([frameDict objectForKey:@"textureRect"]).size;
    CGPoint spriteOffset = CCPointFromString([frameDict objectForKey:@"spriteOffset"]);
    CGSize spriteSourceSize = CCSizeFromString([frameDict objectForKey:@"spriteSourceSize"]);
    CGRect textureRect = CCRectFromString([frameDict objectForKey:@"textureRect"]);
    BOOL textureRotated = [[frameDict objectForKey:@"textureRotated"] boolValue];
    
    // get aliases
    NSArray *aliases = [frameDict objectForKey:@"aliases"];
    for(NSString *alias in aliases) {
        if( [_spriteFramesAliases objectForKey:alias] )
            CCLOGWARN(@"cocos2d: WARNING: an alias with name %@ already exists",alias);
        
        [_spriteFramesAliases setObject:frameDictKey forKey:alias];
    }
    
    // set frame info
    rectInPixels = CGRectMake(textureRect.origin.x, textureRect.origin.y, spriteSize.width, spriteSize.height);
    isRotated = textureRotated;
    frameOffset = spriteOffset;
    originalSize = spriteSourceSize;
    
    NSString *textureFileName = nil;
    CCTexture * texture = nil;
    
    if ( [textureReference isKindOfClass:[NSString class]] )
    {
        textureFileName	= textureReference;
    }
    else if ( [textureReference isKindOfClass:[CCTexture class]] )
    {
        texture = textureReference;
    }
    
    if ( textureFileName )
    {
        spriteFrame = [[CCSpriteFrame alloc] initWithTextureFilename:textureFileName rectInPixels:rectInPixels rotated:isRotated offset:frameOffset originalSize:originalSize];
    }
    else
    {
        spriteFrame = [[CCSpriteFrame alloc] initWithTexture:texture rectInPixels:rectInPixels rotated:isRotated offset:frameOffset originalSize:originalSize];
    }
    
    // add sprite frame
    [_spriteFrames setObject:spriteFrame forKey:frameDictKey];
}


@end
