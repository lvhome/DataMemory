//
//  LHKeyChain.h
//  PaineWebberPro
//
//  Created by mac on 2017/12/19.
//
//

#import <Foundation/Foundation.h>

@interface LHKeyChain : NSObject
+ (void)save:(NSString *)service data:(id)data;
+ (id)load:(NSString *)service;
+ (void)deleteKeyData:(NSString *)service;
@end
