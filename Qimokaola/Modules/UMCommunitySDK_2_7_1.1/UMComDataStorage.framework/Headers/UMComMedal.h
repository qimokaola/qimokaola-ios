//
//  UMComMedal.h
//  UMCommunity
//
//  Created by umeng on 16/2/21.
//  Copyright © 2016年 Umeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "UMComModelObject.h"

@class UMComUser;


@interface UMComMedal : UMComModelObject

/**
 勋章类别
 */
@property (nullable, nonatomic, retain) NSString *classify;
/**
 勋章创建时间
 */
@property (nullable, nonatomic, retain) NSString *create_time;
/**
 勋章描述
 */
@property (nullable, nonatomic, retain) NSString *desc;
/**
 勋章icon_url
 */
@property (nullable, nonatomic, retain) NSString *icon_url;
/**
 勋章唯一ID
 */
@property (nullable, nonatomic, retain) NSString *medal_id;
/**
 勋章名称
 */
@property (nullable, nonatomic, retain) NSString *name;
/**
 
 */
@property (nullable, nonatomic, retain) NSNumber *person_num;



@end

