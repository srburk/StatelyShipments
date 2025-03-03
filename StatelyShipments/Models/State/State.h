//
//  State.h
//  StatelyShipments
//
//  Created by Sam Burkhard on 3/2/25.
//

#import <Foundation/Foundation.h>

@interface State: NSObject

@property NSString* stateCode;
@property NSString* stateName;
@property NSPointerArray* stateNeighbors; // holds array of weak references to States

- (NSString *)description;

@end
