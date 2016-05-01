//
//  MainViewController.m
//  MXPhotoPickerController
//
//  Created by 韦纯航 on 16/5/1.
//  Copyright © 2016年 韦纯航. All rights reserved.
//

#import "MainViewController.h"

#import "MXPhotoPickerController/UIViewController+MXPhotoPicker.h"

#import <Masonry/Masonry.h>

#define WEAKSELF typeof(self) __weak weakSelf = self;

@interface MainViewController ()

@property (retain, nonatomic) UIImageView *imageView;

@end

@implementation MainViewController

- (void)loadView {
    [super loadView];
    
    UIButton *firstButton = [self buttonWithTitle:@"打开图库（单选）"];
    [firstButton addTarget:self action:@selector(openMXImagePickerControllerEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *secondButton = [self buttonWithTitle:@"打开图库（多选）"];
    [secondButton addTarget:self action:@selector(openMXImagePickerControllerMutableEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    self.imageView = [[UIImageView alloc] init];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.layer.borderWidth = 1.0;
    self.imageView.layer.borderColor = MX_TINTCOLOR.CGColor;
    
    [self.view addSubview:firstButton];
    [self.view addSubview:secondButton];
    [self.view addSubview:self.imageView];
    
    WEAKSELF
    [secondButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.view).offset(20.0);
        make.right.equalTo(weakSelf.view).offset(-20.0);
        make.bottom.equalTo(weakSelf.view).offset(-20.0);
        make.height.mas_equalTo(60.0);
    }];
    
    [firstButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.height.equalTo(secondButton);
        make.bottom.equalTo(secondButton.mas_top).offset(-20.0);
    }];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(firstButton);
        make.top.equalTo(weakSelf.view).offset(20.0 + 64.0);
        make.bottom.equalTo(firstButton.mas_top).offset(-20.0);
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"MXPhotoPickerController";
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIButton *)buttonWithTitle:(NSString *)title
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundColor:MX_TINTCOLOR];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    return button;
}

- (void)openMXImagePickerControllerEvent:(UIButton *)button
{
    WEAKSELF
    [self showMXPhotoPickerWithTitle:nil needToEdit:YES completion:^(UIImage *image, UIImage *originImage, CGRect cutRect) {
        weakSelf.imageView.image = image;
    }];
}

- (void)openMXImagePickerControllerMutableEvent:(UIButton *)button
{
    WEAKSELF
    [self showMXPickerWithMaximumPhotosAllow:9 completion:^(NSArray *assets) {
        NSLog(@"assets = %@", assets);
        
        if (assets.count > 0) {
            ALAsset *asset = assets.firstObject;
            
            //全屏分辨率图片
            UIImage *image = [UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage];
            
            /*
             //原始分辨率图片
             CGFloat scale = asset.defaultRepresentation.scale;
             UIImageOrientation orientation = (UIImageOrientation)asset.defaultRepresentation.orientation;
             UIImage *image = [UIImage imageWithCGImage:asset.defaultRepresentation.fullResolutionImage scale:scale orientation:orientation];
             */
            
            weakSelf.imageView.image = image;
        }
    }];
}

@end
