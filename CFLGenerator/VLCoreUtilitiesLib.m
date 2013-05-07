//
//  VLCoreUtilitiesLib.m
//  CFLGenerator
//
//  Created by Jeffrey Varner on 5/7/13.
//  Copyright (c) 2013 Varnerlab. All rights reserved.
//

#import "VLCoreUtilitiesLib.h"

@implementation VLCoreUtilitiesLib


#pragma mark - load/parse file methods
+(NSXMLDocument *)createXMLDocumentFromFile:(NSURL *)fileURL
{
    // Make sure we have a URL -
    if (fileURL==nil)
    {
        NSLog(@"ERROR: Blueprint file URL is nil.");
        return nil;
    }
    
    // Create error instance -
	NSError *errObject = nil;
	
    // Set the NSXMLDocument reference on the tree model
	NSXMLDocument *tmpDocument = [[NSXMLDocument alloc] initWithContentsOfURL:fileURL
                                                                      options:NSXMLNodeOptionsNone error:&errObject];
    
    // Check to make sure all is ok -
    if (errObject==nil)
    {
        // return -
        return tmpDocument;
    }
    else
    {
        NSLog(@"ERROR in createXMLDocumentFromFile: = %@",[errObject description]);
        return nil;
    }
}

+(NSMutableArray *)loadGenericFlatFile:(NSString *)filePath
                 withRecordDeliminator:(NSString *)recordDeliminator
                  withFieldDeliminator:(NSString *)fieldDeliminator
{
    // Method attributes -
    NSError *error = nil;
    NSMutableArray *tmpArray = [NSMutableArray array];
    
    // Load the file -
    NSURL *tmpFileURL = [NSURL fileURLWithPath:filePath isDirectory:NO];
    
    // Load the file -
    NSString *fileString = [NSString stringWithContentsOfURL:tmpFileURL encoding:NSUTF8StringEncoding error:&error];
    
    // Ok, we need to walk through this file, and put it an array -
    NSScanner *scanner = [NSScanner scannerWithString:fileString];
    while (![scanner isAtEnd])
    {
        // Ok, let'd grab a row -
        NSString *tmpString;
        [scanner scanUpToString:recordDeliminator intoString:&tmpString];
        
        // Skip comments -
        NSRange range = [tmpString rangeOfString:@"//" options:NSCaseInsensitiveSearch];
        if(range.location == NSNotFound)
        {
            // Ok, so let's cut around the tabs -
            NSArray *chunks = [tmpString componentsSeparatedByString:fieldDeliminator];
            
            // Load the row -
            [tmpArray addObject:chunks];
        }
    }
    
    // return -
    return [NSArray arrayWithArray:tmpArray];
}


+(void)writeBuffer:(NSString *)buffer
             toURL:(NSURL *)fileURL
{
    // write -
    NSError *error = nil;
    [buffer writeToFile:[fileURL path]
             atomically:YES
               encoding:NSUTF8StringEncoding
                  error:&error];
    
    if (error!=nil)
    {
        NSLog(@"ERROR: There is an issue writing the simulations results to disk - %@",[error description]);
    }
}


#pragma mark - xpath methods
+(NSArray *)executeXPathQuery:(NSString *)xpath withXMLTree:(NSXMLDocument *)document
{
    // Check for null args
    if (xpath==nil || document==nil)
    {
        NSLog(@"ERROR: Either the xpath string or the document was nil");
        return nil;
    }
    
    // Execute -
    NSError *error = nil;
    NSArray *tmpArray = [document nodesForXPath:xpath error:&error];
    
    // Check -
    if (error!=nil)
    {
        NSLog(@"ERROR - xpath = %@ did not complete",[error description]);
    }
    else
    {
        return tmpArray;
    }
    
    // return -
    return nil;
}

+(NSString *)lookupInputPathForTransformationWithName:(NSString *)transformName
                                               inTree:(NSXMLDocument *)blueprintTree
{
    // Formulate the xpath -
    NSString *xpath = [NSString stringWithFormat:@"//Transformation[@name='%@']/property[@key='INPUT_FILE_PATH']/@value",transformName];
    NSArray *resultArray = [VLCoreUtilitiesLib executeXPathQuery:xpath withXMLTree:blueprintTree];
    if (resultArray!=nil)
    {
        NSXMLElement *pathElment = [resultArray lastObject];
        return [pathElment stringValue];
    }
    else
    {
        return nil;
    }
}


+(NSString *)lookupOutputPathForTransformationWithName:(NSString *)transformName
                                                inTree:(NSXMLDocument *)blueprintTree
{
    // Formulate the xpath -
    NSString *xpath = [NSString stringWithFormat:@"//Transformation[@name='%@']/property[@key='OUTPUT_FILE_PATH']/@value",transformName];
    NSArray *resultArray = [VLCoreUtilitiesLib executeXPathQuery:xpath withXMLTree:blueprintTree];
    if (resultArray!=nil)
    {
        NSXMLElement *pathElment = [resultArray lastObject];
        return [pathElment stringValue];
    }
    else
    {
        return nil;
    }
}


@end
