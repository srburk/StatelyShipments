//
//  StatesLoader.m
//  StatelyShipments
//
//  Created by Sam Burkhard on 3/2/25.
//

#import <Foundation/Foundation.h>
#import "StatesLoader.h"
#import "../../Models/State/State.h"

@implementation StatesLoader

+ (NSDictionary *)loadStatesFromPlistAtPath:(NSString*)path {
    
    NSString* filePath = [[NSBundle mainBundle] pathForResource:path ofType:@"plist"];
    NSArray* plistArray = [NSArray arrayWithContentsOfFile:filePath];
    
    if (!plistArray) {
        NSLog(@"Error: Could not load %@.plist", path);
        return @{};
    }
    
    NSMutableDictionary *countryGraph = [[NSMutableDictionary alloc] init]; // stored as key = stateCode value = State
    
    // first pass
    for (NSDictionary *dict in plistArray) {
        // everything should match State
        State *newState = [[State alloc] init];
        newState.stateCode = dict[@"stateCode"];
        newState.stateName = dict[@"stateName"];
        newState.stateNeighbors = [NSPointerArray weakObjectsPointerArray];
        countryGraph[newState.stateCode] = newState;
    }
    
    // second pass to link neighbors
    for (NSDictionary *dict in plistArray) {
        State *state = countryGraph[dict[@"stateCode"]];
        for (NSString *neighborCode in dict[@"stateNeighbors"]) {
            State *neighbor = countryGraph[neighborCode];
            if (neighbor) {
                [state.stateNeighbors addPointer:(__bridge void * _Nullable)(neighbor)];
            }
        }
    }
        
    return countryGraph;
}

@end
