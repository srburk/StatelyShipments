//
//  MainViewController.m
//  StatelyShipments
//
//  Created by Sam Burkhard on 3/4/25.
//

#import <Foundation/Foundation.h>

#import "MainViewController.h"
#import "ShippingEntryViewController.h"

#import "../Utility/StatesLoader.h"

@interface MainViewController () <MKMapViewDelegate>

@property (nonatomic, strong) MKMapView* mapView;
//@property (nonatomic, strong) UINavigationController* drawerNavigationController;
@property (nonatomic, strong) UIImage* statePinImage;

@end

@implementation MainViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:10 weight:UIImageSymbolWeightRegular];
        UIImage *annotationImage = [UIImage systemImageNamed:@"circle.circle.fill" withConfiguration:config];
        self.statePinImage = annotationImage;
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.mapView = [[MKMapView alloc] init];
    self.mapView.translatesAutoresizingMaskIntoConstraints = NO;
    self.mapView.mapType = MKMapTypeMutedStandard;
    self.mapView.delegate = self;
        
    [[StatesLoader shared] loadStatesFromPlistAtPath:@"States"]; // TODO: Remove this and hone init
    
//    for (State* state in [[StatesLoader shared] allStatesAlphabetical]) {
//        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
//        annotation.coordinate = CLLocationCoordinate2DMake([state.latitude doubleValue], [state.longitude doubleValue]);
//        annotation.title = state.stateName;
//        
//        [self.mapView addAnnotation:annotation];
//    }
    
//    self.mapView.map
    [self.view addSubview:self.mapView];
    [NSLayoutConstraint activateConstraints:@[
        [self.mapView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.mapView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.mapView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.mapView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];
    
    // start navigation controller
    [self.coordinator showShippingCalculator];
    
    // Debug button to trigger overlay drawing
    UIButton *debugButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [debugButton setTitle:@"Debug Overlay" forState:UIControlStateNormal];
    debugButton.translatesAutoresizingMaskIntoConstraints = NO;
    [debugButton addTarget:self action:@selector(addMapOverlaysForRoute:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:debugButton];

    [NSLayoutConstraint activateConstraints:@[
        [debugButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20],
        [debugButton.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:80],
        [debugButton.widthAnchor constraintEqualToConstant:120],
        [debugButton.heightAnchor constraintEqualToConstant:44]
    ]];
}

- (void)viewDidAppear:(BOOL)animated {
    // start drawer presentation
    [self presentViewController:self.coordinator.navigationController animated:NO completion:nil];
}

// MARK: These methods should be in a coordinator
- (void)clearMapOverlays {
    
    [self.mapView removeOverlays:self.mapView.overlays];
    
}

- (void)addMapOverlaysForRoute:(NSArray *)route {
    
#ifdef DEBUG
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"stateCode == %@ || stateCode == %@ || stateCode == %@ || stateCode == %@ || stateCode == %@", @"CO", @"KS", @"NE", @"SD", @"WY"];
    NSArray *filteredArray = [[[StatesLoader shared] allStatesAlphabetical] filteredArrayUsingPredicate:predicate];
    route = filteredArray;
#endif
    
    // MARK: Validate route
    NSLog(@"Route: %@", route);
    int count = (int)[route count];
                      
    CLLocationCoordinate2D *coords = malloc(sizeof(CLLocationCoordinate2D) * count);
    for (NSUInteger i = 0; i < count; i++) {
        State *state = route[i];  // filteredArray should contain NSValue objects.
        coords[i] = CLLocationCoordinate2DMake([state.latitude doubleValue], [state.longitude doubleValue]);
    }
    
    MKPolyline *polyline = [MKPolyline polylineWithCoordinates:coords count:count];
//    [UIView animateWithDuration:10 animations:^{
    [self.mapView addOverlay:polyline level:MKOverlayLevelAboveLabels];
//    }];
    
    free(coords);
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithPolyline:(MKGeodesicPolyline*)overlay];
        renderer.lineWidth = 2;
        renderer.strokeColor = [UIColor systemBlueColor];
        renderer.fillColor = [UIColor systemBlueColor];
        renderer.alpha = 0.5;
        return renderer;
    } else {
        return [[MKOverlayRenderer alloc] initWithOverlay:overlay];
    }
}

#pragma mark MKMapViewDelegate Actions

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    static NSString * const identifier = @"StateAnnotation";
    MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    
    if (!annotationView) {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
        
        annotationView.image = self.statePinImage;
    } else {
        annotationView.annotation = annotation;
    }
    
    return annotationView;
}

@end
