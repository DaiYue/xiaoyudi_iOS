//
//  HAMTools.m
//  iosapp
//
//  Created by daiyue on 13-7-30.
//  Copyright (c) 2013年 Droplings. All rights reserved.
//

#import "HAMTools.h"

@implementation HAMTools

+(void)setObject:(id)object toMutableArray:(NSMutableArray*)array atIndex:(int)pos
{
    int i;
    for (i=[array count];i<pos;i++)
        [array addObject:[NSNull null]];
    [array setObject:object atIndexedSubscript:pos];
}

+(NSDictionary*)jsonFromData:(NSData*)data
{
    NSError* error;
    NSDictionary* dic = [NSJSONSerialization
                          JSONObjectWithData:data
                          options:kNilOptions
                          error:&error];
    
    if (error)
        NSLog(@"json parse error:%@",error);
    return dic;
}

@end