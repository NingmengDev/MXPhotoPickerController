//
//  MXImagePreviewController.m
//  MXPhotoPickerController
//
//  Created by 韦纯航 on 15/12/10.
//  Copyright © 2015年 韦纯航. All rights reserved.
//

#import "MXImagePreviewController.h"

#import "MXImagePreviewCell.h"

#import "MXALAsset.h"

#pragma mark - MXImagePreviewTopBar

@interface MXImagePreviewTopBar : UIView

@property (retain, nonatomic) UIButton *backButton;
@property (retain, nonatomic) UIButton *stateButton;

@end

@implementation MXImagePreviewTopBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.5];
        
        self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.backButton setImageEdgeInsets:(UIEdgeInsets){0.0, -10.0, 0.0, 0.0}];
        [self.backButton setImage:[UIImage imageNamed:@"mx_picker_back_image.png"] forState:UIControlStateNormal];
        
        self.stateButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.stateButton setImage:[UIImage imageNamed:@"mx_pic_selected_no.png"] forState:UIControlStateNormal];
        [self.stateButton setImage:[UIImage imageNamed:@"mx_pic_selected_yes.png"] forState:UIControlStateSelected];
        
        [self addSubview:self.backButton];
        [self addSubview:self.stateButton];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect rect = self.bounds;
    rect.size.width = rect.size.height;
    [self.backButton setFrame:rect];
    
    rect.origin.x = CGRectGetWidth(self.bounds) - rect.size.width;
    [self.stateButton setFrame:rect];
}

@end

#pragma mark - MXImagePreviewBottomBar

@interface MXImagePreviewBottomBar : UIView

@property (retain, nonatomic) UILabel *stateLabel;
@property (retain, nonatomic) UIButton *finishButton;

- (void)adjustEnabledState;

@end

@implementation MXImagePreviewBottomBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.5];
        
        self.stateLabel = [[UILabel alloc] init];
        self.stateLabel.textColor = [UIColor whiteColor];
        self.stateLabel.textAlignment = NSTextAlignmentCenter;
        
        self.finishButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.finishButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.finishButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        [self.finishButton setTitle:@"完成" forState:UIControlStateNormal];
        
        [self addSubview:self.stateLabel];
        [self addSubview:self.finishButton];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect rect = self.bounds;
    
    rect.size.width = 80.0;
    rect.origin.x = (CGRectGetWidth(self.bounds) - rect.size.width) / 2;
    [self.stateLabel setFrame:rect];
    
    rect.size.width = 60.0;
    rect.origin.x = CGRectGetWidth(self.bounds) - rect.size.width;
    [self.finishButton setFrame:rect];
}

- (void)adjustEnabledState
{
    BOOL enabled = ([MXALAsset instance].numberOfSelectionalPhotos > 0);
    self.finishButton.enabled = enabled;
    self.stateLabel.textColor = enabled ? [UIColor whiteColor] : [UIColor lightGrayColor];
    self.stateLabel.text = [NSString stringWithFormat:@"%ld/%ld", (long)[MXALAsset instance].numberOfSelectionalPhotos, (long)[MXALAsset instance].maximumNumberOfSelectionalPhotos];
}

@end

#pragma mark - MXImagePreviewController

typedef NS_ENUM(NSInteger, MXImagePreviewType)
{
    MXImagePreviewTypeAll = 0,      //预览全部
    MXImagePreviewTypeSelection = 1 //预览选中的
};

@interface MXImagePreviewController () <UICollectionViewDataSource, UICollectionViewDelegate, MXImagePreviewCellDelegate>

@property (retain, nonatomic) UICollectionView *collectionView;
@property (retain, nonatomic) MXImagePreviewTopBar *topBar;
@property (retain, nonatomic) MXImagePreviewBottomBar *bottomBar;

@property (assign, nonatomic) MXImagePreviewType type;
@property (assign, nonatomic) NSInteger startingIndex;
@property (assign, nonatomic) BOOL isToolBarHidden;

@property (copy, nonatomic) NSArray *originalSelectionalIndexs;

@end

@implementation MXImagePreviewController

static NSString *const CellIdentifier = @"MXImagePreviewCell";

- (id)initWithStartingItem:(NSInteger)item
{
    self = [super init];
    if (self) {
        self.startingIndex = item;
        self.type = MXImagePreviewTypeAll;
    }
    return self;
}

- (id)initWithSelectionalItemsOnly
{
    NSArray *originalSelectionalIndexs = [[MXALAsset instance] originalSelectionalIndexs];
    if (originalSelectionalIndexs.count == 0) return nil;
    
    self = [super init];
    if (self) {
        self.startingIndex = 0;
        self.type = MXImagePreviewTypeSelection;
        self.originalSelectionalIndexs = originalSelectionalIndexs;
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    [flowLayout setMinimumLineSpacing:0.0];
    [flowLayout setItemSize:self.view.bounds.size];
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.bounces = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [self.collectionView registerClass:[MXImagePreviewCell class] forCellWithReuseIdentifier:CellIdentifier];
    [self.view addSubview:self.collectionView];
    
    self.topBar = [[MXImagePreviewTopBar alloc] init];
    [self.topBar.backButton addTarget:self action:@selector(backButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.topBar.stateButton addTarget:self action:@selector(stateButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.topBar];
    
    self.bottomBar = [[MXImagePreviewBottomBar alloc] init];
    [self.bottomBar.finishButton addTarget:self action:@selector(finishButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.bottomBar];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    [self.navigationController setNavigationBarHidden:YES];
    
    [self.bottomBar adjustEnabledState];
    
    if ((self.type == MXImagePreviewTypeAll) && (self.startingIndex < [MXALAsset instance].numberOfAssetsForCurrentGroup)) {
        [self.collectionView reloadData];
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.startingIndex inSection:0];
        [self.collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
    }
    
    [self adjustSelectionalStateForCurrentItem];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGRect rect = self.view.bounds;
    rect.size.height = 64.0;
    [self.topBar setFrame:rect];
    
    rect.size.height = 44.0;
    rect.origin.y = CGRectGetHeight(self.view.bounds) - CGRectGetHeight(rect);
    [self.bottomBar setFrame:rect];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Control Event

- (void)backButtonEvent:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)stateButtonEvent:(UIButton *)button
{
    NSInteger index = [self indexOfCurrentItem];
    if (self.type == MXImagePreviewTypeSelection) {
        index = [self.originalSelectionalIndexs[index] integerValue];
    }
    [self adjustAssetAtIndex:index];
}

- (void)finishButtonEvent:(UIButton *)button
{
    [[NSNotificationCenter defaultCenter] postNotificationName:MXALAssetDidFinishPickingNotification object:nil];
}

#pragma mark - Custom Method

- (NSInteger)indexOfCurrentItem
{
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    CGFloat pageWidth = flowLayout.itemSize.width;
    NSInteger index = floor((self.collectionView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    return index;
}

- (void)adjustAssetAtIndex:(NSInteger)index
{
    typeof(self) __weak weakSelf = self;
    [[MXALAsset instance] adjustAssetAtIndex:index completion:^{
        BOOL isSelectionalItem = [[MXALAsset instance] isTheSelectionalItem:index];
        [self.topBar.stateButton setSelected:isSelectionalItem];
        [weakSelf.bottomBar adjustEnabledState];
        
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(didChangeItemSelectionalState:)]) {
            [weakSelf.delegate didChangeItemSelectionalState:weakSelf];
        }
    }];
}

- (void)adjustSelectionalStateForCurrentItem
{
    NSInteger currentItem = [self indexOfCurrentItem];
    if (self.type == MXImagePreviewTypeSelection) {
        currentItem = [self.originalSelectionalIndexs[currentItem] integerValue];
    }
    
    BOOL isSelectionalItem = [[MXALAsset instance] isTheSelectionalItem:currentItem];
    [self.topBar.stateButton setSelected:isSelectionalItem];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.type == MXImagePreviewTypeSelection) {
        return self.originalSelectionalIndexs.count;
    }
    
    return [MXALAsset instance].numberOfAssetsForCurrentGroup;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MXImagePreviewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    [cell setDelegate:self];
    [cell setIndexPathItem:indexPath.item];
    
    NSInteger currentItem = indexPath.item;
    if (self.type == MXImagePreviewTypeSelection) {
        currentItem = [self.originalSelectionalIndexs[currentItem] integerValue];
    }
    ALAsset *asset = [[MXALAsset instance] assetAtIndex:currentItem];
    [[MXALAsset instance] previewWithAsset:asset result:^(UIImage *image) {
        if (cell.indexPathItem == indexPath.item) cell.imageZoomView.imageView.image = image;
    }];
    
    return cell;
}

#pragma mark - MXImagePreviewCellDelegate

- (void)didSingleTapAtImagePreviewCell:(MXImagePreviewCell *)cell
{
    CGRect topBarRect = self.topBar.frame;
    CGRect bottomBarRect = self.bottomBar.frame;
    
    topBarRect.origin.y = self.isToolBarHidden ? 0.0 : -CGRectGetHeight(topBarRect);
    bottomBarRect.origin.y = self.isToolBarHidden ? CGRectGetHeight(self.view.bounds) - CGRectGetHeight(bottomBarRect) : CGRectGetHeight(self.view.bounds) + CGRectGetHeight(bottomBarRect);
    
    typeof(self) __weak weakSelf = self;
    [UIView animateWithDuration:0.15 animations:^{
        weakSelf.topBar.frame = topBarRect;
        weakSelf.bottomBar.frame = bottomBarRect;
    } completion:^(BOOL finished) {
        weakSelf.isToolBarHidden = !weakSelf.isToolBarHidden;
    }];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!scrollView.tracking && !scrollView.decelerating) {
        return;
    }
    
    [self adjustSelectionalStateForCurrentItem];
}

@end
