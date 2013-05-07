//
//  VLCodeGenerationFoundationServer.m
//  CFLGenerator
//
//  Created by Jeffrey Varner on 5/7/13.
//  Copyright (c) 2013 Varnerlab. All rights reserved.
//

#import "VLCodeGenerationFoundationServer.h"
#import "VLCodeGenerationOperation.h"

@interface VLCodeGenerationFoundationServer ()

// Private lifecycle methods -
-(void)setup;
-(void)cleanMyMemory;

@end

@implementation VLCodeGenerationFoundationServer

// static instance returned when we get the shared instance -
static VLCodeGenerationFoundationServer *_sharedInstance;

// synthesize -
@synthesize myCodeTransformationProcessQueue = _myCodeTransformationProcessQueue;
@synthesize myTransformationBlueprintTree = _myTransformationBlueprintTree;

// static accessor methods -
+(VLCodeGenerationFoundationServer *)sharedFoundationServer
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

+(void)shutdownSharedServer
{
    @synchronized(self)
    {
        // set the shared pointer to nil?
        _sharedInstance = nil;
    }
}

- (id)init
{
    self = [super init];
    if (self)
    {
        // initialize me ...
        [self setup];
    }
    
    // return self -
    return self;
}


-(void)dealloc
{
    [self cleanMyMemory];
}

#pragma mark - job methods
-(void)performSingleOperationWithName:(NSString *)operationName
                                block:(MyVarnerlabCodeGenerationOperationBlock)operation
                           completion:(MyVarnerlabCodeGenerationOperationCompletionBlock)completion
{
    // Create a new operation to wrap the operation and completion block -
    VLCodeGenerationOperation *operationObject = [[VLCodeGenerationOperation alloc] init];
    
    // set the operation block -
    [operationObject setCodeGenerationOperationBlock:operation];
    
    // set the completion block -
    [operationObject setCompletionBlock:completion];
    
    // Set ooperation name -
    [operationObject setMyOperationName:operationName];
    
    // ok, load the block onto the queue -
    [[self myCodeTransformationProcessQueue] addOperation:operationObject];
}


#pragma mark - private lifecycle
-(void)setup
{
    
    // create the transformation queue -
    if ([self myCodeTransformationProcessQueue]==nil)
    {
        // Fire up a new process queue -
        self.myCodeTransformationProcessQueue = [[NSOperationQueue alloc] init];
        
        // Setup KVO so I can see when the queue has completed all operations
        [[self myCodeTransformationProcessQueue] addObserver:self
                                                  forKeyPath:@"operationCount"
                                                     options:0
                                                     context:nil];
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary *)change
                      context:(void *)context
{
    
    if (object==self.myCodeTransformationProcessQueue &&
        [keyPath isEqualToString:@"operationCount"])
    {
        if ([[self myCodeTransformationProcessQueue] operationCount]==0)
        {
            // Fire all transformations are complete message -
            NSNotification *myNotification = [NSNotification notificationWithName:VLTransformationJobDidCompleteNotification
                                                                           object:nil];
            
            [[NSNotificationCenter defaultCenter] postNotification:myNotification];
        }
    }
}

-(void)cleanMyMemory
{
    // Clean my iVars -
    self.myCodeTransformationProcessQueue = nil;
    self.myTransformationBlueprintTree = nil;

    
    // Remove me from the NSNotificationCenter -
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
