//
//  MainViewController.m
//  StatelyShipments
//
//  Created by Sam Burkhard on 3/4/25.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#import "MainViewController.h"
#import "ShippingEntryViewController.h"
#import "../Utility/StatesLoader.h"

@interface MainViewController ()

@property (nonatomic, strong) UINavigationController* drawerNavigationController;
@property (nonatomic, strong) MKMapView* mapView;

@end

@implementation MainViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
//    self.view.backgroundColor = [UIColor systemGray4Color];
    
    self.mapView = [[MKMapView alloc] init];
    self.mapView.translatesAutoresizingMaskIntoConstraints = NO;
    self.mapView.mapType = MKMapTypeMutedStandard;
    
    [[StatesLoader shared] loadStatesFromPlistAtPath:@"States"]; // TODO: Remove this and hone init
    
    for (State* state in [[StatesLoader shared] allStates]) {
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        annotation.coordinate = CLLocationCoordinate2DMake([state.latitude doubleValue], [state.longitude doubleValue]);
        annotation.title = state.stateName;
        
        [self.mapView addAnnotation:annotation];
    }
//    self.mapView.map
    [self.view addSubview:self.mapView];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.mapView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.mapView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.mapView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.mapView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];
    
    self.drawerNavigationController = [[UINavigationController alloc] init];
    self.drawerNavigationController.modalInPresentation = YES;
    self.drawerNavigationController.navigationBarHidden = YES;
    
    self.drawerNavigationController.navigationBar.tintColor = [UIColor blackColor];
    
    ShippingEntryViewController *root = [[ShippingEntryViewController alloc] initWithNavigationController:self.drawerNavigationController];
    
    [self.drawerNavigationController setViewControllers:@[root]];
}

- (void)viewDidAppear:(BOOL)animated {
    [self presentViewController:self.drawerNavigationController animated:NO completion:nil];
}

@end
