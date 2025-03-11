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

- (void)clearMapOverlays;
- (void)addMapOverlaysForRoute:(NSArray*)route;

@end
