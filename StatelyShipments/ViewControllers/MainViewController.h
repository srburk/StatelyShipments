//
//  MainViewController.h
//  StatelyShipments
//
//  Created by Sam Burkhard on 3/4/25.
//

#import <UIKit/UIKit.h>

@interface MainViewController: UIViewController

- (void)clearMapOverlays;
- (void)addMapOverlaysForRoute:(NSArray*)route;

@end
