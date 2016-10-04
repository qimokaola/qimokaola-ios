//
//  ZWSelectSchoolViewController.m
//  Qimokaola
//
//  Created by Administrator on 16/7/14.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWSelectSchoolViewController.h"
#import "ZWAPIRequestTool.h"

@interface ZWSelectSchoolViewController () {
    // 记录是否处于学校列表
    BOOL isInSchoolList;
}

@property (nonatomic, strong) NSArray *schools;
@property (nonatomic, strong) NSArray *academies;
@property (nonatomic, strong) NSDictionary *selectedSchool;
@property (nonatomic, strong) UIBarButtonItem *chooseSchool;

@end

@implementation ZWSelectSchoolViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    //设置tableView分割线只在数据条目显示
    UIView *v = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView setTableFooterView:v];
    self.chooseSchool = [[UIBarButtonItem alloc] initWithTitle:@"换个学校" style:UIBarButtonItemStyleDone target:self action:@selector(fetchSchoolList)];
    // 开始时加载学校列表
    [self fetchSchoolList];
}


- (void)fetchSchoolList {
    isInSchoolList = YES;
    self.title = @"选择学校";
    [ZWAPIRequestTool requestListSchool:^(id response, BOOL success) {
        if (success) {
            self.navigationItem.rightBarButtonItem = nil;
            self.schools = [response objectForKey:kHTTPResponseResKey];
            [self.tableView reloadData];
        }
    }];
}

- (void)fetchAcademiesList {
    isInSchoolList = NO;
    self.title = [self.selectedSchool objectForKey:@"name"];
    [ZWAPIRequestTool requestListAcademyWithParameter:@{@"college" : [self.selectedSchool objectForKey:@"id"]} result:^(id response, BOOL success) {
        if (success) {
            self.navigationItem.rightBarButtonItem = self.chooseSchool;
            self.academies = [(NSDictionary *)response objectForKey:kHTTPResponseResKey];
            [self.tableView reloadData];
        }
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return isInSchoolList ? self.schools.count : self.academies.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *const cellID = @"CellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    NSDictionary *dict = isInSchoolList ? [self.schools objectAtIndex:indexPath.row] : [self.academies objectAtIndex:indexPath.row];
    cell.textLabel.text = [dict objectForKey:@"name"];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    if (isInSchoolList) {
        self.selectedSchool = [self.schools objectAtIndex:indexPath.row];
        [self fetchAcademiesList];
    } else {
        if (_completionBlock) {
            
            NSDictionary *selectedAcademy = [self.academies objectAtIndex:indexPath.row];
            NSDictionary *result = [NSDictionary dictionaryWithObjects:@[self.selectedSchool, selectedAcademy] forKeys:@[@"school", @"academy"]];
            NSLog(@"selected school and academy info: %@", result);
            _completionBlock(result);
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
            
        }
    }
    
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
