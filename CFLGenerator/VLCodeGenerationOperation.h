//
//  VLCodeGenerationOperation.h
//  CFLGenerator
//
//  Created by Jeffrey Varner on 5/7/13.
//  Copyright (c) 2013 Varnerlab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VLCodeGenerationOperation : NSOperation
{
    @private
    MyVarnerlabCodeGenerationOperationBlock _myOperationBlock;
    NSString *_myOperationName;
}

// properties -
@property (retain) NSString *myOperationName;

// methods -
-(void)setCodeGenerationOperationBlock:(MyVarnerlabCodeGenerationOperationBlock)block;

@end
