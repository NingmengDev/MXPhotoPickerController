//
//  MXPhotoPickerController.m
//  MXPhotoPickerController
//
//  Created by 韦纯航 on 15/12/8.
//  Copyright © 2015年 韦纯航. All rights reserved.
//

#import "MXPhotoPickerController.h"

#import "MXImageGroupController.h"

#import "MXALAsset.h"

@interface MXPhotoPickerController ()

@end

@implementation MXPhotoPickerController

- (id)init
{
    MXImageGroupController *imageGroupController = [[MXImageGroupController alloc] initWithStyle:UITableViewStylePlain];
    return [super initWithRootViewController:imageGroupController];
}

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    MXImageGroupController *imageGroupController = [[MXImageGroupController alloc] initWithStyle:UITableViewStylePlain];
    return [super initWithRootViewController:imageGroupController];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationBar.tintColor = [UIColor whiteColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleFinishingPickingNotification:) name:MXALAssetDidFinishPickingNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait; //进入相册，只能支持一个屏幕方向
}

- (void)setMaximumNumberOfSelectionalPhotos:(NSInteger)maximumNumberOfSelectionalPhotos
{
    maximumNumberOfSelectionalPhotos = MAX(0, maximumNumberOfSelectionalPhotos);
    _maximumNumberOfSelectionalPhotos = maximumNumberOfSelectionalPhotos;
    
    [MXALAsset instance].maximumNumberOfSelectionalPhotos = _maximumNumberOfSelectionalPhotos;
}

- (void)handleFinishingPickingNotification:(NSNotification *)notification
{
    if (self.finishedDelegate && [self.finishedDelegate respondsToSelector:@selector(imagePickerController:didFinishPickingWithAssets:)]) {
        NSArray *assets = [[MXALAsset instance] allSelectionalAssets];
        [self.finishedDelegate imagePickerController:self didFinishPickingWithAssets:assets];
    }
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion
{
    [super dismissViewControllerAnimated:flag completion:completion]; //关闭界面
    [[MXALAsset instance] clearAllData]; //清空数据，释放内存
    [[NSNotificationCenter defaultCenter] removeObserver:self]; //注销通知
}

- (void)dealloc
{
    NSLog(@"%@ dealloc.", [[self class] description]);
}

@end
