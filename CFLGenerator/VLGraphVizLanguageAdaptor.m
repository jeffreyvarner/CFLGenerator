//
//  VLGraphVizLanguageAdaptor.m
//  CFLGenerator
//
//  Created by Jeffrey Varner on 5/22/13.
//  Copyright (c) 2013 Varnerlab. All rights reserved.
//

#import "VLGraphVizLanguageAdaptor.h"

@interface VLGraphVizLanguageAdaptor ()

// private helper methods
-(NSString *)buildDOTBufferFromSBMLTree:(NSXMLDocument *)sbmlTree;

@end

@implementation VLGraphVizLanguageAdaptor

-(NSString *)generateGraphvizNetworkVisualizationBufferWithOptions:(NSDictionary *)options
{
    // Buffer to build the array -
    NSMutableString *buffer = [NSMutableString string];
    
    // get the options from the dictionary -
    NSXMLDocument *model_tree = [options objectForKey:kXMLModelTree];
    
    // build the dot-buffer
    NSString *dot_buffer = [self buildDOTBufferFromSBMLTree:model_tree];
    [buffer appendString:dot_buffer];
    
    // return -
    return [NSString stringWithString:buffer];
}


#pragma mark - private helper methods
-(NSString *)buildDOTBufferFromSBMLTree:(NSXMLDocument *)sbmlTree
{
    
    // Create a buffer for the dot file and return -
    NSMutableString *buffer = [NSMutableString string];
    [buffer appendString:@"digraph G {\n"];
    [buffer appendString:@"\tsize=\"7.5,10\";\n"];
    [buffer appendString:@"\tratio=fill;\n"];
    [buffer appendString:@"\tnode[color=dimgray,fontcolor=white,style=filled,shape=house];\n"];
    
    // Get the species array -
    NSArray *species_array = [sbmlTree nodesForXPath:@"/Model/listOfSpecies/species/@symbol" error:nil];
    NSInteger counter = 0;
    for (NSXMLElement *speciesNode in species_array)
    {
        // Get the species value -
        NSString *reactantSymbol = [speciesNode stringValue];
        
        // Generate species line -
        [buffer appendFormat:@"\t%@ [style=filled,fontsize=12,shape=ellipse,color=\"0.03303964757709251 1.0 1.0\",fontcolor=white];\n",reactantSymbol];
        
        // Xpath to get all the reactions for this species -
        NSString *xpath = [NSString stringWithFormat:@"/Model/listOfOperations/operation/listOfReactants/species_reference[@symbol='%@']/../../listOfProducts/species_reference/@symbol",reactantSymbol];
        
        @autoreleasepool {
            
            // Get the products for this species -
            NSArray *productsArray = [sbmlTree nodesForXPath:xpath error:nil];
            
            // build reaction string -
            for (NSXMLElement *productNode in productsArray)
            {
                // Get the name -
                NSString *productSymbol = [productNode stringValue];
                
                // Build the line -
                [buffer appendFormat:@"\t%@->%@ [style=bold,color=blue];\n",reactantSymbol,productSymbol];
            }
        }
        
        counter = counter + 1;
    }
    
    
    // close -
    [buffer appendString:@"}\n"];
    
    // return
    return [NSString stringWithString:buffer];
}


@end
