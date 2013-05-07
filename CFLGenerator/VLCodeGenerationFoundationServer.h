//
//  VLCodeGenerationFoundationServer.h
//  CFLGenerator
//
//  Created by Jeffrey Varner on 5/7/13.
//  Copyright (c) 2013 Varnerlab. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VLCodeGenerationOperation;

@interface VLCodeGenerationFoundationServer : NSObject
{
    @private
    NSOperationQueue *_myCodeTransformationProcessQueue;
    NSXMLDocument *_myTransformationBlueprintTree;
}

// properties -
@property (retain) NSOperationQueue *myCodeTransformationProcessQueue;
@property (retain) NSXMLDocument *myTransformationBlueprintTree;

// methods
+(VLCodeGenerationFoundationServer *)sharedFoundationServer;
+(void)shutdownSharedServer;

// job logic -
-(void)performSingleOperationWithName:(NSString *)operationName
                                block:(MyVarnerlabCodeGenerationOperationBlock)operation
                           completion:(MyVarnerlabCodeGenerationOperationCompletionBlock)completion;


@end
