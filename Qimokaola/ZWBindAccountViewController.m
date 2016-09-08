//
//  ZWBindAccountViewController.m
//  Qimokaola
//
//  Created by Administrator on 16/8/5.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWBindAccountViewController.h"
#import "UIColor+Extension.h"
#import "Masonry.h"
#import "ReactiveCocoa.h"
#import "ZWAPIRequestTool.h"
#import "ZWHUDTool.h"
#import "ZWTabBarController.h"
#import "ZWPathTool.h"
#import "ZWUserManager.h"

#define AccountValidCondition 6
#define PasswordValidCondition 2

#define NeedMoreCode 116
#define AccountErrorCode 115
#define UserAlreadyExistCode 113

@interface ZWBindAccountViewController () {
    // 标记是否需要更多信息
    BOOL isNeedMore;
}

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UITextField *accountField;

@property (nonatomic, strong) UIView *accountLine;

@property (nonatomic, strong) UITextField *passwordField;

@property (nonatomic, strong) UIView *passwordLine;

@property (nonatomic, strong) UIButton *nextBtn;

@property (nonatomic, strong) UITextField *verifyField;

@property (nonatomic, strong) UIView *verifyLine;

@property (nonatomic, strong) UIImageView *verifyImageView;

@property (nonatomic, strong) NSDictionary *moreInfo;

@property (nonatomic, strong) AFHTTPSessionManager *manager;

@property (nonatomic, strong) UIActivityIndicatorView *indicator;

@end

@implementation ZWBindAccountViewController

- (AFHTTPSessionManager *)manager {
    if (_manager == nil) {
        _manager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        _manager.requestSerializer = [AFJSONRequestSerializer serializer];
        [_manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    }
    return _manager;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    isNeedMore = NO;
    
    [self createSubViews];
    
    [self bindSignals];
}

- (void)bindSignals {
    RACSignal *accountValidSignal = [[self.accountField.rac_textSignal map:^id(NSString *value) {
        return @([self isAccountValid:value]);
    }] distinctUntilChanged];
    
    RACSignal *passwordValidSignal = [[self.passwordField.rac_textSignal map:^id(NSString *value) {
        return @([self isPasswordValid:value]);
    }] distinctUntilChanged];
    
    RACSignal *enableSignal = [RACSignal combineLatest:@[accountValidSignal, passwordValidSignal] reduce:^id(NSNumber *accountValid, NSNumber *passwordValid){
        return @([accountValid boolValue] && [passwordValid boolValue]);
    }];
    
    @weakify(self)
    self.nextBtn.rac_command = [[RACCommand alloc] initWithEnabled:enableSignal signalBlock:^RACSignal *(id input) {
        @strongify(self)
        return [self bindAccountSignal];
    }];
    
    [[[[self.nextBtn.rac_command.executionSignals switchToLatest] deliverOnMainThread] doNext:^(id x) {
        
        @strongify(self)
        
        [self.nextBtn setTitle:@"注册" forState:UIControlStateDisabled];
        
        NSLog(@"%@", x);
        
    }] subscribeNext:^(NSDictionary *result) {
       @strongify(self)
        int resultCode = [[result objectForKey:@"code"] intValue];
        if (resultCode == 0) {
            NSLog(@"注册成功 上传头像图片");
            // 注册成功 根据注册信息构建用户
            ZWUser *user = [[ZWUser alloc] init];
            user.uid = [[result objectForKey:@"res"] objectForKey:@"id"];
            user.username = [self.registerParam objectForKey:@"phone"];
            user.nickname = [self.registerParam objectForKey:@"nick"];
            user.collegeId = [self.registerParam objectForKey:@"schoolId"];
            user.acadenyId = [self.registerParam objectForKey:@"academyId"];
            user.gender = [self.registerParam objectForKey:@"gender"];
            user.isAdmin = NO;
            [ZWUserManager sharedInstance].loginUser = user;
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"LoginState"];
            
            [self handleUploadAvatarImage];
            
        } else {
            
            [ZWHUDTool showHUDInView:self.navigationController.view withTitle:[result objectForKey:@"info"] message:nil duration:kShowHUDMid];
            
            // 暂时只处理需要更多信息的情况
            if (resultCode == NeedMoreCode) {
                
                NSLog(@"需要更多信息");
                
                [self handleNeedMore:[result objectForKey:@"res"]];
                
            }
        }
        
    }];
    
    RAC(self.indicator, hidden) = [self.nextBtn.rac_command.executing not];
}

/**
 *  @author Administrator, 16-09-02 23:09:36
 *
 *  注册完后上传用户图像
 */
- (void)handleUploadAvatarImage {
    //__weak __typeof(self) weakSelf = self;
    MBProgressHUD *hud = [ZWHUDTool excutingHudInView:self.navigationController.view title:@"正在准备用户信息"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kShowHUDMid * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [ZWAPIRequestTool requestUploadAvatarWithParamsters:@{} constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            NSString *fileName = @"avatar.jpeg";
            NSString *avatarPath = [[ZWPathTool avatarDirectory] stringByAppendingPathComponent:fileName];
            NSURL *avatarFileURL = [NSURL fileURLWithPath:avatarPath];
            [formData appendPartWithFileURL:avatarFileURL name:@"avatar" fileName:fileName mimeType:@"image/jpeg" error:NULL];
        } result:^(id response, BOOL success) {
            NSLog(@"%@", response);
            
            if (success) {
                hud.mode = MBProgressHUDModeCustomView;
                hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Checkmark"]];
                hud.square = YES;
                hud.label.text = @"注册成功";
                
                ZWUser *user = [ZWUserManager sharedInstance].loginUser;
                user.avatar_url = [[response objectForKey:@"res"] objectForKey:@"avatar"];
                [ZWUserManager sharedInstance].loginUser = user;
                
               
            } else {
                
               hud.label.text = @"上传头像出错, 您可以稍后再次上传";
                
            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kShowHUDShort * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [hud hideAnimated:YES];
                
                 [self dismissViewControllerAnimated:YES completion:^{
                     
                     MBProgressHUD *hud = [ZWHUDTool excutingHudInView:[UIApplication sharedApplication].keyWindow title:nil];
                     
                     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kShowHUDMid * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                         [hud hideAnimated:YES];
                         
                         ZWTabBarController *tabrBarController = [[ZWTabBarController alloc] init];
                         [UIApplication sharedApplication].keyWindow.rootViewController = tabrBarController;
                     });
                 }];
            });
            
        }];
    });
}

/**
 *  @author Administrator, 16-09-01 00:09:56
 *
 *  处理需要更多账号信息的方法，例如需要输入验证码
 */
- (void)handleNeedMore:(NSDictionary *)res {
    isNeedMore = YES;
    // 构建更多参数
    self.moreInfo = [res objectForKey:@"sendback"];
    NSDictionary *code = [[res objectForKey:@"prompt"] objectForKey:@"code"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kShowHUDMid * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self addVerifyView:[code objectForKey:@"data"]];
    });
}

/**
 *  @author Administrator, 16-09-01 00:09:47
 *
 *  当需要验证码信息时，从响应中读取数据转为图片，添加需要的视图，然后设置验证码图片
 *
 *  @param base64String 响应中的base64字符串
 */
- (void)addVerifyView:(NSString *)base64String {
    // base64字符串转为NSData
    NSData *data = [[NSData alloc] initWithBase64EncodedString:base64String options:NSDataBase64DecodingIgnoreUnknownCharacters];
    // NSData转为图片，即显示验证码的图片
    UIImage *verifyCodeImage = [UIImage imageWithData:data];
    
    __weak __typeof(self) weakSelf = self;
    
    // 若验证码视图相关空间为空，说明未初始化验证码视图并添加至父视图，故可以此判断是否已经添加过验证码视图
    if (!_verifyField) {
        
        NSLog(@"未添加验证码相关视图，执行添加过程");
        
        // 未初始化验证码相关视图， 执行初始化并更新必要视图约束
        
        // 1.初始化并添加视图
        _verifyField = [self commonTextField];
        _verifyField.placeholder = @"验证码";
        [self.view addSubview:_verifyField];
        
        _verifyLine = [self commonLine];
        [self.view addSubview:_verifyLine];
        
        _verifyImageView = [[UIImageView alloc] init];
        [self.view addSubview:_verifyImageView];
        
        // 2.设置视图约束 并更新必要约束
        
        CGFloat margin = 10.f;
        CGFloat midMargin = 20.f;
        CGFloat largeMargin = 30.f;
        CGFloat textFieldHeight = 30.f;
        CGFloat lineHiehgt = .5f;
        
        [_nextBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            // 此处距passwordLine距离增加了midMargin + textFieldHeight 以为需要添加验证码相关视图
            make.top.equalTo(weakSelf.passwordLine.mas_bottom).with.offset(largeMargin + midMargin + textFieldHeight);
            
        }];
        
        [UIView animateWithDuration:0.3 animations:^{
            
            [_nextBtn layoutIfNeeded];
            
        } completion:^(BOOL finished) {
            
            [_verifyField mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(weakSelf.passwordLine.mas_bottom).with.offset(midMargin);
                make.left.equalTo(weakSelf.view).with.offset(margin);
                make.height.mas_equalTo(textFieldHeight);
                make.width.equalTo(weakSelf.view).multipliedBy(0.7);
            }];
            
            [_verifyImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(weakSelf.verifyField.mas_right);
                make.bottom.equalTo(weakSelf.verifyField);
                make.right.equalTo(weakSelf.view).with.offset(- margin);
                make.height.mas_equalTo(textFieldHeight);
            }];
            
            [_verifyLine mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(weakSelf.view).with.offset(margin);
                make.right.equalTo(weakSelf.view).with.offset(- margin);
                make.height.mas_equalTo(lineHiehgt);
                make.top.equalTo(weakSelf.verifyField.mas_bottom);
            }];
            
            
        }];
        
        
        
    }
    
    _verifyImageView.image = verifyCodeImage;
}

- (RACSignal *)bindAccountSignal {
    
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        @strongify(self)
        
        
        [self.nextBtn setTitle:@"正在注册" forState:UIControlStateDisabled];
        [self.indicator startAnimating];
        
        //FIXME: 需要删除version字段
        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:self.registerParam];
        [params addEntriesFromDictionary:@{
                                           
                                           @"schoolUn": self.accountField.text,
                                           @"schoolPw": self.passwordField.text,
                                           @"enterYear": @"2014",
                                           @"version": @1
                                           }];
        
        if (isNeedMore && self.verifyField && self.verifyField.text.length != 0) {
            
            NSMutableDictionary *schoolMore = [NSMutableDictionary dictionaryWithDictionary:@{@"code": self.verifyField.text}];
            [schoolMore addEntriesFromDictionary:self.moreInfo];
            
            [params addEntriesFromDictionary:@{@"schoolMore": schoolMore}];
            NSLog(@"需要验证码信息，完整参数: %@", params);
        } else {
            NSLog(@"不需要验证码信息，完整参数: %@", params);
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

            [self.manager POST:[ZWAPITool registerAPI]
               parameters:params
                 progress:nil
                  success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                      
                      [subscriber sendNext:responseObject];
                      [subscriber sendCompleted];
                      
                  }
                  failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                      [subscriber sendError:error];
                     
                  }];
            
        });
        
        return nil;
        
    }];
}

- (BOOL)isAccountValid:(NSString *)value {
    return value.length >= AccountValidCondition;
}

- (BOOL)isPasswordValid:(NSString *)value {
    return value.length >= PasswordValidCondition;
}

- (void)createSubViews {
    
    //创建并添加至父视图
    self.titleLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.font = ZWFont(22);
        label.textColor = [UIColor blackColor];
        label.text = @"绑定您的教务处账号";
        [label sizeToFit];
        [self.view addSubview:label];
        
        label;
    });
    
    self.accountField = ({
        UITextField *textField = [self commonTextField];
        textField.placeholder = @"教务处账号";
        [self.view addSubview:textField];
        
        textField;
    });
    
    self.accountLine = [self commonLine];
    [self.view addSubview:self.accountLine];
    
    self.passwordField = ({
        UITextField *textField = [self commonTextField];
        textField.placeholder = @"教务处密码";
        textField.secureTextEntry = YES;
        [self.view addSubview:textField];
        
        textField;
    });
    
    self.passwordLine = [self commonLine];
    [self.view addSubview:self.passwordLine];
    
    
    self.nextBtn = ({
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setBackgroundImage:[RGB(80., 140., 238.) parseToImage] forState:UIControlStateNormal];
        [btn setBackgroundImage:[[UIColor lightGrayColor] parseToImage] forState:UIControlStateDisabled];
        [btn setTitle:@"注册" forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.layer.cornerRadius = 5;
        btn.layer.masksToBounds = YES;
        
        [self.view addSubview:btn];
        
        btn;
    });
    
    _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [_nextBtn addSubview:_indicator];
    
    //FIXME: 发布时需要删除
    // 预先设置数据 方便调试
    
    self.accountField.text = @"3136309003";
    self.passwordField.text = @"L243216!!";
    
    //设置视图约束
    
    __weak __typeof(self) weakSelf = self;
    
    CGFloat margin = 10.f;
    CGFloat midMargin = 20.f;
    CGFloat largeMargin = 30.f;
    
    CGFloat textFieldHeight = 30.f;
    CGFloat lineHiehgt = .5f;
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.view);
        make.centerY.equalTo(weakSelf.view).multipliedBy(.5f);
    }];
    
    [@[self.accountField, self.accountLine, self.passwordField, self.passwordLine, self.nextBtn] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(weakSelf.view).with.offset(margin);
        make.right.equalTo(weakSelf.view).with.offset(- margin);
    }];
    
    [@[self.accountLine, self.passwordLine] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(lineHiehgt);
    }];
    
    [@[self.accountField, self.passwordField] mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(textFieldHeight);
    }];
    
    //以accountLine位置为中心位置
    [self.accountLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf.view);
    }];
    
    [self.accountField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(weakSelf.accountLine.mas_top);
    }];
    
    [self.passwordField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.accountLine.mas_bottom).with.offset(midMargin);
    }];
    
    [self.passwordLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.passwordField.mas_bottom);
    }];
    
    [self.nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.passwordLine.mas_bottom).with.offset(largeMargin);
        make.height.mas_equalTo(45.f);
    }];
    
    [_indicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(weakSelf.nextBtn);
        make.right.equalTo(weakSelf.nextBtn.titleLabel.mas_left).with.offset(- margin);
    }];
}

- (UIView *)commonLine {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = RGB(240., 240., 240.);
    return view;
}

- (UITextField *)commonTextField {
    UITextField *textField = [[UITextField alloc] init];
    textField.borderStyle = UITextBorderStyleNone;
    textField.font = ZWFont(17);
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    return textField;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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