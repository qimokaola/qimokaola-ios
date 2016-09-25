//
//  ZWUserInfoViewController.m
//  Qimokaola
//
//  Created by Administrator on 2016/9/16.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWUserInfoViewController.h"
#import "ZWUserManager.h"
#import "ZWAPITool.h"
#import "ZWModifyNicknameViewController.h"
#import "ZWModifyGenderViewController.h"
#import "ZWModifiAcademyViewController.h"
#import "ZWModifyAvatarViewController.h"

#import <YYKit/YYKit.h>

@interface ZWUserInfoViewController () <UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate> {
    NSInteger thisYear;
}

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *userInfoArray;

@property (nonatomic, strong) UIView *avatarAccessoryView;

@property (nonatomic, strong) UIImageView *avatarView;

@property (nonatomic, strong) UIPickerView *enterYearPicker;

@end

@implementation ZWUserInfoViewController

#pragma mark - Life Cycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.view.backgroundColor = universalGrayColor;
    self.title = @"个人信息";
    [self zw_addSubViews];
    // 获取今年年份
    NSDate *date = [NSDate date];
    thisYear = [date year];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Lazy Loading

- (NSArray *)userInfoArray {
    if (_userInfoArray == nil) {
        _userInfoArray = @[
                           @[
                               @"头像",
                               @"昵称",
                               @"手机号"
                               
                               ],
                           
                           @[
                               @"学校",
                               @"学院",
                               @"入学年份",
                               @"性别"
                               
                               ]
                           ];
    }
    return _userInfoArray;
}

- (UIView *)avatarAccessoryView {
    if (_avatarAccessoryView == nil) {
        CGFloat avatarImageViewSize = 60;
        CGFloat arrowViewSize = 15;
        CGFloat margin = 10.f;
        _avatarAccessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, avatarImageViewSize + arrowViewSize + margin, avatarImageViewSize)];
    // 头像
        _avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        _avatarView.layer.cornerRadius = 5;
        _avatarView.layer.masksToBounds = YES;
        _avatarView.layer.borderWidth = 1;
        _avatarView.layer.borderColor = universalGrayColor.CGColor;
        [_avatarView setImageWithURL:[NSURL URLWithString:[[ZWAPITool base] stringByAppendingPathComponent:[ZWUserManager sharedInstance].loginUser.avatar_url]] options:YYWebImageOptionProgressive];
        [_avatarAccessoryView addSubview:_avatarView];
        
        // 箭头
        UIImageView *arrowView = [[UIImageView alloc] initWithFrame:CGRectMake(avatarImageViewSize + margin, (avatarImageViewSize - arrowViewSize) / 2, arrowViewSize, arrowViewSize)];
        arrowView.image = [UIImage imageNamed:@"common_icon_arrow"];
        [_avatarAccessoryView addSubview:arrowView];
    }
    return _avatarAccessoryView;
}

- (UIPickerView *)enterYearPicker {
    if (_enterYearPicker == nil) {
        CGFloat pickerViewHeight = 150;
        _enterYearPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, kScreenHeight - pickerViewHeight, kScreenWidth, pickerViewHeight)];
        _enterYearPicker.dataSource = self;
        _enterYearPicker.delegate = self;
    }
    return _enterYearPicker;
}

#pragma mark - Common Methods

- (void)zw_addSubViews {
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    _tableView.scrollIndicatorInsets = _tableView.contentInset;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.backgroundView.backgroundColor = [UIColor clearColor];
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.userInfoArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [(NSArray *)[self.userInfoArray objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    cell.textLabel.text = [[self.userInfoArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.detailTextLabel.font =ZWFont(15);
    ZWUser *user =[ZWUserManager sharedInstance].loginUser;
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                cell.accessoryView = self.avatarAccessoryView;
                [_avatarView setImageWithURL:[NSURL URLWithString:[[ZWAPITool base] stringByAppendingPathComponent:[ZWUserManager sharedInstance].loginUser.avatar_url]] options:YYWebImageOptionProgressive];
                break;
            case 1:
                cell.detailTextLabel.text = user.nickname;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
            case 2:
                cell.detailTextLabel.text = user.username;
                break;
            default:
                break;
        }
    } else {
        switch (indexPath.row) {
            case 0:
                cell.detailTextLabel.text = user.collegeName;
                cell.accessoryType = UITableViewCellAccessoryNone;
                break;
            case 1:
                cell.detailTextLabel.text = user.academyName;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
            case 2:
                cell.detailTextLabel.text = user.enterYear;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
            case 3:
                cell.detailTextLabel.text = user.gender;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
            default:
                break;
        }
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    });
    __weak __typeof(self) weakSelf = self;
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            ZWModifyAvatarViewController *modifyAvatar = [[ZWModifyAvatarViewController alloc] init];
            modifyAvatar.completion = ^() {
                [weakSelf.tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
            };
            [self.navigationController pushViewController:modifyAvatar animated:YES];
        } else if (indexPath.row == 1) {
            ZWModifyNicknameViewController *modifyNickname = [[ZWModifyNicknameViewController alloc] init];
            modifyNickname.completion = ^() {
                [weakSelf.tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
            };
            [self.navigationController pushViewController:modifyNickname animated:YES];
        }
    } else {
        if (indexPath.row == 1) {
            ZWModifiAcademyViewController *modifyAcademy = [[ZWModifiAcademyViewController alloc] init];
            modifyAcademy.completion = ^() {
                [weakSelf.tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
            };
            [self.navigationController pushViewController:modifyAcademy animated:YES];
        } else if (indexPath.row == 2) {
            [self.view addSubview:self.enterYearPicker];
        } else if (indexPath.row == 3) {
            ZWModifyGenderViewController *modifyGender = [[ZWModifyGenderViewController alloc] init];
            modifyGender.comletion = ^() {
                [weakSelf.tableView reloadRowAtIndexPath:indexPath withRowAnimation:UITableViewRowAnimationNone];
            };
            [self.navigationController pushViewController:modifyGender animated:YES];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        return 80;
    } else {
        return 44;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 5;
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [NSString stringWithFormat:@"%li", thisYear - row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [pickerView removeFromSuperview];
    });
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
