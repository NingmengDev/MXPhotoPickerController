//
//  MXALAsset.m
//  MXPhotoPickerController
//
//  Created by 韦纯航 on 15/12/9.
//  Copyright © 2015年 韦纯航. All rights reserved.
//

#import "MXALAsset.h"

NSString *const MXALAssetDidFinishPickingNotification = @"MXALAssetDidFinishPicking";

@interface MXALAsset ()

@property (strong, nonatomic) ALAssetsLibrary *assetsLibrary;
@property (strong, nonatomic) NSCache *imageCache;

@property (strong, nonatomic) NSMutableArray *allAssets;
@property (strong, nonatomic) NSMutableIndexSet *selectedIndexSet;

@end

@implementation MXALAsset

+ (MXALAsset *)instance
{
    static id obj;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [self new];
    });
    return obj;
}

#pragma mark - Setter & Getter

- (ALAssetsLibrary *)assetsLibrary
{
    if (_assetsLibrary == nil) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    return _assetsLibrary;
}

- (NSCache *)imageCache
{
    if (_imageCache == nil) {
        _imageCache = [[NSCache alloc] init];
    }
    return _imageCache;
}

- (NSMutableArray *)allAssets
{
    if (_allAssets == nil) {
        _allAssets = [NSMutableArray array];
    }
    return _allAssets;
}

- (NSMutableIndexSet *)selectedIndexSet
{
    if (_selectedIndexSet == nil) {
        _selectedIndexSet = [NSMutableIndexSet indexSet];
    }
    return _selectedIndexSet;
}

- (NSUInteger)numberOfSelectionalPhotos
{
    return self.selectedIndexSet.count;
}

- (NSUInteger)numberOfAssetsForCurrentGroup
{
    return self.allAssets.count;
}

#pragma mark - Public

- (void)setupAlbumGroups:(MXALAssetGroupsBlock)callback
{
    NSMutableArray *groups = [NSMutableArray array];
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            [group setAssetsFilter:[ALAssetsFilter allPhotos]]; //只要图片
            
            NSInteger groupType = [[group valueForProperty:ALAssetsGroupPropertyType] integerValue];
            if (groupType == ALAssetsGroupSavedPhotos) {
                [groups insertObject:group atIndex:0];
            }
            else if (group.numberOfAssets > 0) {
                [groups addObject:group];
            }
        }
        else {
            if (callback) callback([NSArray arrayWithArray:groups]);
            *stop = YES;
        }
        
    } failureBlock:^(NSError *error) {
        if (callback) callback([NSArray arrayWithArray:groups]);
    }];
}

- (void)setupAlbumAssets:(ALAssetsGroup *)group completion:(MXALAssetsCompletion)completion
{
    if (!group || group.numberOfAssets == 0) {
        if (completion) completion();
        return;
    }

    [group setAssetsFilter:[ALAssetsFilter allPhotos]]; //只要图片
    
    typeof(self) __weak weakSelf = self;
    [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (result) {
            [weakSelf.allAssets addObject:result];
        }
        else {
            if (completion) completion();
            *stop = YES;
        }
    }];
}

- (void)thumbWithAsset:(ALAsset *)asset result:(MXALAssetImageBlock)callback
{
    if (asset == nil) {
        if (callback) callback(nil);
        return;
    }

    typeof(self) __weak weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *cacheKey = [NSString stringWithFormat:@"Thumb_%@", asset.defaultRepresentation.filename];
        id thumb = [weakSelf.imageCache objectForKey:cacheKey];
        
        if (thumb && [thumb isKindOfClass:[UIImage class]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (callback) callback(thumb);
            });
        }
        else {
            thumb = [weakSelf imageFromAsset:asset type:AssetPhotoTypeAspectRatioThumbnail];
            [weakSelf.imageCache setObject:thumb forKey:cacheKey];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (callback) callback(thumb);
            });
        }
    });
}

- (void)previewWithAsset:(ALAsset *)asset result:(MXALAssetImageBlock)callback
{
    if (asset == nil) {
        if (callback) callback(nil);
        return;
    }
    
    typeof(self) __weak weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *cacheKey = [NSString stringWithFormat:@"Preview_%@", asset.defaultRepresentation.filename];
        id preview = [weakSelf.imageCache objectForKey:cacheKey];
        
        if (preview && [preview isKindOfClass:[UIImage class]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (callback) callback(preview);
            });
        }
        else {
            NSString *thumbCacheKey = [NSString stringWithFormat:@"Thumb_%@", asset.defaultRepresentation.filename];
            id thumb = [weakSelf.imageCache objectForKey:thumbCacheKey];
            
            if (thumb && [thumb isKindOfClass:[UIImage class]]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (callback) callback(thumb);
                });
            }
            
            preview = [weakSelf imageFromAsset:asset type:AssetPhotoTypeFullScreen];
            [weakSelf.imageCache setObject:preview forKey:cacheKey];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (callback) callback(preview);
            });
        }
    });
}

- (ALAsset *)assetAtIndex:(NSInteger)index
{
    if (index < self.allAssets.count) {
        return self.allAssets[index];
    }
    
    return nil;
}

- (void)adjustAssetAtIndex:(NSInteger)index completion:(MXALAssetsCompletion)completion;
{
    if ([self.selectedIndexSet containsIndex:index]) {
        [self.selectedIndexSet removeIndex:index];
        if (completion) completion();
    }
    else if (self.numberOfSelectionalPhotos < self.maximumNumberOfSelectionalPhotos) {
        [self.selectedIndexSet addIndex:index];
        if (completion) completion();
    }
    else {
        NSString *message = [NSString stringWithFormat:@"你最多只能选择%ld张照片", (long)self.maximumNumberOfSelectionalPhotos];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
        [alertView performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
    }
}

- (BOOL)isTheSelectionalItem:(NSInteger)item
{
    return [self.selectedIndexSet containsIndex:item];
}

- (NSArray *)originalSelectionalIndexs
{
    NSMutableArray *selectionalIndexs = [NSMutableArray array];
    [self.selectedIndexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL * _Nonnull stop) {
        [selectionalIndexs addObject:@(idx)];
    }];
    return [NSArray arrayWithArray:selectionalIndexs];
}

- (NSArray *)allSelectionalAssets
{
    return [self.allAssets objectsAtIndexes:self.selectedIndexSet];
}

- (void)resetAllSelectionalALAssets
{
    [self.allAssets removeAllObjects];
    [self.selectedIndexSet removeAllIndexes];
    [self.imageCache removeAllObjects];
}

- (void)clearAllData
{
    [self resetAllSelectionalALAssets];
    
    [self setAllAssets:nil];
    [self setSelectedIndexSet:nil];
    [self setImageCache:nil];
    [self setAssetsLibrary:nil];
    [self setMaximumNumberOfSelectionalPhotos:0];
}

#pragma mark - Private

- (UIImage *)imageFromAsset:(ALAsset *)asset type:(AssetPhotoType)type
{
    CGImageRef iRef = nil;
    
    if (type == AssetPhotoTypeThumbnail)
        iRef = [asset thumbnail];
    else if (type == AssetPhotoTypeAspectRatioThumbnail)
        iRef = [asset aspectRatioThumbnail];
    else if (type == AssetPhotoTypeFullScreen)
        iRef = [asset.defaultRepresentation fullScreenImage];
    else if (type == AssetPhotoTypeFullResolution)
    {
        NSString *strXMP = asset.defaultRepresentation.metadata[@"AdjustmentXMP"];
        if (strXMP == nil || [strXMP isKindOfClass:[NSNull class]])
        {
            iRef = [asset.defaultRepresentation fullResolutionImage];
            return [UIImage imageWithCGImage:iRef scale:asset.defaultRepresentation.scale orientation:(UIImageOrientation)asset.defaultRepresentation.orientation];
        }
        else {
            NSData *dXMP = [strXMP dataUsingEncoding:NSUTF8StringEncoding];
            CIImage *image = [CIImage imageWithCGImage:asset.defaultRepresentation.fullResolutionImage];
            
            NSError *error = nil;
            NSArray *filterArray = [CIFilter filterArrayFromSerializedXMP:dXMP inputImageExtent:image.extent error:&error];
            if (error) {
                NSLog(@"Error during CIFilter creation: %@", [error localizedDescription]);
            }
            
            for (CIFilter *filter in filterArray) {
                [filter setValue:image forKey:kCIInputImageKey];
                image = [filter outputImage];
            }
            CIContext *context = [CIContext contextWithOptions:nil];
            CGImageRef cgimage = [context createCGImage:image fromRect:[image extent]];
            UIImage *iImage = [UIImage imageWithCGImage:cgimage scale:asset.defaultRepresentation.scale orientation:(UIImageOrientation)asset.defaultRepresentation.orientation];
            return iImage;
        }
    }
    
    return [UIImage imageWithCGImage:iRef];
}

@end
