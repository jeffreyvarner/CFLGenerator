//
//  VLCFLMLToEvaluateSignalEquationsVendor.m
//  CFLGenerator
//
//  Created by Jeffrey Varner on 5/8/13.
//  Copyright (c) 2013 Varnerlab. All rights reserved.
//

#import "VLCFLMLToEvaluateSignalEquationsVendor.h"
#import "VLAbstractLanguageAdaptor.h"

@implementation VLCFLMLToEvaluateSignalEquationsVendor

-(void)startTransformationWithName:(NSString *)transformationName
{
    // grab the name (before we start) -
    self.myTransformationName = transformationName;
    
    // Get the code generation engine -
    VLCodeGenerationFoundationServer *codeGenerationEngine = [VLCodeGenerationFoundationServer sharedFoundationServer];
    
    // Get file paths -
    NSString *inputFilePath = [VLCoreUtilitiesLib lookupInputPathForTransformationWithName:transformationName inTree:[self myBlueprintTree]];
    NSString *outputFilePath = [VLCoreUtilitiesLib lookupOutputPathForTransformationWithName:transformationName inTree:[self myBlueprintTree]];
    
    // Formulate the blocks and go -
    __block NSMutableString *buffer = [[NSMutableString alloc] init];
    NSXMLDocument *myBlueprintDocument = [self myBlueprintTree];
    
    // Setup blocks -
    // Input handler block -
    void (^VLOperationBlock)(void) = ^{
        
        // Create the buffer -
        buffer = [NSMutableString string];
        
        // Create file URL -
        NSString *fullPathString = [NSString stringWithFormat:@"file://%@",inputFilePath];
        NSURL *fileURL = [NSURL URLWithString:fullPathString];
        
        // Load the SBML file from disk -
        NSXMLDocument *cflmlDocument = [VLCoreUtilitiesLib createXMLDocumentFromFile:fileURL];
        
        // Use my language adaptor to generate data file code in specified language -
        NSDictionary *options = @
        {
            kXMLModelTree : cflmlDocument,
            kXMLTransformationTree : myBlueprintDocument
        };
        
        NSString *code_block = [[self myLanguageAdaptor] generateEvaluateSignalEquationsBufferWithOptions:options];
        [buffer appendString:code_block];
    };
    
    // Output handler block -
    void (^VLCompletionBlock)(void) = ^{
        
        // dump the buffer to disk -
        NSString *fullPathString = [NSString stringWithFormat:@"file://%@",outputFilePath];
        NSURL *fileURL = [NSURL URLWithString:fullPathString];
        
        // Create *final* output string -
        NSString *output = [NSString stringWithString:buffer];
        
        // dump -
        [VLCoreUtilitiesLib writeBuffer:output toURL:fileURL];
    };
    
    
    // No dependecy, launch single operation -
    [codeGenerationEngine performSingleOperationWithName:transformationName
                                                   block:VLOperationBlock
                                              completion:VLCompletionBlock];
}

-(void)stopTransformation
{
    
}


@end
