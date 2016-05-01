//
//  MXALAsset.h
//  MXPhotoPickerController
//
//  Created by 韦纯航 on 15/12/9.
//  Copyright © 2015年 韦纯航. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

typedef void (^MXALAssetGroupsBlock)(NSArray *groups);
typedef void (^MXALAssetImageBlock)(UIImage *image);
typedef void (^MXALAssetsCompletion)(void);

FOUNDATION_EXTERN NSString *const MXALAssetDidFinishPickingNotification;

typedef NS_ENUM(NSInteger, AssetPhotoType)
{
    AssetPhotoTypeThumbnail = 0,
    AssetPhotoTypeAspectRatioThumbnail = 1,
    AssetPhotoTypeFullScreen = 2,
    AssetPhotoTypeFullResolution = 3
};

@interface MXALAsset : NSObject

@property (assign, nonatomic) NSUInteger maximumNumberOfSelectionalPhotos;
@property (assign, readonly, nonatomic) NSUInteger numberOfSelectionalPhotos;
@property (assign, readonly, nonatomic) NSUInteger numberOfAssetsForCurrentGroup;

+ (MXALAsset *)instance;

- (void)setupAlbumGroups:(MXALAssetGroupsBlock)callback;
- (void)setupAlbumAssets:(ALAssetsGroup *)group completion:(MXALAssetsCompletion)completion;

- (void)thumbWithAsset:(ALAsset *)asset result:(MXALAssetImageBlock)callback;
- (void)previewWithAsset:(ALAsset *)asset result:(MXALAssetImageBlock)callback;

- (ALAsset *)assetAtIndex:(NSInteger)index;
- (void)adjustAssetAtIndex:(NSInteger)index completion:(MXALAssetsCompletion)completion;
- (BOOL)isTheSelectionalItem:(NSInteger)item;

- (NSArray *)originalSelectionalIndexs;
- (NSArray *)allSelectionalAssets;

- (void)resetAllSelectionalALAssets;
- (void)clearAllData;

@end
