//
//  StatesLoader.h
//  StatelyShipments
//
//  Created by Sam Burkhard on 3/2/25.
//

#import <Foundation/Foundation.h>
#import "../Models/State.h"

@interface StatesLoader : NSObject

@property (nonatomic, strong, readonly) NSArray<State*>* allStates;

+ (id)shared;

- (id)init;
- (NSDictionary *)loadStatesFromPlistAtPath:(NSString*)path;

@end
