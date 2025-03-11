//
//  MainViewController.h
//  StatelyShipments
//
//  Created by Sam Burkhard on 3/4/25.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "../MainCoordinator.h"

@interface MainViewController: UIViewController

@property (nonatomic, weak) MainCoordinator *coordinator;

@property (nonatomic, strong, readonly) MKMapView* mapView;

- (void)clearMap;
- (void)drawRoute:(NSArray*)route;
- (void)focusMapOnPoint:(MKMapPoint)point1 andPoint:(MKMapPoint)point2;

@end
