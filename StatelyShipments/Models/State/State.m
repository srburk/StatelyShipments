//
//  State.m
//  StatelyShipments
//
//  Created by Sam Burkhard on 3/2/25.
//

#import <Foundation/Foundation.h>
#import "State.h"

@implementation State

- (NSString *)description {
    NSMutableArray *neighborCodes = [NSMutableArray array];
    
    for (State *neighbor in self.stateNeighbors) {
        if (neighbor) {
            [neighborCodes addObject:neighbor.stateCode]; // Collect state codes
        }
    }

    NSString *neighborList = [neighborCodes componentsJoinedByString:@", "];
    
    return [[NSString alloc] initWithFormat:@"%@, %@, Neighbors [%@]", self.stateCode, self.stateName, neighborList];
}

@end
