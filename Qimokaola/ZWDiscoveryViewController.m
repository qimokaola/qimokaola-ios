//
//  ZWDiscoveryViewController.m
//  Qimokaola
//
//  Created by Administrator on 16/7/19.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWDiscoveryViewController.h"
#import "ZWAPITool.h"
#import "ZWUserManager.h"
#import "ZWUserInfoViewController.h"
#import "ZWHUDTool.h"

#import "MJRefresh.h"
#import "Masonry.h"
#import "ReactiveCocoa.h"
#import <UMCommunitySDK/UMComDataRequestManager.h>
#import <UMCommunitySDK/UMComSession.h>
#import <YYKit/YYKit.h>


@interface ZWDiscoveryViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

// 头像 用户名等父控件
@property (strong, nonatomic) UIView *userInfoView;

// 头像
@property (strong, nonatomic) UIImageView *avatarImageView;

// 昵称标签
@property (nonatomic, strong) UILabel *nicknameLabel;

// 性别视图
@property (nonatomic, strong) UIImageView *genderView;

// 学校标签
@property (nonatomic, strong) UILabel *schoolLabel;

@property (nonatomic, strong) NSArray *channels;

@end

@implementation ZWDiscoveryViewController

#pragma mark - Life Cyle

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.view.backgroundColor = universalGrayColor;
    [self createSubViews];
    
    // 设置下拉刷新
    MJRefreshNormalHeader *refreshHeader = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(freshHeaderFreshed)];
    self.tableView.mj_header = refreshHeader;
    // 进入视图时刷新用户信息
    [self.tableView.mj_header beginRefreshing];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateUserInfo];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Lazy Loading

- (NSArray *)channels {
    if (_channels == nil) {
        _channels = @[
                      @[
                          @{@"icon" : @"radio_button_checked", @"title" : @"我的动态", @"detail" : @"我发的学生圈"},
                          @{@"icon" : @"radio_button_checked", @"title" : @"我的收藏", @"detail" : @"收藏的帖子"},
                          @{@"icon" : @"radio_button_checked", @"title" : @"评论", @"detail" : @"我的评论"},
                          @{@"icon" : @"radio_button_checked", @"title" : @"赞我的", @"detail" : @"你说得好"}
                        ],
                      
                      @[
                          @{@"icon" : @"radio_button_checked", @"title" : @"考试倒计时", @"detail" : @"新建倒计时"},
                          @{@"icon" : @"radio_button_checked", @"title" : @"四六级查询", @"detail" : @"免准考号查询"},
                          @{@"icon" : @"radio_button_checked", @"title" : @"加入我们", @"detail" : @"版主及校代表"}
                          
                        ]
                      
                      ];
    }
    return _channels;
}

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.contentInset = UIEdgeInsetsMake(kNavigationBarHeight, 0, 0, 0);
        _tableView.scrollIndicatorInsets = _tableView.contentInset;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

#pragma mark - Common Methods

#pragma mark 获取用户信息
- (void)freshHeaderFreshed {
    self.tableView.userInteractionEnabled = NO;
    __weak __typeof(self) weakSelf = self;
    [ZWAPIRequestTool requestUserInfo:^(id response, BOOL success) {
        [weakSelf.tableView.mj_header endRefreshing];
        weakSelf.tableView.userInteractionEnabled = YES;
        if (success && [[response objectForKey:@"code"] intValue] == 0) {
            ZWUser *user = [ZWUser modelWithDictionary:[response objectForKey:@"res"]];
            if (![user isEqual:[ZWUserManager sharedInstance].loginUser]) {
                [ZWUserManager sharedInstance].loginUser = user;
                [weakSelf updateUserInfo];
            }
        } else {
            [ZWHUDTool showHUDInView:weakSelf.navigationController.view withTitle:@"出现错误" message:nil duration:kShowHUDMid];
        }
    }];
}

- (void)updateUserInfo {
    ZWUser *loginUser = [ZWUserManager sharedInstance].loginUser;
    [self.avatarImageView setImageWithURL:[NSURL URLWithString:[[ZWAPITool base] stringByAppendingPathComponent:loginUser.avatar_url]] placeholder:[UIImage imageNamed:@"avatar"]];
    self.nicknameLabel.text  = loginUser.nickname;
    //self.schoolLabel.text = loginUser.collegeName;
    self.schoolLabel.text  = @"福州大学";
    NSString *genderImageName = [loginUser.gender isEqualToString:@"男"] ? @"icon_male" : @"icon_female";
    self.genderView.image = [UIImage imageNamed:genderImageName];
}

- (void)createSubViews {
    __weak __typeof(self) weakSelf = self;
    CGFloat sizeRate = 0.7;
    CGFloat marginRate = (1. - sizeRate) / 2.;
    CGFloat margin = 10;
    CGFloat smallMargin = 5.f;
    CGFloat genderViewSize = 20.f;
    UIColor *commonBlueColor = RGB(80, 140, 238);
    
    //用户信息View
    self.userInfoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight * 0.15)];
    [self.userInfoView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToUserInfo)]];
    self.userInfoView.backgroundColor = [UIColor whiteColor];
    self.tableView.tableHeaderView = self.userInfoView;
    
    //头像View
    self.avatarImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"avatar"]];
    [self.userInfoView addSubview:self.avatarImageView];
    [self.avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.and.width.equalTo(weakSelf.userInfoView.mas_height).multipliedBy(sizeRate);
        make.centerY.equalTo(weakSelf.userInfoView);
        make.left.offset(weakSelf.userInfoView.frame.size.height * marginRate);
    }];
    [self.avatarImageView layoutIfNeeded];
    CALayer *layer = self.avatarImageView.layer;
    layer.borderColor = commonBlueColor.CGColor;
    layer.borderWidth = 2;
    layer.cornerRadius = CGRectGetWidth(self.avatarImageView.frame) / 2.;
    layer.masksToBounds = YES;
    
    //用户名（昵称）View
    self.nicknameLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.numberOfLines = 1;
        label.textColor = commonBlueColor;
        label.font = [UIFont systemFontOfSize:17];
        [label sizeToFit];
        [self.userInfoView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf.avatarImageView.mas_right).with.offset(margin);
            make.bottom.equalTo(weakSelf.userInfoView.mas_centerY).with.offset(-smallMargin);
        }];
        label;
    });
    
    self.genderView = ({
        UIImageView *imageView = [[UIImageView alloc] init];
        [self.userInfoView addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(genderViewSize, genderViewSize));
            make.centerY.equalTo(weakSelf.nicknameLabel);
            make.left.equalTo(weakSelf.nicknameLabel.mas_right).with.offset(smallMargin);
        }];
        imageView;
    });
    
    //显示下载币文字标签
    self.schoolLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.numberOfLines = 1;
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor lightGrayColor];
        [label sizeToFit];
        [self.userInfoView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(weakSelf.nicknameLabel);
            make.top.equalTo(weakSelf.userInfoView.mas_centerY).with.offset(smallMargin);
        }];
        label;
    });

    // 箭头
    UIImageView *arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_icon_arrow"]];
    [self.userInfoView addSubview:arrowView];
    [arrowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(20, 20));
        make.centerY.equalTo(weakSelf.userInfoView);
        make.right.equalTo(weakSelf.userInfoView).with.offset(- margin);
    }];
}

- (void)tapToUserInfo {
    NSLog(@"tapped user info");
    ZWUserInfoViewController *userInfoViewController = [[ZWUserInfoViewController alloc] init];
    [self.navigationController pushViewController:userInfoViewController animated:YES];
}

#pragma mark - UITabelViewDataSource 

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = [self.channels objectAtIndex:section];
    return array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
        cell.backgroundColor = [UIColor whiteColor];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    NSDictionary *dict = [self.channels[indexPath.section] objectAtIndex:indexPath.row];
    cell.imageView.image = [UIImage imageNamed:dict[@"icon"]];
    cell.textLabel.text = dict[@"title"];
    cell.detailTextLabel.text = dict[@"detail"];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    });
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
