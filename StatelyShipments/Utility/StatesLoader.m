//
//  StatesLoader.m
//  StatelyShipments
//
//  Created by Sam Burkhard on 3/2/25.
//

#import <Foundation/Foundation.h>
#import "StatesLoader.h"
#import "../Models/State.h"

@interface StatesLoader ()

@property (nonatomic, strong) NSArray<State*>* allStates;

@end

@implementation StatesLoader

+ (id)shared {
    static StatesLoader *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[self alloc] init];
    });
    return shared;
}

- (id)init {
    if (self = [super init]) {
        self.allStates = [NSArray array];
    }
    return self;
}

- (NSDictionary *)loadStatesFromPlistAtPath:(NSString*)path {
    
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
        newState.longitude = @([dict[@"longitude"] floatValue]);
        newState.latitude = @([dict[@"latitude"] floatValue]);

        newState.stateNeighbors = [NSMutableArray array];
        
        countryGraph[newState.stateCode] = newState;
    }
    
    // second pass to link neighbors
    for (NSDictionary *dict in plistArray) {
        State *state = countryGraph[dict[@"stateCode"]];
        for (NSString *neighborCode in dict[@"stateNeighbors"]) {
            State *neighbor = countryGraph[neighborCode];
            if (neighbor) {
                [state.stateNeighbors addObject:neighbor];
            }
        }
    }
    
    NSArray* statesAlphabetical = [countryGraph.allValues sortedArrayUsingComparator:^NSComparisonResult(State *state1, State *state2) {
        return [state1.stateCode localizedCaseInsensitiveCompare:state2.stateCode];
    }];
    self.allStates = statesAlphabetical;
    
    return countryGraph;
}

@end
