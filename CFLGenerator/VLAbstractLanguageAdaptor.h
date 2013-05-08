//
//  VLAbstractLanguageAdaptor.h
//  CFLGenerator
//
//  Created by Jeffrey Varner on 5/7/13.
//  Copyright (c) 2013 Varnerlab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VLAbstractLanguageAdaptor : NSObject
{
    
}

// public methods -
-(NSString *)generateDataFileBufferWithOptions:(NSDictionary *)options;
-(NSString *)generateKineticsBufferWithOptions:(NSDictionary *)options;
-(NSString *)generateSTMBufferWithOptions:(NSDictionary *)options;
-(NSString *)generateMappingMatrixBufferWithOptions:(NSDictionary *)options;
-(NSString *)generateCalculateSystemArraysBufferWithOptions:(NSDictionary *)options;
-(NSString *)generateSignalDriverBufferWithOptions:(NSDictionary *)options;

@end
