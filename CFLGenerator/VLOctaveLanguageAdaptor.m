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
-(NSString *)buildReactionStringRepresentationForOperationWithName:(NSString *)operatioName
                                                      fromSBMLTree:(NSXMLDocument *)sbmlTree;

@end

@implementation VLOctaveLanguageAdaptor


#pragma mark - method overrides
-(NSString *)generateSimulationInputBufferWithOptions:(NSDictionary *)options
{
    // Buffer to build the array -
    NSMutableString *buffer = [NSMutableString string];
    
    // get the options from the dictionary -
    __unused NSXMLDocument *model_tree = [options objectForKey:kXMLModelTree];

    [buffer appendString:@"function new_input_vector = SimulationInput(state_vector,time_index,DF)\n"];
    [buffer appendString:@"% ------------------------------------------------------------------------------------- %\n"];
    [buffer appendString:@"% Copyright (c) 2013 Varnerlab,\n"];
    [buffer appendString:@"% School of Chemical and Biomolecular Engineering,\n"];
    [buffer appendString:@"% Cornell University, Ithaca NY 14853 USA.\n"];
    [buffer appendString:@"%\n"];
    [buffer appendString:@"% Permission is hereby granted, free of charge, to any person obtaining a copy\n"];
    [buffer appendString:@"% of this software and associated documentation files (the \"Software\"), to deal\n"];
    [buffer appendString:@"% in the Software without restriction, including without limitation the rights\n"];
    [buffer appendString:@"% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell\n"];
    [buffer appendString:@"% copies of the Software, and to permit persons to whom the Software is\n"];
    [buffer appendString:@"% furnished to do so, subject to the following conditions:\n"];
    [buffer appendString:@"% The above copyright notice and this permission notice shall be included in\n"];
    [buffer appendString:@"% all copies or substantial portions of the Software.\n"];
    [buffer appendString:@"%\n"];
    [buffer appendString:@"% THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR\n"];
    [buffer appendString:@"% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,\n"];
    [buffer appendString:@"% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE\n"];
    [buffer appendString:@"% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER\n"];
    [buffer appendString:@"% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,\n"];
    [buffer appendString:@"% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN\n"];
    [buffer appendString:@"% THE SOFTWARE.\n"];
    [buffer appendString:@"%\n"];
    [buffer appendString:@"% SimulationInput.m \n"];
    [buffer appendString:@"% SimulationInput takes the current state vector and time index and computes a \n"];
    [buffer appendString:@"% perturbation to the state vector. The default is the identity transformation.\n"];
    [buffer appendString:@"% ------------------------------------------------------------------------------------- %\n"];
    [buffer appendString:@"\n"];
    [buffer appendString:@"% Identity is the default perturbation (update for custom inputs) - \n"];
    [buffer appendString:@"new_input_vector = state_vector;\n"];
    [buffer appendString:@"\n"];
    [buffer appendString:@"return;\n"];

    
    // return -
    return [NSString stringWithString:buffer];
}

-(NSString *)generateEvaluateSignalEquationsBufferWithOptions:(NSDictionary *)options
{
    // Buffer to build the array -
    NSMutableString *buffer = [NSMutableString string];
    
    // get the options from the dictionary -
    __unused NSXMLDocument *model_tree = [options objectForKey:kXMLModelTree];

    [buffer appendString:@"function output_vector = EvaluateSignalSystem(state_vector,MAP_MATRIX,DF)\n"];
    [buffer appendString:@"% ------------------------------------------------------------------------------------- %\n"];
    [buffer appendString:@"% Copyright (c) 2013 Varnerlab,\n"];
    [buffer appendString:@"% School of Chemical and Biomolecular Engineering,\n"];
    [buffer appendString:@"% Cornell University, Ithaca NY 14853 USA.\n"];
    [buffer appendString:@"%\n"];
    [buffer appendString:@"% Permission is hereby granted, free of charge, to any person obtaining a copy\n"];
    [buffer appendString:@"% of this software and associated documentation files (the \"Software\"), to deal\n"];
    [buffer appendString:@"% in the Software without restriction, including without limitation the rights\n"];
    [buffer appendString:@"% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell\n"];
    [buffer appendString:@"% copies of the Software, and to permit persons to whom the Software is\n"];
    [buffer appendString:@"% furnished to do so, subject to the following conditions:\n"];
    [buffer appendString:@"% The above copyright notice and this permission notice shall be included in\n"];
    [buffer appendString:@"% all copies or substantial portions of the Software.\n"];
    [buffer appendString:@"%\n"];
    [buffer appendString:@"% THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR\n"];
    [buffer appendString:@"% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,\n"];
    [buffer appendString:@"% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE\n"];
    [buffer appendString:@"% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER\n"];
    [buffer appendString:@"% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,\n"];
    [buffer appendString:@"% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN\n"];
    [buffer appendString:@"% THE SOFTWARE.\n"];
    [buffer appendString:@"%\n"];
    [buffer appendString:@"% EvaluateSignalSystem.m \n"];
    [buffer appendString:@"% EvaluateSignalSystem takes the state_vector, mapping matrix and data struct and\n"];
    [buffer appendString:@"% evaluates the kinetics. It then updates the state_vector to the new state\n"];
    [buffer appendString:@"% which gets retruned.\n"];
    [buffer appendString:@"% ------------------------------------------------------------------------------------- %\n"];
    [buffer appendString:@"\n"];
    [buffer appendString:@"% Evaluate the kinetics - \n"];
    [buffer appendString:@"rV = Kinetics(state_vector,DF);\n"];
    [buffer appendString:@"[NROWS,NCOLS] = size(MAP_MATRIX);\n"];
    [buffer appendString:@"for rate_index = 1:NROWS\n"];
    [buffer appendString:@"\tMAP_MATRIX_ROW = MAP_MATRIX(rate_index,:);\n"];
    [buffer appendString:@"\tINDEX_NON_ZERO = find(MAP_MATRIX_ROW~=0);\n"];
    [buffer appendString:@"\tif (~isempty(INDEX_NON_ZERO))\n"];
    [buffer appendString:@"\t\tINDEX_VEC = find(MAP_MATRIX_ROW == 1);\n"];
    [buffer appendString:@"\t\tif (length(INDEX_VEC)==1)\n"];
    [buffer appendString:@"\t\t\trate_vector(rate_index,1) = 0;\n"];
    [buffer appendString:@"\t\telse\n"];
    [buffer appendString:@"\t\t\trate_vector(rate_index,1) = prod(rV(INDEX_VEC,1));\n"];
    [buffer appendString:@"\t\tend;\n"];
    [buffer appendString:@"\telse\n"];
    [buffer appendString:@"\t\t\trate_vector(rate_index,1) = 0;\n"];
    [buffer appendString:@"\tend;\n"];
    [buffer appendString:@"end;\n"];
    [buffer appendString:@"\n"];
    [buffer appendString:@"% Compute the output vector - \n"];
    [buffer appendString:@"output_vector = MAP_MATRIX*rV - rate_vector;\n"];
    [buffer appendString:@"\n"];
    [buffer appendString:@"% ok, so we need to correct for rows in mapping matrix -\n"];
    [buffer appendString:@"NUMBER_OF_EXTERNAL_STATES = DF.NUMBER_OF_EXTERNAL_STATES;\n"];
    [buffer appendString:@"for rate_index = 1:NROWS\n"];
    [buffer appendString:@"\tMAP_MATRIX_ROW = MAP_MATRIX(rate_index,:);\n"];
	[buffer appendString:@"\tINDEX_NON_ZERO = find(MAP_MATRIX_ROW~=0);\n"];
	[buffer appendString:@"\tif (isempty(INDEX_NON_ZERO))\n"];
    [buffer appendString:@"\t\toutput_vector(rate_index,1) = state_vector(rate_index + NUMBER_OF_EXTERNAL_STATES,1);\n"];
	[buffer appendString:@"\tend;\n"];
    [buffer appendString:@"end;\n"];
    [buffer appendString:@"\n"];
    [buffer appendString:@"% Impose a change constraint?\n"];
    [buffer appendString:@"DELTA = output_vector - state_vector((NUMBER_OF_EXTERNAL_STATES+1):end,1);\n"];
    [buffer appendString:@"EPSILON_ARRAY = DF.MAXIMUM_OPERATION_CHANGE_ARRAY;\n"];
    [buffer appendString:@"for rate_index = 1:NROWS\n"];
    [buffer appendString:@"\tEPSILON = EPSILON_ARRAY(rate_index,1);\n"];
    [buffer appendString:@"\tif (DELTA(rate_index,1)<-1*EPSILON)\n"];
    [buffer appendString:@"\t\toutput_vector(rate_index,1) = state_vector(rate_index + NUMBER_OF_EXTERNAL_STATES,1) - EPSILON;\n"];
	[buffer appendString:@"\telseif (DELTA(rate_index,1)>1*EPSILON)\n"];
    [buffer appendString:@"\t\toutput_vector(rate_index,1) = state_vector(rate_index + NUMBER_OF_EXTERNAL_STATES,1) + EPSILON;\n"];
	[buffer appendString:@"\tend\n"];
    [buffer appendString:@"end;\n"];
    [buffer appendString:@"return;\n"];
    
    // return -
    return [NSString stringWithString:buffer];
}

-(NSString *)generateSignalDriverBufferWithOptions:(NSDictionary *)options
{
    // Buffer to build the array -
    NSMutableString *buffer = [NSMutableString string];
    
    // get the options from the dictionary -
    NSXMLDocument *model_tree = [options objectForKey:kXMLModelTree];
    
    // ok, so let's calculate system arrays -
    [buffer appendString:@"% ------------------------------------------------------------------------------------- %\n"];
    [buffer appendString:@"% Copyright (c) 2013 Varnerlab,\n"];
    [buffer appendString:@"% School of Chemical and Biomolecular Engineering,\n"];
    [buffer appendString:@"% Cornell University, Ithaca NY 14853 USA.\n"];
    [buffer appendString:@"%\n"];
    [buffer appendString:@"% Permission is hereby granted, free of charge, to any person obtaining a copy\n"];
    [buffer appendString:@"% of this software and associated documentation files (the \"Software\"), to deal\n"];
    [buffer appendString:@"% in the Software without restriction, including without limitation the rights\n"];
    [buffer appendString:@"% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell\n"];
    [buffer appendString:@"% copies of the Software, and to permit persons to whom the Software is\n"];
    [buffer appendString:@"% furnished to do so, subject to the following conditions:\n"];
    [buffer appendString:@"% The above copyright notice and this permission notice shall be included in\n"];
    [buffer appendString:@"% all copies or substantial portions of the Software.\n"];
    [buffer appendString:@"%\n"];
    [buffer appendString:@"% THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR\n"];
    [buffer appendString:@"% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,\n"];
    [buffer appendString:@"% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE\n"];
    [buffer appendString:@"% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER\n"];
    [buffer appendString:@"% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,\n"];
    [buffer appendString:@"% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN\n"];
    [buffer appendString:@"% THE SOFTWARE.\n"];
    [buffer appendString:@"%\n"];
    [buffer appendString:@"% Driver.m \n"];
    [buffer appendString:@"% Main simulation function for evaluating a cFL model generated using the\n"];
    [buffer appendString:@"% cFLGenerator system.\n"];
    [buffer appendString:@"% ------------------------------------------------------------------------------------- %\n"];
    [buffer appendString:@"\n"];
    [buffer appendString:@"% Setup the simulation time scale - \n"];
    [buffer appendString:@"TSTART = 0.0;\n"];
    [buffer appendString:@"TSTOP = 100;\n"];
    [buffer appendString:@"Ts = 1;\n"];
    [buffer appendString:@"TIME_VECTOR = TSTART:Ts:TSTOP;\n"];
    [buffer appendString:@"NUMBER_OF_STEPS = length(TIME_VECTOR);\n"];
    [buffer appendString:@"\n"];
    [buffer appendString:@"% Load the DataFile - \n"];
    [buffer appendString:@"DF = DataFile(0,0,0,[]);\n"];
    [buffer appendString:@"\n"];
    [buffer appendString:@"% Get the state vector - \n"];
    [buffer appendString:@"IC = DF.INITIAL_CONDITION_VECTOR;\n"];
    [buffer appendString:@"\n"]; 
    [buffer appendString:@"% Load the network and mapping matrix - \n"];
    [buffer appendString:@"STM = load('Network.dat');\n"];
    [buffer appendString:@"MAP = load('Map.dat');\n"];
    [buffer appendString:@"\n"]; 
    [buffer appendString:@" % state calculations - \n"];
    [buffer appendString:@"state_vector = IC;\n"];
    [buffer appendString:@"SIMULATION_ARRAY = [];\n"];
    [buffer appendString:@"for time_index = 1:NUMBER_OF_STEPS\n"];
    [buffer appendString:@"\n"];
    [buffer appendString:@"\t% calculate the simulation inputs - \n"];
    [buffer appendString:@"\tperturbed_state_vector = SimulationInput(state_vector,time_index,DF);\n"];
    [buffer appendString:@"\n"];
    [buffer appendString:@"\t% evaluate the signal system - \n"];
    [buffer appendString:@"\toutput_vector = EvaluateSignalSystem(perturbed_state_vector,MAP,DF);\n"];
    [buffer appendString:@"\n"];
    [buffer appendString:@"\t% Sort the state_vector - \n"];
    
    // grab the outside species -
    NSArray *outside_state_array = [model_tree nodesForXPath:@"//listOfSpecies/species[@compartment='outside']/@symbol" error:nil];
    NSInteger NUMBER_OF_OUTSIDE_SPECIES = [outside_state_array count];
    NSInteger species_counter = 1;
    for (NSXMLElement *outside_node in outside_state_array)
    {
        // build -
        [buffer appendFormat:@"\tstate_vector(%lu,1) = perturbed_state_vector(%lu,1);\n",species_counter,species_counter];
        
        // update state counter -
        species_counter = species_counter + 1;
    }
    
    // grab the model species -
    NSArray *model_state_array = [model_tree nodesForXPath:@"//listOfSpecies/species[@compartment='model']/@symbol" error:nil];
    species_counter = 1;
    for (NSXMLElement *model_node in model_state_array)
    {
        // build -
        [buffer appendFormat:@"\tstate_vector(%lu,1) = output_vector(%lu,1);\n",(species_counter + NUMBER_OF_OUTSIDE_SPECIES),species_counter];
        
        // update state counter -
        species_counter = species_counter + 1;
    }

    [buffer appendString:@"\tSIMULATION_ARRAY = [SIMULATION_ARRAY state_vector];\n"];
	[buffer appendString:@"end;\n"];
    
    // return -
    return [NSString stringWithString:buffer];
}

-(NSString *)generateCalculateSystemArraysBufferWithOptions:(NSDictionary *)options
{
    // Buffer to build the array -
    NSMutableString *buffer = [NSMutableString string];
    
    // get the options from the dictionary -
    __unused NSXMLDocument *model_tree = [options objectForKey:kXMLModelTree];
    
    // ok, so let's calculate system arrays -
    
    
    // return -
    return [NSString stringWithString:buffer];
}

-(NSString *)generateMappingMatrixBufferWithOptions:(NSDictionary *)options
{
    // Buffer to build the array -
    NSMutableString *buffer = [NSMutableString string];
    
    // get the options from the dictionary -
    NSXMLDocument *model_tree = [options objectForKey:kXMLModelTree];
    
    // get the rate array -
    NSArray *rates_array = [model_tree nodesForXPath:@".//operation" error:nil];
    
    // ok, so let's calculate system arrays -
    BOOL isProduct = NO;
    NSArray *states_array = [model_tree nodesForXPath:@"//listOfSpecies/species[@compartment='model']/@symbol" error:nil];
    for (NSXMLElement *state_node in states_array)
    {
        // Get the symbol -
        NSString *state_symbol = [state_node stringValue];
        
        // ok, so go through the rates, does this species appear as a reactant?
        for (NSXMLElement *rate_node in rates_array)
        {
            // reset the flags -
            isProduct = NO;
            
            // check to see if this is a product -
            NSArray *products = [rate_node nodesForXPath:@"./listOfProducts/species_reference/@symbol" error:nil];
            
            // ok, so do we have a match?
            for (NSXMLElement *product_node in products)
            {
                NSString *product_symbol = [product_node stringValue];
                
                // r these the same symbol?
                if ([product_symbol isEqualToString:state_symbol]==YES)
                {
                    isProduct = YES;
                    break;
                }
            }
            
            // ok - add the correct element to the buffer
            if (isProduct == YES)
            {
                [buffer appendString:@"1 "];
            }
            else if (isProduct == NO)
            {
                [buffer appendString:@"0 "];
            }
        }
        
        // new line -
        [buffer appendString:@"\n"];
    }

    // return -
    return [NSString stringWithString:buffer];
}

-(NSString *)generateSTMBufferWithOptions:(NSDictionary *)options
{
    // Buffer to build the array -
    NSMutableString *buffer = [NSMutableString string];
    
    // get the options from the dictionary -
    NSXMLDocument *model_tree = [options objectForKey:kXMLModelTree];
    BOOL isReactant = NO;
    BOOL isProduct = NO;
    
    // get the rate array -
    NSArray *rates_array = [model_tree nodesForXPath:@".//operation" error:nil];
       
    // ok, get the species array -
    NSArray *states_array = [model_tree nodesForXPath:@"//listOfSpecies/species/@symbol" error:nil];
    for (NSXMLElement *state_node in states_array)
    {
        // Get the symbol -
        NSString *state_symbol = [state_node stringValue];
        
        // ok, so go through the rates, does this species appear as a reactant?
        for (NSXMLElement *rate_node in rates_array)
        {
            // reset the flags -
            isReactant = NO;
            isProduct = NO;
            
            // check the reactants of this node -
            NSArray *reactants = [rate_node nodesForXPath:@"./listOfReactants/species_reference/@symbol" error:nil];
            
            // ok, so do we have a match?
            for (NSXMLElement *reactant_node in reactants)
            {
                NSString *reactant_symbol = [reactant_node stringValue];
                
                // r these the same symbol?
                if ([reactant_symbol isEqualToString:state_symbol]==YES)
                {
                    isReactant = YES;
                    break;
                }
            }
            
            // check to see if this is a product -
            NSArray *products = [rate_node nodesForXPath:@"./listOfProducts/species_reference/@symbol" error:nil];
            
            // ok, so do we have a match?
            for (NSXMLElement *product_node in products)
            {
                NSString *product_symbol = [product_node stringValue];
                
                // r these the same symbol?
                if ([product_symbol isEqualToString:state_symbol]==YES)
                {
                    isProduct = YES;
                    break;
                }
            }
            
            // ok - add the correct element to the buffer
            if (isReactant == YES)
            {
                [buffer appendString:@"-1 "];
            }
            else if (isProduct == YES)
            {
                [buffer appendString:@"1 "];
            }
            else if (isReactant == NO && isProduct == NO)
            {
                [buffer appendString:@"0 "];
            }
        }
        
        // new line -
        [buffer appendString:@"\n"];
    }
    
    // return -
    return [NSString stringWithString:buffer];
}


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
    NSString *epsilon_block = [self buildEpsilonArrayFromSBMLTree:model_tree];
    NSString *footer_block = [self buildFooterBlockFromBlueprintTree:transformation_tree andSBMLTree:model_tree];
    [buffer appendString:header_block];
    [buffer appendString:parameter_block];
    [buffer appendString:ic_block];
    [buffer appendString:epsilon_block];
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
    [buffer appendString:@"% ------------------------------------------------------------------------------------- %\n"];
    [buffer appendString:@"% Copyright (c) 2013 Varnerlab,\n"];
    [buffer appendString:@"% School of Chemical and Biomolecular Engineering,\n"];
    [buffer appendString:@"% Cornell University, Ithaca NY 14853 USA.\n"];
    [buffer appendString:@"%\n"];
    [buffer appendString:@"% Permission is hereby granted, free of charge, to any person obtaining a copy\n"];
    [buffer appendString:@"% of this software and associated documentation files (the \"Software\"), to deal\n"];
    [buffer appendString:@"% in the Software without restriction, including without limitation the rights\n"];
    [buffer appendString:@"% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell\n"];
    [buffer appendString:@"% copies of the Software, and to permit persons to whom the Software is\n"];
    [buffer appendString:@"% furnished to do so, subject to the following conditions:\n"];
    [buffer appendString:@"% The above copyright notice and this permission notice shall be included in\n"];
    [buffer appendString:@"% all copies or substantial portions of the Software.\n"];
    [buffer appendString:@"%\n"];
    [buffer appendString:@"% THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR\n"];
    [buffer appendString:@"% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,\n"];
    [buffer appendString:@"% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE\n"];
    [buffer appendString:@"% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER\n"];
    [buffer appendString:@"% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,\n"];
    [buffer appendString:@"% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN\n"];
    [buffer appendString:@"% THE SOFTWARE.\n"];
    [buffer appendString:@"%\n"];
    [buffer appendString:@"% Kinetics.m \n"];
    [buffer appendString:@"% Kinetics takes the state_vector and the data struct and calculates the transfer\n"];
    [buffer appendString:@"% function values for a given model.\n"];
    [buffer appendString:@"% ------------------------------------------------------------------------------------- %\n"];
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
                
                // ok, so I need to figure out the proptionality -
                NSString *prop_xpath = [NSString stringWithFormat:@".//operation[@name='%@']/listOfReactants/species_reference[@symbol='%@']/@proportionality",operation_name,reactant_symbol];
                NSString *prop_direction = [[[sbmlTree nodesForXPath:prop_xpath error:nil] lastObject] stringValue];
                if ([prop_direction isEqualToString:@"inverse"]==YES)
                {
                    [local_buffer appendFormat:@"(1 - %@)",reactant_symbol];
                }
                else
                {
                    [local_buffer appendFormat:@"%@",reactant_symbol];
                }
                
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
        else if ([operation_type isEqualToString:@"SINGLE_PRODUCT_INHIBITION"]==YES)
        {
            // what are the inouts?
            NSString *reactant_symbol = [[operation_reactants lastObject] stringValue];
            [buffer appendFormat:@"INPUT_%@ = 1 - %@;\n",operation_name,reactant_symbol];
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
    [buffer appendString:@"% ------------------------------------------------------------------------------------- %\n"];
    [buffer appendString:@"% Copyright (c) 2013 Varnerlab,\n"];
    [buffer appendString:@"% School of Chemical and Biomolecular Engineering,\n"];
    [buffer appendString:@"% Cornell University, Ithaca NY 14853 USA.\n"];
    [buffer appendString:@"%\n"];
    [buffer appendString:@"% Permission is hereby granted, free of charge, to any person obtaining a copy\n"];
    [buffer appendString:@"% of this software and associated documentation files (the \"Software\"), to deal\n"];
    [buffer appendString:@"% in the Software without restriction, including without limitation the rights\n"];
    [buffer appendString:@"% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell\n"];
    [buffer appendString:@"% copies of the Software, and to permit persons to whom the Software is\n"];
    [buffer appendString:@"% furnished to do so, subject to the following conditions:\n"];
    [buffer appendString:@"% The above copyright notice and this permission notice shall be included in\n"];
    [buffer appendString:@"% all copies or substantial portions of the Software.\n"];
    [buffer appendString:@"%\n"];
    [buffer appendString:@"% THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR\n"];
    [buffer appendString:@"% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,\n"];
    [buffer appendString:@"% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE\n"];
    [buffer appendString:@"% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER\n"];
    [buffer appendString:@"% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,\n"];
    [buffer appendString:@"% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN\n"];
    [buffer appendString:@"% THE SOFTWARE.\n"];
    [buffer appendString:@"%\n"];
    [buffer appendString:@"% DataFile.m \n"];
    [buffer appendString:@"% DataFile holds the parameters and initial conditions for the cFL model. This struct\n"];
    [buffer appendString:@"% is passed around to the various functions and *can* be modfied in memory.\n"];
    [buffer appendString:@"% ------------------------------------------------------------------------------------- %\n"];
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
    
    // how many internal versus external states?
    NSArray *outside_species = [sbmlTree nodesForXPath:@".//listOfSpecies/species[@compartment='outside']/@symbol" error:nil];
    [buffer appendFormat:@"NUMBER_OF_EXTERNAL_STATES = %ld;\n",[outside_species count]];
    
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
    [buffer appendString:@"DF.NUMBER_OF_EXTERNAL_STATES = NUMBER_OF_EXTERNAL_STATES;\n"];
    [buffer appendString:@"DF.MAXIMUM_OPERATION_CHANGE_ARRAY = MAX_CHANGE_ARRAY;\n"];
    [buffer appendString:@"DF.MEASUREMENT_SELECTION_VECTOR = 1:NUMBER_OF_STATES;\n"];
    // close -
    [buffer appendString:@"% ======================================================== %\n"];
    [buffer appendString:@"return;\n"];
    
    // return buffer
    return [NSString stringWithString:buffer];
}

-(NSString *)buildEpsilonArrayFromSBMLTree:(NSXMLDocument *)sbmlTree
{
    // Initialize the buffer -
    NSMutableString *buffer = [NSMutableString string];
    
    // Formulate rate constant buffer -
    // open -
    [buffer appendString:@"\n"];
    [buffer appendString:@"MAX_CHANGE_ARRAY = [\n"];
    
    // Get the operation names -
    NSArray *operationArray = [sbmlTree nodesForXPath:@".//listOfSpecies/species/@symbol" error:nil];
    NSInteger counter = 0;
    for (NSXMLElement *name_node in operationArray)
    {
        // Get the name -
        NSString *operation_name = [name_node stringValue];
        
        // ok, so get the parameters for this operation -
        NSString *parameter_xpath = [NSString stringWithFormat:@".//listOfSpecies/species[@symbol='%@']/@maximum_change",operation_name];
        NSArray *parameterArray = [sbmlTree nodesForXPath:parameter_xpath error:nil];
        
        __unused NSInteger NUMBER_OF_RATES = [parameterArray count];
        for (NSXMLElement *parameterNode in parameterArray)
        {
            // Get id of rate -
            NSString *epsilon_value = [parameterNode stringValue];
            
            // Ok, so I don't have the reaction name -
            [buffer appendFormat:@"\t%@\t;\t%% %ld %@\n",epsilon_value,counter+1,operation_name];
            
            // update the counter -
            counter = counter + 1;
        }
    }
    
    // close -
    [buffer appendString:@"];\n"];
    
    
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
    [buffer appendString:@"RATE_CONSTANT_VECTOR = [\n\n"];
    
    // Get the operation names -
    NSArray *operationArray = [sbmlTree nodesForXPath:@".//listOfOperations/operation/@name" error:nil];
    NSInteger counter = 0;
    NSInteger operation_counter = 0;
    for (NSXMLElement *name_node in operationArray)
    {
        // Get the name -
        NSString *operation_name = [name_node stringValue];
        
        // ok, so get the parameters for this operation -
        NSString *parameter_xpath = [NSString stringWithFormat:@".//operation[@name='%@']/rule/listOfParameters/parameter/@symbol",operation_name];
        NSArray *parameterArray = [sbmlTree nodesForXPath:parameter_xpath error:nil];
        
        // what is the operation name?
        [buffer appendFormat:@"\t%% Operation: %lu %@\n",(operation_counter + 1),operation_name];
        
        // ok, so write a schematic of the reaction for debugging -
        NSString *operation_reaction_string = [self buildReactionStringRepresentationForOperationWithName:operation_name fromSBMLTree:sbmlTree];
        [buffer appendFormat:@"\t%% %@",operation_reaction_string];
        
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
        
        // update operation counter -
        operation_counter = operation_counter + 1;
        
        // add a new line -
        [buffer appendString:@"\n"];
    }
    
    
    
        
    // close -
    [buffer appendString:@"];\n"];
    
    // return buffer
    return [NSString stringWithString:buffer];
}

-(NSString *)buildReactionStringRepresentationForOperationWithName:(NSString *)operatioName
                                                      fromSBMLTree:(NSXMLDocument *)sbmlTree
{
    // ok, so I need to get the reactants and products for this reaction (including whether or not they are direct or indirect)
    
    // get productions -
    NSString *products_string = [NSString stringWithFormat:@".//operation[@name='%@']/listOfProducts/species_reference/@symbol",operatioName];
    NSArray *products_array = [sbmlTree nodesForXPath:products_string error:nil];
    
    // get reactants -
    NSString *reactants_string = [NSString stringWithFormat:@".//operation[@name='%@']/listOfReactants/species_reference/@symbol",operatioName];
    NSArray *reactants_array = [sbmlTree nodesForXPath:reactants_string error:nil];

    // ok, so let's formulate the string -
    NSMutableString *buffer = [NSMutableString string];
    NSInteger counter = 0;
    NSInteger NUMBER_OF_REACTANTS = [reactants_array count];
    for (NSXMLElement *reactant_node in reactants_array)
    {
        // get the symbol -
        NSString *reactant_symbol = [reactant_node stringValue];
        
        // need to check the proportionality -
        NSString *xpath_proportionality = [NSString stringWithFormat:@".//operation[@name='%@']/listOfReactants/species_reference[@symbol='%@']/@proportionality",operatioName,reactant_symbol];
        NSString *direction = [[[sbmlTree nodesForXPath:xpath_proportionality error:nil] lastObject] stringValue];
        if ([direction isEqualToString:@"direct"] == YES)
        {
            [buffer appendString:reactant_symbol];
        }
        else if ([direction isEqualToString:@"inverse"] == YES)
        {
            NSString *inverse = [NSString stringWithFormat:@"(1 - %@)",reactant_symbol];
            [buffer appendString:inverse];
        }
        
        if (counter != (NUMBER_OF_REACTANTS - 1))
        {
            [buffer appendString:@"*"];
        }
        
        // update the counter -
        counter = counter + 1;
    }
    
    // arrow -
    [buffer appendString:@" ---------> "];
    
    // process the products -
    [buffer appendString:@"["];
    for (NSXMLElement *product_node in products_array)
    {
        // get the symbol -
        NSString *product_symbol = [product_node stringValue];

        // add to buffer -
        [buffer appendString:product_symbol];
    }
    
    // close -
    [buffer appendString:@"];\n"];
    
    // return buffer
    return [NSString stringWithString:buffer];
}

@end
