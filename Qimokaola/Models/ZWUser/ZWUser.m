//
//  ZWUser.m
//  Qimokaola
//
//  Created by Administrator on 16/9/4.
//  Copyright © 2016年 Administrator. All rights reserved.
//

#import "ZWUser.h"
#import <YYKit/YYKit.h>

@implementation ZWUser

- (void)encodeWithCoder:(NSCoder *)aCoder { [self modelEncodeWithCoder:aCoder]; }
- (id)initWithCoder:(NSCoder *)aDecoder { self = [super init]; return [self modelInitWithCoder:aDecoder]; }
- (id)copyWithZone:(NSZone *)zone { return [self modelCopy]; }
- (NSUInteger)hash { return [self modelHash]; }
- (BOOL)isEqual:(id)object { return [self modelIsEqual:object]; }
- (NSString *)description { return [self modelDescription]; }

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"uid" : @"id",
             @"academyId" : @"AcademyId",
             @"collegeId" : @"CollegeId",
             @"avatar_url" : @"avatar"};
}

@end
