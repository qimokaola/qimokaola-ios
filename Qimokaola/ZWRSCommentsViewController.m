//
//  ZWBaseCommentsViewController.m
//  Qimokaola
//
//  Created by Administrator on 2016/9/29.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWRSCommentsViewController.h"
#import "ZWHUDTool.h"
#import "ZWUserDetailViewController.h"
#import "ZWFeedDetailViewController.h"
#import "ZWFeedComposeViewController.h"


#define kUserCommentsReceivedIdentifier @"kUserCommentsReceivedIdentifier"
#define kUserCommentsSentIdentifier @"kUserCommentsSentIdentifier"

@interface ZWRSCommentsViewController ()

@property (nonatomic, strong) UITableView *tableView;

/**
 评论数组
 */
@property (nonatomic, strong) NSMutableArray *comments;

@end

@implementation ZWRSCommentsViewController

- initWithUserCommentsType:(ZWUserCommentsType)userCommentsType {
    if (self = [super init]) {
        self.userCommentsType = userCommentsType;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = defaultBackgroundColor;
    
    self.comments = [NSMutableArray array];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tableView.mj_header beginRefreshing];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Lazy Loading

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        // 64 + 10
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 74, 0);
        _tableView.scrollIndicatorInsets = _tableView.contentInset;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        
        if (_userCommentsType == ZWUserCommentsTypeReceived) {
            [_tableView registerClass:[ZWReceivedCommentCell class] forCellReuseIdentifier:kUserCommentsReceivedIdentifier];
        } else {
            [_tableView registerClass:[ZWSentCommentCell class] forCellReuseIdentifier:kUserCommentsSentIdentifier];
        }
        
        MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(fetchCommentsData)];
        _tableView.mj_header = header;
        
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

#pragma mark - Common Methods

- (void)fetchCommentsData {
    __weak __typeof(self) weakSelf = self;
    if (_userCommentsType == ZWUserCommentsTypeReceived) {
        [[UMComDataRequestManager defaultManager] fetchCommentsUserReceivedWithCount:5
                                                                          completion:^(NSDictionary *responseObject, NSError *error) {
                                                                              [weakSelf.tableView.mj_header endRefreshing];
                                                                              [weakSelf dealWithResult:responseObject error:error];
                                                                          }];
    } else {
        [[UMComDataRequestManager defaultManager] fetchCommentsUserSentWithCount:5
                                                                      completion:^(NSDictionary *responseObject, NSError *error) {
                                                                          [weakSelf.tableView.mj_header endRefreshing];
                                                                          [weakSelf dealWithResult:responseObject error:error];
                                                                      }];
    }

}

- (void)dealWithResult:(NSDictionary *)responseObject error:(NSError *)error {
    if (responseObject) {
        [self.comments removeAllObjects];
        [self.comments addObjectsFromArray:responseObject[@"data"]];
        [self.tableView reloadData];
    } else {
        [ZWHUDTool showHUDInView:self.navigationController.view withTitle:@"获取数据失败" message:nil duration:kShowHUDShort];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.comments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ZWRSCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:_userCommentsType == ZWUserCommentsTypeReceived ? kUserCommentsReceivedIdentifier : kUserCommentsSentIdentifier];
    cell.comment = self.comments[indexPath.row];
    cell.delegate = self;
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id model = self.comments[indexPath.row];
    Class clazz = _userCommentsType == ZWUserCommentsTypeReceived ? [ZWReceivedCommentCell class] : [ZWSentCommentCell class];
    return [tableView cellHeightForIndexPath:indexPath model:model keyPath:@"comment" cellClass:clazz contentViewWidth:kScreenW];
}

#pragma mark - ZWRSCommentCellDelegate

- (void)cell:(ZWRSCommentCell *)cell didClickToUser:(UMComUser *)user {
    ZWUserDetailViewController *userDetailViewController = [[ZWUserDetailViewController alloc] init];
    userDetailViewController.user = user;
    [self.navigationController pushViewController:userDetailViewController animated:YES];
}

- (void)cell:(ZWRSCommentCell *)cell didClickReplyComment:(UMComComment *)comment {
    
}

- (void)cell:(ZWRSCommentCell *)cell didClickReplyFeed:(UMComFeed *)feed {
    ZWFeedDetailViewController *feedDetailViewController = [[ZWFeedDetailViewController alloc] init];
    feedDetailViewController.feed = feed;
    [self.navigationController pushViewController:feedDetailViewController animated:YES];
}

- (void)cell:(ZWRSCommentCell *)cell didClickCommentButton:(UMComComment *)comment {
    ZWFeedComposeViewController *composeViewController = [[ZWFeedComposeViewController alloc] init];
    composeViewController.composeType = ZWFeedComposeTypeReplyComment;
    composeViewController.commentID = comment.commentID;
    UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:composeViewController];
    [self presentViewController:navc animated:YES completion:nil];
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end