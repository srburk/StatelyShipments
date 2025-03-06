//
//  StatesLoader.h
//  StatelyShipments
//
//  Created by Sam Burkhard on 3/2/25.
//

#import <Foundation/Foundation.h>
#import "../Models/State.h"

@interface StatesLoader : NSObject

@property (nonatomic, strong, readonly) NSDictionary<NSArray*, State*>* allStatesGraph;
@property (nonatomic, strong, readonly) NSArray<State*>* allStatesAlphabetical;

+ (id)shared;

- (void)loadStatesFromPlistAtPath:(NSString*)path;

@end
