//
//  UMAssetsCollectionController.m
//  UMCommunity
//
//  Created by luyiyuan on 14/9/9.
//  Copyright (c) 2014年 Umeng. All rights reserved.
//

#import "UMAssetsCollectionController.h"
#import "UMAssetsCollectionCell.h"
#import "UMComResouceDefines.h"
#import "UIViewController+UMComAddition.h"
#import <UMComFoundation/UMComKit+Color.h>

static inline NSInteger umGetRowNumber(NSInteger number)
{
    return number % 4 == 0 ? (number/4) : (number/4 + 1);
}

static inline NSRange umGetRangeForIndex(NSInteger index,NSInteger allcount)
{
    NSRange range;
    
    range.location =  index * 4;
    
    if(range.location + 4 < allcount)
    {
        range.length = 4;
    }
    else
    {
        range.length = allcount - range.location;
    }
    
    return range;
}

@interface UMAssetsCollectionController ()
{
    UIImage* _backImage;
}
@property (nonatomic, strong) NSMutableArray *assets;
@property (nonatomic, strong) NSMutableDictionary *assetsSelection;
@property (nonatomic, strong) NSMutableArray *assetsSelectionArray;
@property (nonatomic, strong) UIBarButtonItem *doneButton;
@end

@implementation UMAssetsCollectionController


-(void) setBackImage:(UIImage *)backImage
{
    _backImage = backImage;
    if (_backImage) {
        [self setForumUIBackButtonWithImage:_backImage];
    }
}

-(UIImage*) backImage
{
    return _backImage;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        

        [self.navigationController.navigationBar setBarTintColor:UMComColorWithHexString(@"#f7f7f8")];

        [self setRightButtonWithTitle:UMComLocalizedString(@"um_com_finish",@"完成") action:@selector(done:)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
//        [self setTitleViewWithTitle:UMComLocalizedString(@"Photo", @"相机胶卷")];
        [self.tableView registerClass:[UMAssetsCollectionCell class] forCellReuseIdentifier:@"CollectionCell"];
    }
    return self;
}


- (void)setAssetsGroup:(ALAssetsGroup *)assetsGroup
{
    _assetsGroup = assetsGroup;
    
    // Set title
    self.title = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    
    // Set assets filter
    [self.assetsGroup setAssetsFilter:[ALAssetsFilter allPhotos]];
    
    // Load assets
    NSMutableArray *assets = [NSMutableArray array];

    [self.assetsGroup enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (result) {
            
            NSString *type = [result valueForProperty:ALAssetPropertyType];
            
            if ([type isEqualToString:ALAssetTypePhoto])
            {
                [assets addObject:result];
            }
        }
    }];
    
    self.assets = assets;

    self.assetsSelection = [NSMutableDictionary dictionary];
    self.assetsSelectionArray = [NSMutableArray arrayWithCapacity:1];
    
    // Update view
    [self.tableView reloadData];
}

- (void)done:(id)sender
{
    if([self.assetsSelection count]<=0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:UMComLocalizedString(@"um_com_warning", @"警告") message:[NSString stringWithFormat:UMComLocalizedString(@"um_com_selectedMinPics", @"当前至少选择%d张图片"),self.minimumNumberOfSelection] delegate:self cancelButtonTitle:UMComLocalizedString(@"um_com_ok", @"好的") otherButtonTitles:nil];
        
        [alert show];
        return;
    }
    
    
    NSMutableArray *array = [NSMutableArray array];

//原    for(NSNumber *number in self.assetsSelection)

    for(NSNumber *number in self.assetsSelectionArray)
    {
        if ([number integerValue] < self.assets.count) {
            [array addObject:self.assets[[number integerValue]]];
        }
    }
    
    if(self.finishHandle)
    {
        self.finishHandle(array);
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return indexPath.row == 0 ? 90 : 80;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return umGetRowNumber([self.assets count]);
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UMAssetsCollectionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CollectionCell" forIndexPath:indexPath];
    cell.maximumNumberOfSelection = self.maximumNumberOfSelection;
    
    NSArray *asset = [self.assets subarrayWithRange:umGetRangeForIndex(indexPath.row,[self.assets count])];
//    [cell setAssets:asset
//          rowNumber:indexPath.row
//             height:[self tableView:tableView heightForRowAtIndexPath:indexPath]
//          selection:self.assetsSelection
//              range:getRangeForIndex(indexPath.row,[self.assets count])];
    [cell setAssets:asset
          rowNumber:indexPath.row
             height:[self tableView:tableView heightForRowAtIndexPath:indexPath]
          selection:self.assetsSelection
              range:umGetRangeForIndex(indexPath.row,[self.assets count]) selectionArray:self.assetsSelectionArray];
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
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
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
