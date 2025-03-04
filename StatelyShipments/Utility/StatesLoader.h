//
//  StatesLoader.h
//  StatelyShipments
//
//  Created by Sam Burkhard on 3/2/25.
//

#import <Foundation/Foundation.h>

@interface StatesLoader : NSObject

+ (NSDictionary *)loadStatesFromPlistAtPath:(NSString*)path;

@end
