//
//  VLTransformationServiceVendor.m
//  CFLGenerator
//
//  Created by Jeffrey Varner on 5/7/13.
//  Copyright (c) 2013 Varnerlab. All rights reserved.
//

#import "VLTransformationServiceVendor.h"

@implementation VLTransformationServiceVendor

// synthesize
@synthesize myBlueprintTree = _myBlueprintTree;
@synthesize myTransformationName = _myTransformationName;
@synthesize myLanguageAdaptor = _myLanguageAdaptor;

-(void)dealloc
{
    [self cleanMyMemory];
}

-(void)cleanMyMemory
{
    self.myBlueprintTree = nil;
    self.myTransformationName = nil;
    self.myLanguageAdaptor = nil;
}

-(void)postMessageTransformationMessage:(NSString *)message
{
    // dispatch -
    dispatch_async(dispatch_get_main_queue(), ^{
        
        // Make a message and send -
        NSNotification *myNotification = [NSNotification notificationWithName:VLTransformationJobProgressUpdateNotification
                                                                       object:message];
        
        [[NSNotificationCenter defaultCenter] postNotification:myNotification];
    });
}

#pragma mark - override these methods in subclass
-(void)startTransformationWithName:(NSString *)transformationName
{
    
}

-(void)stopTransformation
{
    
}


@end
