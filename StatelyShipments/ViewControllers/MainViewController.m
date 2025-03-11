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

static const CGFloat mapViewPadding = 75;

@interface MainViewController () <MKMapViewDelegate>

@property (nonatomic, strong) MKMapView* mapView;
@property (nonatomic, strong) UIImage* statePinImage;

@end

@implementation MainViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.mapView = [[MKMapView alloc] init];
    self.mapView.translatesAutoresizingMaskIntoConstraints = NO;
    self.mapView.mapType = MKMapTypeMutedStandard;
    self.mapView.delegate = self;
        
    [[StatesLoader shared] loadStatesFromPlistAtPath:@"States"]; // TODO: Remove this and hone init

    [self.view addSubview:self.mapView];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.mapView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.mapView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.mapView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.mapView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];
    
    // clear map at beginning
    [self clearMap];
    
    // start navigation controller
    [self.coordinator showShippingCalculator];
}

- (void)viewDidAppear:(BOOL)animated {
    // start drawer presentation
    [self presentViewController:self.coordinator.navigationController animated:NO completion:nil];
}


- (MKMapRect)makeBoundingMapRectFromPoint:(MKMapPoint)point1 toPoint:(MKMapPoint)point2 {
    double minX = MIN(point1.x, point2.x);
    double minY = MIN(point1.y, point2.y);
    double maxX = MAX(point1.x, point2.x);
    double maxY = MAX(point1.y, point2.y);
    MKMapRect boundingRect = MKMapRectMake(minX, minY, maxX - minX, maxY - minY);
    return boundingRect;
}

- (void)focusMapOnPoint:(MKMapPoint)point1 andPoint:(MKMapPoint)point2 {
    
    MKMapRect boundingRect = [self makeBoundingMapRectFromPoint:point1 toPoint:point2];

    UIEdgeInsets edgePadding = UIEdgeInsetsMake(mapViewPadding, mapViewPadding, (self.mapView.bounds.size.height / 2), mapViewPadding);
    [self.mapView setVisibleMapRect:boundingRect edgePadding:edgePadding animated:YES];
}

// reset map
- (void)clearMap {
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView removeOverlays:self.mapView.overlays];
    
    // center of the US
    CLLocationCoordinate2D topLeft = CLLocationCoordinate2DMake(49.38, -124.77);
    CLLocationCoordinate2D bottomRight = CLLocationCoordinate2DMake(24.52, -66.95);

    MKMapPoint point1 = MKMapPointForCoordinate(topLeft);
    MKMapPoint point2 = MKMapPointForCoordinate(bottomRight);
    MKMapRect boundingRect = [self makeBoundingMapRectFromPoint:point1 toPoint:point2];
    UIEdgeInsets edgePadding = UIEdgeInsetsMake(0, 20, mapViewPadding, 20);
    [self.mapView setVisibleMapRect:boundingRect edgePadding:edgePadding animated:YES];
    
}

// draw route and destinations
- (void)drawRoute:(NSArray *)route {
    
    // TODO: Make this a UIConstant
    CGRect rect = CGRectMake(0, 0, 20, 20);
    CGRect insetRect = CGRectInset(rect, 5 / 2.0, 5 / 2.0);
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc] initWithSize:rect.size];
    self.statePinImage = [renderer imageWithActions:^(UIGraphicsImageRendererContext * _Nonnull context) {
        // Draw the circle
        UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:insetRect];
        [[UIColor whiteColor] setFill];
        [circlePath fill];
        [[UIColor systemGray5Color] setStroke];
        circlePath.lineWidth = 5;
        [circlePath stroke];
    }];
    
    // MARK: Validate route
    NSLog(@"Route: %@", route);
    
    // add annotations
    for (State* state in route) {
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        annotation.coordinate = CLLocationCoordinate2DMake([state.latitude doubleValue], [state.longitude doubleValue]);
        annotation.title = state.stateName;

        [self.mapView addAnnotation:annotation];
    }

    // draw overlay
    int count = (int)[route count];
                      
    CLLocationCoordinate2D *coords = malloc(sizeof(CLLocationCoordinate2D) * count);
    for (NSUInteger i = 0; i < count; i++) {
        State *state = route[i];  // filteredArray should contain NSValue objects.
        coords[i] = CLLocationCoordinate2DMake([state.latitude doubleValue], [state.longitude doubleValue]);
    }
    
    MKPolyline *polyline = [MKPolyline polylineWithCoordinates:coords count:count];
    [self.mapView addOverlay:polyline level:MKOverlayLevelAboveLabels];
    free(coords);
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineRenderer *renderer = [[MKPolylineRenderer alloc] initWithPolyline:(MKGeodesicPolyline*)overlay];
        renderer.lineWidth = 5;
        renderer.strokeColor = [UIColor systemGray5Color];
//        renderer.fillColor = [UIColor systemBlueColor];
//        renderer.alpha = 0.5;
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
