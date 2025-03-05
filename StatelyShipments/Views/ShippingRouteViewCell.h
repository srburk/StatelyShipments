//
//  ShippingRouteViewCell.h
//  StatelyShipments
//
//  Created by Sam Burkhard on 3/5/25.
//

#import <UIKit/UIKit.h>

@interface ShippingRouteViewCell: UITableViewCell

@property (nonatomic, strong, readonly) UILabel *stateLabel;
@property (nonatomic, strong, readonly) UILabel *fuelCostLabel;

@end
