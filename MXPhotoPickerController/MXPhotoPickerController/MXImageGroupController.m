//
//  MXImageGroupController.m
//  MXPhotoPickerController
//
//  Created by 韦纯航 on 15/12/9.
//  Copyright © 2015年 韦纯航. All rights reserved.
//

#import "MXImageGroupController.h"

#import "MXImageListController.h"

#import "MXALAsset.h"

@interface MXImageGroupCell : UITableViewCell

@property (retain, nonatomic) UIImageView *photoView;

@property (retain, nonatomic) UILabel *titleLabel;

@end

@implementation MXImageGroupCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.separatorInset = UIEdgeInsetsMake(0.0, 10.0, 0.0, 0.0);
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        self.photoView = [[UIImageView alloc] init];
        self.titleLabel = [[UILabel alloc] init];
        
        [self.contentView addSubview:self.photoView];
        [self.contentView addSubview:self.titleLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect rect = self.contentView.bounds;
    CGFloat x, y, w, h;
    
    x = 10.0, y = 10.0, h = CGRectGetHeight(rect) - y * 2, w = h;
    [self.photoView setFrame:(CGRect){x, y, w, h}];
    
    x = CGRectGetMaxX(self.photoView.frame) + 10.0;
    w = CGRectGetWidth(rect) - x;
    [self.titleLabel setFrame:(CGRect){x, y, w, h}];
}

@end

static NSString *const CellIdentifier = @"MXImageGroupCell";

@interface MXImageGroupController ()

@property (copy, nonatomic) NSArray *allGroups;

@end

@implementation MXImageGroupController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
        if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
            [self.tableView setLayoutMargins:UIEdgeInsetsZero];
        }
        [self.tableView registerClass:[MXImageGroupCell class] forCellReuseIdentifier:CellIdentifier];
        [self.tableView setRowHeight:90.0];
        [self.tableView setTableFooterView:[UIView new]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"照片";
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(rightItemEvent:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    typeof(self) __weak weakSelf = self;
    [[MXALAsset instance] setupAlbumGroups:^(NSArray *groups) {
        weakSelf.allGroups = groups;
        [weakSelf.tableView reloadData];
        
        if (weakSelf.allGroups.count > 0) {
            MXImageListController *imageListController = [[MXImageListController alloc] init];
            imageListController.selectedGroup = [weakSelf.allGroups firstObject];
            [weakSelf.navigationController pushViewController:imageListController animated:NO];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[MXALAsset instance] resetAllSelectionalALAssets];
}

#pragma mark - Control Event

- (void)rightItemEvent:(UIBarButtonItem *)item
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.allGroups.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MXImageGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    ALAssetsGroup *group = self.allGroups[indexPath.row];
    
    cell.photoView.image = [UIImage imageWithCGImage:group.posterImage];
    
    NSDictionary *groupTitleAttribute = @{NSForegroundColorAttributeName : [UIColor blackColor],
                                          NSFontAttributeName : [UIFont boldSystemFontOfSize:17.0]};
    NSDictionary *numberOfAssetsAttribute = @{NSForegroundColorAttributeName:[UIColor grayColor],
                                              NSFontAttributeName : [UIFont systemFontOfSize:17.0]};
    NSString *groupTitle = [group valueForProperty:ALAssetsGroupPropertyName];
    NSInteger numberOfAssets = group.numberOfAssets;
    NSString *titleString = [NSString stringWithFormat:@"%@（%ld）", groupTitle, (long)numberOfAssets];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:titleString attributes:numberOfAssetsAttribute];
    [attributedString addAttributes:groupTitleAttribute range:NSMakeRange(0, groupTitle.length)];
    [cell.titleLabel setAttributedText:attributedString];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MXImageListController *imageListController = [[MXImageListController alloc] init];
    imageListController.selectedGroup = self.allGroups[indexPath.row];
    [self.navigationController pushViewController:imageListController animated:YES];
}

@end
