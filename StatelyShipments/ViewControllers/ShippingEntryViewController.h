//
//  ShippingEntryViewController.h
//  StatelyShipments
//
//  Created by Sam Burkhard on 3/3/25.
//

#import <UIKit/UIKit.h>
#import "../MainCoordinator.h"
#import "../Views/StatePickerButton.h"

@interface ShippingEntryViewController : UIViewController

@property (nonatomic, weak) MainCoordinator *coordinator;

@property (nonatomic, strong, readonly) StatePickerButton* sourcePickerButton;
@property (nonatomic, strong, readonly) StatePickerButton* destinationPickerButton;
@property (nonatomic, strong, readonly) UIActivityIndicatorView* spinnerView;

-(double)getStateBorderFee;

@end
