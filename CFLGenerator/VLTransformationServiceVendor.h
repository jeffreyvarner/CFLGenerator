//
//  VLTransformationServiceVendor.h
//  CFLGenerator
//
//  Created by Jeffrey Varner on 5/7/13.
//  Copyright (c) 2013 Varnerlab. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VLAbstractLanguageAdaptor;

@interface VLTransformationServiceVendor : NSObject
{
    @protected
    NSXMLDocument *_myBlueprintTree;
    NSString *_myTransformationName;
    VLAbstractLanguageAdaptor *_myLanguageAdaptor;
    
}

// Properties -
@property (retain) NSXMLDocument *myBlueprintTree;
@property (retain) NSString *myTransformationName;
@property (strong) VLAbstractLanguageAdaptor *myLanguageAdaptor;

// Methods
-(void)cleanMyMemory;
-(void)startTransformationWithName:(NSString *)transformationName;
-(void)stopTransformation;
-(void)postMessageTransformationMessage:(NSString *)message;

@end
