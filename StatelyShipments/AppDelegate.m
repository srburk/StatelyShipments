//
//  AppDelegate.m
//  StatelyShipments
//
//  Created by Sam Burkhard on 3/2/25.
//

#import "AppDelegate.h"
#import "Services/FuelCostService/FuelCostService.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // testing state loader
    
//    NSDictionary* countryGraph = [StatesLoader loadStatesFromPlistAtPath:@"States"];
    
    // testing fetching a bunch of fuel costs    
//    State *ohio = countryGraph[@"OH"];
//    
//    for (State *neighbor in ohio.stateNeighbors) {
//        [fuelCostService fuelCostBetweenNeighborStates:ohio andState:neighbor completion:^(float result) {
//            NSLog(@"%@-%@ | Cost: %f", ohio.stateCode, neighbor.stateCode, result);
//        }];
//    }
//    
//    // test wait for 3 seconds
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        for (State *neighbor in ohio.stateNeighbors) {
//            [fuelCostService fuelCostBetweenNeighborStates:ohio andState:neighbor completion:^(float result) {
//                NSLog(@"%@-%@ | Cost: %f", ohio.stateCode, neighbor.stateCode, result);
//            }];
//        }
//    });
//    
//    // test wait for 3 seconds
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            
//        for (State *neighbor in ohio.stateNeighbors) {
//            [fuelCostService fuelCostBetweenNeighborStates:ohio andState:neighbor completion:^(float result) {
//                NSLog(@"%@-%@ | Cost: %f", ohio.stateCode, neighbor.stateCode, result);
//            }];
//        }
//    });
        
    return YES;
}

#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
