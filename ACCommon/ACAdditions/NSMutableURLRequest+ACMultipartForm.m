//
//  NSMutableURLRequest+ACMultipartForm.m
//  ACCommon
//
//  Created by 暁星 on 15/7/17.
//  Copyright (c) 2015年 Stone.y. All rights reserved.
//

#import "NSMutableURLRequest+ACMultipartForm.h"

#import <pthread.h>

@implementation NSMutableURLRequest (ACMultipartForm)

+ (void)initialize {
    pthread_mutex_t mutex;
    pthread_mutex_init(&mutex, NULL);
}

@end
