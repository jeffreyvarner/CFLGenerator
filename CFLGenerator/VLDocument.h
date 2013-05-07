//
//  VLDocument.h
//  CFLGenerator
//
//  Created by Jeffrey Varner on 5/7/13.
//  Copyright (c) 2013 Varnerlab. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class VLTransformationServiceVendor;
@class VLAbstractLanguageAdaptor;

@interface VLDocument : NSDocument
{
    @private
    NSTextField *_myBlueprintFileTextField;
    NSTextField *_myProgressUpdateTextField;
    NSProgressIndicator *_myProgressIndicator;
    NSWindowController *_myWindowController;
    NSURL *_myBlueprintFileURL;
}

// Actions -
-(IBAction)codeGenerationBeginGenerationButtonWasTapped:(NSButton *)button;
-(IBAction)codeGenerationCancelGenerationButtonWasTapped:(NSButton *)button;
-(IBAction)codeGenerationLoadTransformationBlueprintButtonWasTapped:(NSButton *)button;

@end
