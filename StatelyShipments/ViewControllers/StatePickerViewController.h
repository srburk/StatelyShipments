//
//  StatePickerViewController.h
//  StatelyShipments
//
//  Created by Sam Burkhard on 3/5/25.
//

#import <UIKit/UIKit.h>
#import "../Models/State.h"

@interface StatePickerViewController : UIViewController

@property (nonatomic, strong) UINavigationController* navigationController;
@property (nonatomic, strong) State* selectedState;
@property (nonatomic, copy) void (^selectionHandler)(State *selectedState);

@end
