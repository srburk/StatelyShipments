//
//  StatePickerButton.h
//  StatelyShipments
//
//  Created by Sam Burkhard on 3/3/25.
//

#import <UIKit/UIKit.h>
#import "../Models/State.h"

@interface StatePickerButton: UIView

@property (nonatomic, strong) State* selectedState;

@property (nonatomic, strong, readonly) UIButton *button;
@property (nonatomic, strong, readonly) UILabel *label;

@end
