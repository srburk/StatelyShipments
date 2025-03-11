//
//  ShippingCostServiceTests.m
//  StatelyShipmentsTests
//
//  Created by Sam Burkhard on 3/11/25.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import "ShippingCostService.h"
#import "StatesLoader.h"

// test fuel cost service
@interface TestFuelCostService : FuelCostService

@property (nonatomic, strong) NSDictionary<NSString *, NSNumber *> *fuelCosts;
@property (nonatomic, strong) NSDictionary<NSString *, NSNumber *> *roadUsability;

- (instancetype)initWithFuelCosts:(NSDictionary<NSString *, NSNumber *> *)fuelCosts roadUsability:(NSDictionary<NSString *, NSNumber *> *)roadUsability;
@end

@implementation TestFuelCostService

- (instancetype)initWithFuelCosts:(NSDictionary<NSString *, NSNumber *> *)fuelCosts
                    roadUsability:(NSDictionary<NSString *, NSNumber *> *)roadUsability {
    if (self = [super init]) {
        self.fuelCosts = fuelCosts;
        self.roadUsability = roadUsability;
    }
    return self;
}

- (void)fuelCostBetweenNeighborStates:(State *)stateA andState:(State *)stateB completion:(void (^)(float))completion {
    NSString *key = [self keyForState:stateA andState:stateB];
    NSNumber *cost = self.fuelCosts[key];
    if (completion) {
        completion([cost floatValue]);
    }
}

- (BOOL)isRoadUsableBetweenNeighborStates:(State *)stateA andState:(State *)stateB {
    return YES;
}

- (NSString *)keyForState:(State *)stateA andState:(State *)stateB {
    NSArray *states = @[[stateA stateCode], [stateB stateCode]];
    return [NSString stringWithFormat:@"%@-%@", states[0], states[1]];
}

@end

@interface ShippingCostServiceTests : XCTestCase <ShippingCostServiceDelegate>

@property NSMutableArray<NSString*>* route; // just state codes here
@property (assign) float totalCost;

@property XCTestExpectation* preWeightedRoutesExpectation;

@property (nonatomic, strong) ShippingCostService* shippingCostService;
@property (nonatomic, strong) TestFuelCostService* testFuelCostService;
@property (nonatomic, strong) StatesLoader* statesLoader;

@end

@implementation ShippingCostServiceTests

- (void)setUp {
    NSString *jsonPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"graph_weights" ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonPath];
    NSError *error = nil;
    NSDictionary *testFuelCosts = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    XCTAssertNil(error, @"Error parsing expected results JSON: %@", error);
    
    self.statesLoader = [[StatesLoader alloc] init];
    [self.statesLoader loadStatesFromPlistAtPath:@"States"];
    
    self.testFuelCostService = [[TestFuelCostService alloc] initWithFuelCosts:testFuelCosts roadUsability:@{}];
    self.shippingCostService = [[ShippingCostService alloc] init];
    self.shippingCostService.fuelCostService = self.testFuelCostService;
    self.shippingCostService.delegate = self;
    
    self.route = [NSMutableArray array];
}

- (void)testPreWeightedRoutes {
    
    // MARK: Load Expected Results
    NSString *jsonPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"expected_results" ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:jsonPath];
    NSError *error = nil;
    NSDictionary *expectedTestResults = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    XCTAssertNil(error, @"Error parsing expected results JSON: %@", error);
    
    // test conducted at border fee = $50
    self.shippingCostService.stateBorderFee = 50;
    
    for (NSDictionary* expectedResult in expectedTestResults) {
        
        self.route = [NSMutableArray array];
        
        self.preWeightedRoutesExpectation = [[XCTestExpectation alloc] init];
        
        State* source = [[self.statesLoader allStatesGraph] valueForKey:expectedResult[@"start"]];
        State* destination = [[self.statesLoader allStatesGraph] valueForKey:expectedResult[@"goal"]];
        
        [self.shippingCostService cheapestRouteBetweenStates:source andState:destination];
        
        [self waitForExpectations:@[self.preWeightedRoutesExpectation] timeout:20];
                
        NSLog(@"Starting pre-calculated test #%@", expectedResult[@"test_number"]);
                
        for (int i = 0; i < [self.route count]; i++) {
            XCTAssertTrue([self.route[i] isEqualToString:expectedResult[@"route"][i]], @"Route does not match expected value");
            NSNumber *expectedCost = expectedResult[@"cost"];
            XCTAssertEqualWithAccuracy(self.totalCost, [expectedCost floatValue], 0.0001, @"Total cost does not match expected value");
        }
    }
}

// MARK: Delegate Methods

- (void)shippingCostServiceDidFailWithMessage:(NSString *)message { 
    [self.preWeightedRoutesExpectation fulfill];
    self.preWeightedRoutesExpectation = nil;
}

- (void)shippingCostServiceDidFindRoute:(NSArray *)route withCosts:(NSArray *)fuelCosts withTotalCost:(float)cost {
    for (State* state in route) {
        [self.route addObject:state.stateCode];
    }
    
    self.totalCost = cost;
    
    [self.preWeightedRoutesExpectation fulfill];
    self.preWeightedRoutesExpectation = nil;
}

@end
