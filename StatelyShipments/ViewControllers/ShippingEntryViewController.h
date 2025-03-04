//
//  ShippingEntryViewController.h
//  StatelyShipments
//
//  Created by Sam Burkhard on 3/3/25.
//

#import <UIKit/UIKit.h>

@interface ShippingEntryViewController : UIViewController

@property(nonatomic, strong) UINavigationController* navigationController;

- (id)initWithNavigationController:(UINavigationController*)navController;

@end
