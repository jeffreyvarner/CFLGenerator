//
//  VLCodeGenerationOperation.m
//  CFLGenerator
//
//  Created by Jeffrey Varner on 5/7/13.
//  Copyright (c) 2013 Varnerlab. All rights reserved.
//

#import "VLCodeGenerationOperation.h"

@interface VLCodeGenerationOperation ()

// private props -
@property (strong) MyVarnerlabCodeGenerationOperationBlock myOperationBlock;

@end

@implementation VLCodeGenerationOperation

// synthesize -
@synthesize myOperationBlock = _myOperationBlock;
@synthesize myOperationName = _myOperationName;

#pragma mark - main method
-(void)main
{
    if ([self myOperationBlock]!=nil)
    {
        // ok, so let's execute the block -
        MyVarnerlabCodeGenerationOperationBlock operationBlock = [self myOperationBlock];
        operationBlock();
    }
}

-(void)setCodeGenerationOperationBlock:(MyVarnerlabCodeGenerationOperationBlock)block
{
    // This should copy the block onto the heap -
    self.myOperationBlock = block;
}

-(void)dealloc
{
    NSLog(@"Dealloc called on %@",[[self class] description]);
    [self cleanMyMemory];
}


#pragma mark - private lifecycle methods
-(void)cleanMyMemory
{
    self.myOperationBlock = nil;
    self.myOperationName = nil;
}

@end
