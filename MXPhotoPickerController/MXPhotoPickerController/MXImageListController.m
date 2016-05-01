//
//  MXImageListController.m
//  MXPhotoPickerController
//
//  Created by 韦纯航 on 15/12/9.
//  Copyright © 2015年 韦纯航. All rights reserved.
//

#import "MXImageListController.h"

#import "MXImagePreviewController.h"

#import "MXALAsset.h"

#pragma mark - MXImageListCell

@interface MXImageListCell : UICollectionViewCell

@property (retain, nonatomic) UIImageView *imageView;
@property (retain, nonatomic) UIButton *stateView;

@property (assign, nonatomic) NSInteger indexPathItem;

@end

@implementation MXImageListCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        self.imageView = [[UIImageView alloc] init];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        
        self.stateView = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.stateView setImage:[UIImage imageNamed:@"mx_pic_selected_no.png"] forState:UIControlStateNormal];
        [self.stateView setImage:[UIImage imageNamed:@"mx_pic_selected_yes.png"] forState:UIControlStateSelected];
        
        [self.contentView addSubview:self.imageView];
        [self.contentView addSubview:self.stateView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect rect = self.contentView.bounds;
    
    [self.imageView setFrame:rect];
    
    CGFloat x, y, w, h;
    w = MIN(ceilf(CGRectGetHeight(rect) / 2), 44.0);
    h = w;
    x = CGRectGetWidth(rect) - w;
    y = 0.0;

    [self.stateView setFrame:(CGRect){x, y, w, h}];
}

- (void)setIndexPathItem:(NSInteger)indexPathItem
{
    _indexPathItem = indexPathItem;
    _stateView.tag = indexPathItem;
}

@end

#pragma mark - MXImageListBottomBar

@interface MXImageListBottomBar : UIView

@property (retain, nonatomic) UIButton *previewButton;
@property (retain, nonatomic) UILabel *stateLabel;
@property (retain, nonatomic) UIButton *finishButton;

- (void)adjustEnabledState;

@end

@implementation MXImageListBottomBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:250/255.0 alpha:1.0];
        
        self.previewButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.previewButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.previewButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        [self.previewButton setTitle:@"预览" forState:UIControlStateNormal];
        
        self.stateLabel = [[UILabel alloc] init];
        self.stateLabel.textAlignment = NSTextAlignmentCenter;
        
        self.finishButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.finishButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.finishButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        [self.finishButton setTitle:@"完成" forState:UIControlStateNormal];
        
        [self addSubview:self.previewButton];
        [self addSubview:self.stateLabel];
        [self addSubview:self.finishButton];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, [UIColor lightGrayColor].CGColor);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, rect.origin.x, rect.origin.y);
    CGContextAddLineToPoint(context, rect.size.width, rect.origin.y);
    CGContextStrokePath(context);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect rect = self.bounds;
    rect.size.width = 60.0;
    [self.previewButton setFrame:rect];
    
    rect.size.width = 80.0;
    rect.origin.x = (CGRectGetWidth(self.bounds) - rect.size.width) / 2;
    [self.stateLabel setFrame:rect];
    
    rect.size.width = CGRectGetWidth(self.previewButton.frame);
    rect.origin.x = CGRectGetWidth(self.bounds) - rect.size.width;
    [self.finishButton setFrame:rect];
}

- (void)adjustEnabledState
{
    BOOL enabled = ([MXALAsset instance].numberOfSelectionalPhotos > 0);
    self.previewButton.enabled = enabled;
    self.finishButton.enabled = enabled;
    self.stateLabel.textColor = enabled ? [UIColor blackColor] : [UIColor lightGrayColor];
    
    self.stateLabel.text = [NSString stringWithFormat:@"%ld/%ld", (long)[MXALAsset instance].numberOfSelectionalPhotos, (long)[MXALAsset instance].maximumNumberOfSelectionalPhotos];
}

@end

#pragma mark - MXImageListController

@interface MXImageListController () <UICollectionViewDataSource, UICollectionViewDelegate, MXImagePreviewControllerDelegate>

@property (retain, nonatomic) UICollectionView *collectionView;
@property (retain, nonatomic) MXImageListBottomBar *bottomBar;

@end

@implementation MXImageListController

static NSString *const CellIdentifier = @"MXImageListCell";

- (void)loadView {
    [super loadView];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.sectionInset = UIEdgeInsetsMake(5.0, 5.0, 5.0, 5.0);
    flowLayout.minimumInteritemSpacing = 0.0;
    flowLayout.minimumLineSpacing = 5.0;
    
    CGFloat itemWidth = (CGRectGetWidth([UIScreen mainScreen].bounds) - flowLayout.sectionInset.left - flowLayout.sectionInset.right - 5.0 * 3) / 4;
    itemWidth = floorf(itemWidth);
    flowLayout.itemSize = CGSizeMake(itemWidth, itemWidth);

    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.collectionView.contentInset = (UIEdgeInsets){0.0, 0.0, 44.0 + flowLayout.sectionInset.bottom, 0.0};
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.collectionView registerClass:[MXImageListCell class] forCellWithReuseIdentifier:CellIdentifier];
    [self.view addSubview:self.collectionView];
    
    self.bottomBar = [[MXImageListBottomBar alloc] init];
    [self.bottomBar.previewButton addTarget:self action:@selector(previewButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomBar.finishButton addTarget:self action:@selector(finishButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.bottomBar];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [self.selectedGroup valueForProperty:ALAssetsGroupPropertyName];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(rightItemEvent:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    [self.bottomBar adjustEnabledState];
    
    typeof(self) __weak weakSelf = self;
    [[MXALAsset instance] setupAlbumAssets:self.selectedGroup completion:^{
       [weakSelf.collectionView reloadData];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGRect rect = self.view.bounds;
    rect.size.height = 44.0;
    rect.origin.y = CGRectGetHeight(self.view.bounds) - rect.size.height;
    [self.bottomBar setFrame:rect];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.navigationController.isNavigationBarHidden) {
        [self.navigationController setNavigationBarHidden:NO];
    }
}

#pragma mark - Control Event

- (void)rightItemEvent:(UIBarButtonItem *)item
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)previewButtonEvent:(UIButton *)button
{
    MXImagePreviewController *imagePreviewController = [[MXImagePreviewController alloc] initWithSelectionalItemsOnly];
    imagePreviewController.delegate = self;
    [self.navigationController pushViewController:imagePreviewController animated:YES];
}

- (void)finishButtonEvent:(UIButton *)button
{
    [[NSNotificationCenter defaultCenter] postNotificationName:MXALAssetDidFinishPickingNotification object:nil];
}

- (void)stateViewEvent:(UIButton *)button
{
    NSInteger index = button.tag;
    [self adjustAssetAtIndex:index];
}

#pragma mark - Custom Method

- (void)adjustAssetAtIndex:(NSInteger)index
{
    typeof(self) __weak weakSelf = self;
    [[MXALAsset instance] adjustAssetAtIndex:index completion:^{
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
        [weakSelf.collectionView reloadItemsAtIndexPaths:@[indexPath]];
        
        [weakSelf.bottomBar adjustEnabledState];
    }];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [MXALAsset instance].numberOfAssetsForCurrentGroup;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MXImageListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    [cell.stateView addTarget:self action:@selector(stateViewEvent:) forControlEvents:UIControlEventTouchUpInside];
    [cell setIndexPathItem:indexPath.item];
    
    BOOL isSelectionalItem = [[MXALAsset instance] isTheSelectionalItem:indexPath.item];
    [cell.stateView setSelected:isSelectionalItem];
    
    ALAsset *asset = [[MXALAsset instance] assetAtIndex:indexPath.item];
    [[MXALAsset instance] thumbWithAsset:asset result:^(UIImage *thumbImage) {
        if (cell.indexPathItem == indexPath.item) cell.imageView.image = thumbImage;
    }];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    MXImagePreviewController *imagePreviewController = [[MXImagePreviewController alloc] initWithStartingItem:indexPath.item];
    imagePreviewController.delegate = self;
    [self.navigationController pushViewController:imagePreviewController animated:YES];
}

#pragma mark - MXImagePreviewControllerDelegate

- (void)didChangeItemSelectionalState:(MXImagePreviewController *)imagePreviewController
{
    NSArray *visibleIndexPaths = [self.collectionView indexPathsForVisibleItems];
    [self.collectionView reloadItemsAtIndexPaths:visibleIndexPaths];
    
    [self.bottomBar adjustEnabledState];
}

@end
