//
//  ShippingRouteViewHeader.h
//  StatelyShipments
//
//  Created by Sam Burkhard on 3/9/25.
//

#import <UIKit/UIKit.h>

@interface ShippingRouteViewHeader: UIView

@property (nonatomic, strong) UILabel *totalCostLabel;
@property (nonatomic, strong) UILabel *sourceStateLabel;
@property (nonatomic, strong) UILabel *destinationStateLabel;

@end
