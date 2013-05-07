//
//  VLDocument.m
//  CFLGenerator
//
//  Created by Jeffrey Varner on 5/7/13.
//  Copyright (c) 2013 Varnerlab. All rights reserved.
//

#import "VLDocument.h"
#import "VLTransformationServiceVendor.h"

@interface VLDocument ()

// private methods -
-(void)cleanMyMemory;

// private props and outlets -
@property (retain) IBOutlet NSTextField *myBlueprintFileTextField;
@property (retain) IBOutlet NSProgressIndicator *myProgressIndicator;
@property (retain) IBOutlet NSTextField *myProgressUpdateTextField;
@property (retain) NSWindowController *myWindowController;
@property (retain) NSURL *myBlueprintFileURL;


@end

@implementation VLDocument

// synthesize -
@synthesize myBlueprintFileTextField = _myBlueprintFileTextField;
@synthesize myProgressUpdateTextField = _myProgressUpdateTextField;
@synthesize myProgressIndicator = _myProgressIndicator;
@synthesize myWindowController = _myWindowController;
@synthesize myBlueprintFileURL = _myBlueprintFileURL;


- (id)init
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
    }
    return self;
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"VLDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *)aController
{
    // Ok, call the super -
    [super windowControllerDidLoadNib:aController];
    
    // grab the controller -
    self.myWindowController = aController;
    
    // Start the foundation server -
    [VLCodeGenerationFoundationServer sharedFoundationServer];
    
    // Setup completion notification -
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
    
    // VLTransformationJobUpdateNotification -
    [center addObserverForName:VLTransformationJobProgressUpdateNotification
                        object:nil
                         queue:mainQueue
                    usingBlock:^(NSNotification *notification){
                        
                        // Get the message from the notification -
                        NSString *message = [notification object];
                        
                        // update the label -
                        [[self myProgressUpdateTextField] setStringValue:message];
                    }];
    
    // VLTransformationJobCompletedNotification -
    [center addObserverForName:VLTransformationJobDidCompleteNotification
                        object:nil
                         queue:mainQueue
                    usingBlock:^(NSNotification *notification){
                        
                        // shutdown the progress bar animation -
                        [[self myProgressIndicator] stopAnimation:nil];
                        
                        // Set the completed text -
                        [[self myProgressUpdateTextField] setStringValue:@"Status: Transformation completed."];
                    }];

}

+ (BOOL)autosavesInPlace
{
    return YES;
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning nil.
    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.
    NSException *exception = [NSException exceptionWithName:@"UnimplementedMethod" reason:[NSString stringWithFormat:@"%@ is unimplemented", NSStringFromSelector(_cmd)] userInfo:nil];
    @throw exception;
    return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to read your document from the given data of the specified type. If outError != NULL, ensure that you create and set an appropriate error when returning NO.
    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead.
    // If you override either of these, you should also override -isEntireFileLoaded to return NO if the contents are lazily loaded.
    NSException *exception = [NSException exceptionWithName:@"UnimplementedMethod" reason:[NSString stringWithFormat:@"%@ is unimplemented", NSStringFromSelector(_cmd)] userInfo:nil];
    @throw exception;
    return YES;
}

-(void)dealloc
{
    [self cleanMyMemory];
}


#pragma mark - actions
-(IBAction)codeGenerationBeginGenerationButtonWasTapped:(NSButton *)button
{
    // ok, so check to make sure we have a URL - if we do then begin the generation
    // process. If not, then open the open panel -
    if ([self myBlueprintFileURL]!=nil)
    {
        // start the progress bar animation -
        [[self myProgressIndicator] startAnimation:nil];
        
        // Ok, so when I get here I have the blueprint file URL.
        // We need to start the code generation process for this blueprint file.
        // Get the blueprint URL -
        NSURL *localBlueprintURL = [self myBlueprintFileURL];
        
        // Load the blueprint file -
        NSXMLDocument *blueprintTree = [VLCoreUtilitiesLib createXMLDocumentFromFile:localBlueprintURL];
        
        // Get the transformation xml blocks -
        NSArray *transformBlockNames = [VLCoreUtilitiesLib executeXPathQuery:@"//Transformation/@name"
                                                                          withXMLTree:blueprintTree];
        
        // Process the transformations -
        for (NSXMLElement *node in transformBlockNames)
        {
            // Get the name of this transformation -
            NSString *transformationName = [node stringValue];
            
            // update the progress text label -
            NSString *progressText = [NSString stringWithFormat:@"Status: Loaded %@ block",transformationName];
            [[self myProgressUpdateTextField] setStringValue:progressText];
            
            // Get the input and output classname -
            NSString *inputClassNameXPath = [NSString stringWithFormat:@"//Transformation[@name='%@']/@classname",transformationName];
            NSString *languageXPath = [NSString stringWithFormat:@"//Transformation[@name='%@']/@language",transformationName];
            
            // execute the query -
            NSString *inputClassName = [[[VLCoreUtilitiesLib executeXPathQuery:inputClassNameXPath
                                                                            withXMLTree:blueprintTree] lastObject] stringValue];
            
            NSString *languageClassName = [[[VLCoreUtilitiesLib executeXPathQuery:languageXPath
                                                                   withXMLTree:blueprintTree] lastObject] stringValue];
            
            // Build the input and output handlers -
            VLTransformationServiceVendor *vendor = [[NSClassFromString(inputClassName) alloc] init];
            VLAbstractLanguageAdaptor *language = [[NSClassFromString(languageClassName) alloc] init];
            
            // set the blueprint tree -
            [vendor setMyBlueprintTree:blueprintTree];
            [vendor setMyLanguageAdaptor:language];
            
            // execute the transformations -
            [vendor startTransformationWithName:transformationName];
        }
    }
    else
    {
        [self codeGenerationLoadTransformationBlueprintButtonWasTapped:nil];
    }
}

-(IBAction)codeGenerationCancelGenerationButtonWasTapped:(NSButton *)button
{
    
}

-(IBAction)codeGenerationLoadTransformationBlueprintButtonWasTapped:(NSButton *)button
{
    // Launch the NSOpenPanel logic, capture the user filename and present the path in the text fld
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    
    // Configure the panel -
    [openPanel setAllowsMultipleSelection:NO];
    [openPanel setCanChooseFiles:YES];
    [openPanel setCanCreateDirectories:YES];
    
    // Run the panel as a sheet -
    [openPanel beginSheetModalForWindow:[[self myWindowController] window]
                      completionHandler:^(NSInteger resultIndex){
                          
                          // Ok, so this block gets executed *after* we have selected a file
                          if (resultIndex == NSFileHandlingPanelOKButton)
                          {
                              // Ok, so when I get here the user has hit the OK button
                              NSURL *mySelectedURL = [openPanel URL];
                              
                              // grab this URL for later -
                              self.myBlueprintFileURL = mySelectedURL;
                              
                              // Create a file path string -
                              NSString *pathString = [mySelectedURL absoluteString];
                              
                              // Set the value in the text fld -
                              [[self myBlueprintFileTextField] setStringValue:pathString];
                          }
                          else if (resultIndex == NSFileHandlingPanelCancelButton)
                          {
                              // Ok, so when I get here the user has hit the cancel button
                              // for now, do nothing.
                          }
                          
                      }];
}

#pragma mark - private lifecycle methods
-(void)cleanMyMemory
{
    // clean my iVars -
    self.myProgressIndicator = nil;
    self.myBlueprintFileTextField = nil;
    self.myWindowController = nil;
    self.myBlueprintFileURL = nil;
}

@end
