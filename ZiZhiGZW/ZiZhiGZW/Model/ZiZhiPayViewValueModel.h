//
//  ZiZhiPayViewValueModel.h
//  ZiZhiGZW
//
//  Created by zyz on 12/18/15.
//  Copyright © 2015 zizhi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZiZhiPayViewValueModel : NSObject
@property (strong, nonatomic) NSString *detail;
@property (strong, nonatomic) NSString *price;
@property (strong, nonatomic) NSString *orderId;

@property (strong, nonatomic) NSString *idcardnumber;
@property (strong, nonatomic) NSString *phone;

+ (instancetype)sharedModel;
@end