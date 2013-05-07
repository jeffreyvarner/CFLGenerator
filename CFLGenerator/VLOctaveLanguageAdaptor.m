//
//  VLOctaveLanguageAdaptor.m
//  CFLGenerator
//
//  Created by Jeffrey Varner on 5/7/13.
//  Copyright (c) 2013 Varnerlab. All rights reserved.
//

#import "VLOctaveLanguageAdaptor.h"

@interface VLOctaveLanguageAdaptor ()

// Kinetics -
-(NSString *)buildKineticsBufferFromBlueprintTree:(NSXMLDocument *)blueprintTree
                                      andSBMLTree:(NSXMLDocument *)sbmlTree;

// DataFile -
-(NSString *)buildHeaderBlockFromBlueprintTree:(NSXMLDocument *)blueprintTree
                                   andSBMLTree:(NSXMLDocument *)sbmlTree;


-(NSString *)buildFooterBlockFromBlueprintTree:(NSXMLDocument *)blueprintTree
                                   andSBMLTree:(NSXMLDocument *)sbmlTree;

-(NSString *)buildRateConstantListFromSBMLTree:(NSXMLDocument *)sbmlTree;
-(NSString *)buildInitialConditionListFromSBMLTree:(NSXMLDocument *)sbmlTree;

@end

@implementation VLOctaveLanguageAdaptor


#pragma mark - method overrides
-(NSString *)generateDataFileBufferWithOptions:(NSDictionary *)options
{
    // get the options from the dictionary -
    NSXMLDocument *model_tree = [options objectForKey:kXMLModelTree];
    NSXMLDocument *transformation_tree = [options objectForKey:kXMLTransformationTree];
    
    // build the buffer -
    NSMutableString *buffer = [NSMutableString string];
    NSString *header_block = [self buildHeaderBlockFromBlueprintTree:transformation_tree andSBMLTree:model_tree];
    NSString *parameter_block = [self buildRateConstantListFromSBMLTree:model_tree];
    NSString *ic_block = [self buildInitialConditionListFromSBMLTree:model_tree];
    NSString *footer_block = [self buildFooterBlockFromBlueprintTree:transformation_tree andSBMLTree:model_tree];
    [buffer appendString:header_block];
    [buffer appendString:parameter_block];
    [buffer appendString:ic_block];
    [buffer appendString:footer_block];
    
    // return -
    return [NSString stringWithString:buffer];
}

-(NSString *)generateKineticsBufferWithOptions:(NSDictionary *)options
{
    // get the options from the dictionary -
    NSXMLDocument *model_tree = [options objectForKey:kXMLModelTree];
    NSXMLDocument *transformation_tree = [options objectForKey:kXMLTransformationTree];
    
    // build the buffer -
    NSMutableString *buffer = [NSMutableString string];
    NSString *kinetics_buffer = [self buildKineticsBufferFromBlueprintTree:transformation_tree andSBMLTree:model_tree];
    [buffer appendString:kinetics_buffer];
    
    // return -
    return [NSString stringWithString:buffer];
}

#pragma mark - private logic methods
-(NSString *)buildKineticsBufferFromBlueprintTree:(NSXMLDocument *)blueprintTree
                                      andSBMLTree:(NSXMLDocument *)sbmlTree
{
    // Initialize the buffer -
    NSMutableString *buffer = [NSMutableString string];
    
    // DataFile function -
    [buffer appendString:@"function rate_vector = Kinetics(state_vector,DF)\n"];
    [buffer appendString:@"% ---------------------------------------- % \n"];
    [buffer appendString:@"% Kinetics.m \n"];
    [buffer appendString:@"% -----------------------------------------% \n"];
    [buffer appendFormat:@"\n"];
    [buffer appendString:@"% State symbols - \n"];
    
    // Get the species vectors -
    NSArray *states_array = [sbmlTree nodesForXPath:@"//listOfSpecies/species/@symbol" error:nil];
    NSInteger species_counter = 1;
    for (NSXMLElement *node in states_array)
    {
        NSString *species_symbol = [node stringValue];
        [buffer appendFormat:@"%@ = state_vector(%lu,1);\n",species_symbol,species_counter];
        
        // update counter -
        species_counter = species_counter + 1;
    }
    
    // new line -
    [buffer appendString:@"\n"];
    
    // parameters -
    NSArray *parameter_array = [sbmlTree nodesForXPath:@".//parameter/@symbol" error:nil];
    [buffer appendString:@"% Parameter symbols - \n"];
    [buffer appendString:@"RATE_CONSTANT_VECTOR = DF.RATE_CONSTANT_VECTOR;\n"];
    NSInteger parameter_counter = 1;
    for (NSXMLElement *parameter_node in parameter_array)
    {
        NSString *parameter_symbol = [parameter_node stringValue];
        [buffer appendFormat:@"%@ = RATE_CONSTANT_VECTOR(%lu,1);\n",parameter_symbol,parameter_counter];
        parameter_counter = parameter_counter + 1;
    }
    
    // new line -
    [buffer appendString:@"\n"];
    
    // get the rates -
    NSArray *rates = [sbmlTree nodesForXPath:@".//operation/@name" error:nil];
    
    // initialize -
    [buffer appendString:@"% Initialize and populate the rate vector - \n"];
    [buffer appendString:@"NUMBER_OF_RATES = DF.NUMBER_OF_RATES;\n"];
    [buffer appendString:@"rate_vector = zeros(NUMBER_OF_RATES,1);\n"];
    
    // new line -
    [buffer appendString:@"\n"];
    NSInteger rate_counter = 1;
    for (NSXMLElement *rate_node in rates)
    {
        // Get the operation name -
        NSString *operation_name = [rate_node stringValue];
        
        // what type of operation is this?
        NSString *operation_type_xpath = [NSString stringWithFormat:@".//operation[@name='%@']/rule/@type",operation_name];
        NSString *operation_type = [[[sbmlTree nodesForXPath:operation_type_xpath error:nil] lastObject] stringValue];
        
        // reactants?
        NSString *operation_reactants_xpath = [NSString stringWithFormat:@".//operation[@name='%@']/listOfReactants/species_reference/@symbol",operation_name];
        NSArray *operation_reactants = [sbmlTree nodesForXPath:operation_reactants_xpath error:nil];
        
        // ok, so I we need to build the rate law -
        [buffer appendFormat:@"%%\tOperation: %@ type: %@\n",operation_name,operation_type];
        
        // need to lookup the value for each type of parameter -
        NSString *parameter_symbol_xpath_scale = [NSString stringWithFormat:@".//operation[@name='%@']/rule[@type='%@']/listOfParameters/parameter[@type = 'SCALE']/@symbol",operation_name,operation_type];
        NSString *parameter_symbol_xpath_sat = [NSString stringWithFormat:@".//operation[@name='%@']/rule[@type='%@']/listOfParameters/parameter[@type = 'SATURATION']/@symbol",operation_name,operation_type];
        NSString *parameter_symbol_xpath_hill = [NSString stringWithFormat:@".//operation[@name='%@']/rule[@type='%@']/listOfParameters/parameter[@type = 'HILL']/@symbol",operation_name,operation_type];
        NSString *parameter_symbol_scale = [[[sbmlTree nodesForXPath:parameter_symbol_xpath_scale error:nil] lastObject] stringValue];
        NSString *parameter_symbol_saturation = [[[sbmlTree nodesForXPath:parameter_symbol_xpath_sat error:nil] lastObject] stringValue];
        NSString *parameter_symbol_hill = [[[sbmlTree nodesForXPath:parameter_symbol_xpath_hill error:nil] lastObject] stringValue];
        
        // ok, so if we have activating -
        if ([operation_type isEqualToString:@"SINGLE_REACTANT_ACTIVATION"]==YES)
        {
            // what are the inouts?
            NSString *reactant_symbol = [[operation_reactants lastObject] stringValue];
            [buffer appendFormat:@"INPUT_%@ = %@;\n",operation_name,reactant_symbol];
        }
        else if ([operation_type isEqualToString:@"MULTIPLE_REACTANT_AND"]==YES)
        {
            // ok, so here we are *multiple* inputs -
            NSMutableString *local_buffer = [NSMutableString string];
            NSInteger COUNT = [operation_reactants count];
            NSInteger reactant_counter = 0;
            for (NSXMLElement *reactant_node in operation_reactants)
            {
                NSString *reactant_symbol = [reactant_node stringValue];
                [local_buffer appendFormat:@"%@",reactant_symbol];
                
                if (reactant_counter == COUNT - 1)
                {
                    [local_buffer appendString:@";\n"];
                }
                else
                {
                    reactant_counter = reactant_counter + 1;
                    [local_buffer appendString:@"*"];
                }
            }
            
             [buffer appendFormat:@"INPUT_%@ = %@",operation_name,local_buffer];
        }
        
        [buffer appendFormat:@"rate_vector(%lu,1) = %@*(%@^%@ + 1)*(INPUT_%@^%@)/(%@^%@ + INPUT_%@^%@);\n",rate_counter,
         parameter_symbol_scale,parameter_symbol_saturation,parameter_symbol_hill,operation_name,parameter_symbol_hill,parameter_symbol_saturation,
         parameter_symbol_hill,operation_name,parameter_symbol_hill];
     
        // new line -
        [buffer appendString:@"\n"];
        
        // update the counter -
        rate_counter = rate_counter + 1;
    }
    
    [buffer appendString:@"return;\n"];
    
    // return buffer
    return [NSString stringWithString:buffer];
}


-(NSString *)buildHeaderBlockFromBlueprintTree:(NSXMLDocument *)blueprintTree
                                   andSBMLTree:(NSXMLDocument *)sbmlTree
{
    // Initialize the buffer -
    NSMutableString *buffer = [NSMutableString string];
    
    // DataFile function -
    [buffer appendString:@"function DF = DataFile(TSTART,TSTOP,Ts,INDEX)\n"];
    [buffer appendString:@"% ---------------------------------------- % \n"];
    [buffer appendString:@"% DataFile.m \n"];
    [buffer appendString:@"% -----------------------------------------% \n"];
    [buffer appendFormat:@"\n"];
    [buffer appendString:@"% Dimension of the system - \n"];
    
    // Get the dimension of rates, and states -
    NSArray *rates = [sbmlTree nodesForXPath:@".//operation/@name" error:nil];
    NSArray *states_not_unique_array = [sbmlTree nodesForXPath:@".//species/@symbol" error:nil];
    NSMutableSet *state_vector = [NSMutableSet set];
    for (NSXMLElement *node in states_not_unique_array)
    {
        // Get the state -
        NSString *state_symbol = [node stringValue];
        
       // add -
        [state_vector addObject:state_symbol];
    }
    
    
    // put the dimension -
    [buffer appendFormat:@"NUMBER_OF_RATES = %ld;\n",[rates count]];
    [buffer appendFormat:@"NUMBER_OF_STATES = %ld;\n",[state_vector count]];
    
    // return buffer
    return [NSString stringWithString:buffer];
}

-(NSString *)buildFooterBlockFromBlueprintTree:(NSXMLDocument *)blueprintTree
                                   andSBMLTree:(NSXMLDocument *)sbmlTree
{
    // Initialize the buffer -
    NSMutableString *buffer = [NSMutableString string];
    
    // Footer block -
    // open -
    [buffer appendString:@"\n"];
    [buffer appendString:@"% =========== DO NOT EDIT BELOW THIS LINE ================ %\n"];
    [buffer appendString:@"DF.RATE_CONSTANT_VECTOR = RATE_CONSTANT_VECTOR;\n"];
    [buffer appendString:@"DF.INITIAL_CONDITION_VECTOR = INITIAL_CONDITION_VECTOR;\n"];
    [buffer appendString:@"DF.NUMBER_OF_RATES = NUMBER_OF_RATES;\n"];
    [buffer appendString:@"DF.NUMBER_OF_STATES = NUMBER_OF_STATES;\n"];
    [buffer appendString:@"DF.MEASUREMENT_SELECTION_VECTOR = 1:NUMBER_OF_STATES;\n"];
    // close -
    [buffer appendString:@"% ======================================================== %\n"];
    [buffer appendString:@"return;\n"];
    
    // return buffer
    return [NSString stringWithString:buffer];
}

-(NSString *)buildInitialConditionListFromSBMLTree:(NSXMLDocument *)sbmlTree
{
    // Initialize the buffer -
    NSMutableString *buffer = [NSMutableString string];
    
    // Formulate rate constant buffer -
    // open -
    [buffer appendString:@"\n"];
    [buffer appendString:@"INITIAL_CONDITION_VECTOR = [\n"];
    
    NSArray *compartmentArray = [sbmlTree nodesForXPath:@".//compartment/@name" error:nil];
    NSInteger counter = 0;
    for (NSXMLElement *compartmentNode in compartmentArray)
    {
        // Get the compartment -
        NSString *compartmentID = [compartmentNode stringValue];
        
        // alias the species -
        @autoreleasepool {
            
            // ok, so I need to get the species -
            NSString *xpath = [NSString stringWithFormat:@".//listOfSpecies/species[@compartment='%@']/@symbol",compartmentID];
            NSArray *states = [sbmlTree nodesForXPath:xpath error:nil];
            
            for (NSXMLElement *stateNode in states)
            {
                // Get the id -
                NSString *stateID = [stateNode stringValue];
                
                // Get the IC value for this species -
                NSString *xpath = [NSString stringWithFormat:@".//listOfSpecies/species[@symbol='%@']/@initial_amount",stateID];
                NSString *value = [[[sbmlTree nodesForXPath:xpath error:nil] lastObject] stringValue];
                
                // build the line -
                [buffer appendFormat:@"\t%@\t;\t%% %ld %@ %@\n",value,counter+1,stateID,compartmentID];
                
                // update counter -
                counter = counter + 1;
            }
        }
    }
    
    // close -
    [buffer appendString:@"];\n"];
    
    
    // return buffer
    return [NSString stringWithString:buffer];
}

-(NSString *)buildRateConstantListFromSBMLTree:(NSXMLDocument *)sbmlTree
{
    // Initialize the buffer -
    NSMutableString *buffer = [NSMutableString string];
    
    // Formulate rate constant buffer -
    // open -
    [buffer appendString:@"\n"];
    [buffer appendString:@"RATE_CONSTANT_VECTOR = [\n"];
    
    // rates -
    NSArray *parameterArray = [sbmlTree nodesForXPath:@".//parameter/@symbol" error:nil];
    NSInteger counter = 0;
    __unused NSInteger NUMBER_OF_RATES = [parameterArray count];
    for (NSXMLElement *parameterNode in parameterArray)
    {
        // Get id of rate -
        NSString *parameterID = [parameterNode stringValue];
        
        // Ok, so I don't have the reaction name -
        NSString *xpath = [NSString stringWithFormat:@".//parameter[@symbol='%@']/@value",parameterID];
        NSString *value = [[[sbmlTree nodesForXPath:xpath error:nil] lastObject] stringValue];
        [buffer appendFormat:@"\t%@\t;\t%% %ld %@\n",value,counter+1,parameterID];
        
        // update the counter -
        counter = counter + 1;
    }
    
    // close -
    [buffer appendString:@"];\n"];
    
    // return buffer
    return [NSString stringWithString:buffer];
}


@end
