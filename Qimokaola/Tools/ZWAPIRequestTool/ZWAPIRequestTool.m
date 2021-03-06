//
//  ZWAPIRequestTool.m
//  Qimokaola
//
//  Created by Administrator on 16/8/28.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWAPIRequestTool.h"


@implementation ZWAPIRequestTool

+ (void)requestSendCodeWithParameter:(id)param result:(APIRequestResult)result {
    
    [ZWAPIRequestTool requestWithAPI:[ZWAPITool sendCodeAPI]
                          parameters:param
                              result:result];
    
}

+ (void)requestSmsSendCodeWithPhoneNumber:(NSString *)phoneNumber result:(APIRequestResult)result {
    [ZWAPIRequestTool requestWithAPI:[ZWAPITool smsSendCodeAPI]
                          parameters:@{@"phone" : phoneNumber}
                              result:result];
}

+ (void)requestVerifyCodeWithParameter:(id)param result:(APIRequestResult)result {
    
    [ZWAPIRequestTool requestWithAPI:[ZWAPITool verifyCodeAPI]
                          parameters:param
                              result:result];
    
}

+ (void)requestSmsVerifyCodeWithCode:(NSString *)code result:(APIRequestResult)result {
    
    [ZWAPIRequestTool requestWithAPI:[ZWAPITool smsVerifyCodeAPI]
                          parameters:@{@"code": code}
                              result:result];
    
}

+ (void)requestListSchool:(APIRequestResult)result {
    [ZWAPIRequestTool requestWithAPI:[ZWAPITool listSchoolAPI]
                          parameters:nil
                              result:result];
}

+ (void)requestListAcademyWithParameter:(id)param result:(APIRequestResult)result {
    [ZWAPIRequestTool requestWithAPI:[ZWAPITool listAcademyAPI]
                          parameters:param
                              result:result];
}


+ (void)requestLoginWithParameters:(id)params result:(APIRequestResult)result {
    [ZWAPIRequestTool requestWithAPI:[ZWAPITool loginAPI]
                          parameters:params
                              result:result];
}

+ (void)requestUploadAvatarWithParamsters:(id)params
                constructingBodyWithBlock:(void (^)(id<AFMultipartFormData>))block
                                   result:(APIRequestResult)result {
    
    
    [ZWNetworkingManager postWithURLString:[ZWAPITool uploadAvatarAPI]
                                    params:[ZWAPIRequestTool buildParameters:params ? params : @{}]
                 constructingBodyWithBlock:block
                                  progress:nil
                                   success:^(NSURLSessionDataTask *task, id responseObject) {
                                      
                                       if (result) {
                                           result(responseObject, YES);
                                       }
                                       
                                   }
                                   failure:^(NSURLSessionDataTask *task, NSError *error) {
                                       
                                       if (result) {
                                           result(error, NO);
                                       }
                                   }];
}

+ (void)requestUserInfo:(APIRequestResult)result {
    [ZWAPIRequestTool requestWithAPI:[ZWAPITool userInfoAPI]
                          parameters:nil
                              result:result];
}

+ (void)requstFileAndFolderListInSchool:(NSNumber *)collegeId
                             path:(NSString *)path
                       needDetail:(BOOL)needDetail
                           result:(APIRequestResult)result {
    NSDictionary *params = @{@"path": path, @"detail": @(needDetail)};
    NSString *listAPI = [NSString stringWithFormat:[ZWAPITool listFileAndFolderAPI], [collegeId intValue]];
    [ZWAPIRequestTool requestWithAPI:listAPI
                          parameters:params
                              result:result];
}

+ (void)requestModifyUserInfoWithParameters:(id)params result:(APIRequestResult)result {
    [ZWAPIRequestTool requestWithAPI:[ZWAPITool modifyUserInfoAPI]
                          parameters:params
                              result:result];
}

+ (void)requestLogout:(APIRequestResult)result {
    [ZWAPIRequestTool requestWithAPI:[ZWAPITool logoutAPI]
                          parameters:nil
                              result:result];
}

+ (void)requestDownloadUrlInSchool:(NSNumber *)collegeId path:(NSString *)path result:(APIRequestResult)result {
    [ZWAPIRequestTool requestWithAPI:[NSString stringWithFormat:[ZWAPITool downloadUrlAPI], collegeId.intValue]
                          parameters:@{@"path" : path}
                              result:result];
}

+ (void)reuqestInfoByName:(NSString *)username result:(APIRequestResult)result {
    [ZWAPIRequestTool requestWithAPI:[ZWAPITool infoByNameAPI]
                          parameters:@{@"nickname" : username}
                              result:result];
}

+ (void)requestResetPasswordWithUserName:(NSString *)userName newPassword:(NSString *)newPassword result:(APIRequestResult)result {
    [ZWAPIRequestTool requestWithAPI:[ZWAPITool resetPwdAPI]
                          parameters:@{@"username" : userName, @"password" : newPassword}
                              result:result];
}

+ (void)requestSBInfo:(APIRequestResult)result {
    [ZWAPIRequestTool requestWithAPI:[ZWAPITool sbAPI]
                          parameters:nil
                              result:result];
}

+ (void)requestAppInfo:(APIRequestResult)result {
    [ZWNetworkingManager getWithURLString:[ZWAPITool appInfoAPI]
                                  success:^(NSURLSessionDataTask *task, id responseObject) {
                                      if (result) {
                                          result(responseObject, YES);
                                      }
                                  }
                                  failure:^(NSURLSessionDataTask *task, NSError *error) {
                                      if (result) {
                                          result(error, NO);
                                      }
                                  }];
}

// 通用请求接口，针对接收字典参数的接口
+ (void)requestWithAPI:(NSString *)API parameters:(id)params result:(APIRequestResult)result {
    [ZWNetworkingManager postWithURLString:API
                                    params:[ZWAPIRequestTool buildParameters:params ? params : @{}]
                                   success:^(NSURLSessionDataTask *task, id responseObject) {
                                       if ([[responseObject objectForKey:kHTTPResponseInfoKey] isEqualToString:kUserNotLoginInfo]) {
                                           [[NSNotificationCenter defaultCenter] postNotificationName:kUserNeedLoginNotification object:nil];
                                       }
                                       if (result) {
                                           result(responseObject, YES);
                                       }
                                   }
                                   failure:^(NSURLSessionDataTask *task, NSError *error) {
                                       if (result) {
                                           result(error, NO);
                                       }
                                   }];
    
}


+ (id)buildParameters:(id)param {
    
    if ([param isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject:@1 forKey:@"version"];
        [dict addEntriesFromDictionary:param];
        return dict;
    } else if ([param isKindOfClass:[NSString class]]) {
        NSMutableString *validParams = [param mutableCopy];
        [validParams insertString:@"\n  \"version\":1" atIndex:1];
        return validParams;
    }
    return nil;
}



@end
