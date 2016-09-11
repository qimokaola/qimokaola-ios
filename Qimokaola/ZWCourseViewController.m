//
//  ZWCourseViewController.m
//  Qimokaola
//
//  Created by Administrator on 16/9/10.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWCourseViewController.h"
#import "ZWFolder.h"
#import "ZWAPIRequestTool.h"
#import "ZWUserManager.h"
#import "ZWFileAndFolderViewController.h"
#import "ZWCourseCell.h"

#import "LinqToObjectiveC.h"

@interface ZWCourseViewController ()

@end

@implementation ZWCourseViewController

static NSString *const ROOT = @"/";
static NSString *const CourseCellIdentifier = @"CourseCellIdentifier";

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[ZWCourseCell class] forCellReuseIdentifier:CourseCellIdentifier];    
    self.tableView.rowHeight = 50;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Normal Method

#pragma mark 重写覆盖下拉刷新方法
- (void)freshHeaderStartFreshing {
    
    __weak __typeof(self) weakSelf = self;
    
    [ZWAPIRequestTool requstFileAndFolderListInSchool:[ZWUserManager sharedInstance].loginUser.collegeId
                                                 path:ROOT
                                           needDetail:YES
                                               result:^(id response, BOOL success) {
                                                   
                                                   [weakSelf.tableView.mj_header endRefreshing];
                                                   
                                                   if (success) {
                                                       [weakSelf loadRemoteData:[response objectForKey:@"res"]];
                                                   }
                                                   
                                               }];
}

#pragma mark 处理接收到数据
- (void)loadRemoteData:(NSDictionary *)data {
    self.dataArray = [[[data objectForKey:@"folders"] linq_select:^id(NSDictionary *item) {
        return [ZWFolder yy_modelWithDictionary:item];
    }] mutableCopy];
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZWCourseCell *cell = [tableView dequeueReusableCellWithIdentifier:CourseCellIdentifier];
    ZWFolder *folder = nil;
    if (self.searchController.active) {
        folder = [self.filteredArray objectAtIndex:indexPath.row];
    } else {
        folder = [self.dataArray objectAtIndex:indexPath.row];
    }
    cell.folderName = folder.name;
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    });
    
    NSString *path = nil;
    ZWFolder *folder = nil;
    if (self.searchController.active) {
        folder = [self.filteredArray objectAtIndex:indexPath.row];
    } else {
        folder = [self.dataArray objectAtIndex:indexPath.row];
    }
    path = [[ROOT stringByAppendingPathComponent:folder.name] stringByAppendingString:@"/"];
    ZWFileAndFolderViewController *fileAndFolder = [[ZWFileAndFolderViewController alloc] init];
    fileAndFolder.path = path;
    [self.navigationController pushViewController:fileAndFolder animated:YES];
}

#pragma mark - UISearchResultUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    [self.filteredArray removeAllObjects];
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"name CONTAINS[c] %@", searchController.searchBar.text];
    self.filteredArray = [[self.dataArray filteredArrayUsingPredicate:searchPredicate] mutableCopy];
    [self.tableView reloadData];
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
