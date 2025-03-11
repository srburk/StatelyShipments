//
//  ShippingRouteCellView.h
//  StatelyShipments
//
//  Created by Sam Burkhard on 3/5/25.
//

#import <UIKit/UIKit.h>

@interface ShippingRouteCellView: UITableViewCell

@property (nonatomic, strong, readonly) UILabel *stateLabel;
@property (nonatomic, strong, readonly) UILabel *fuelCostLabel;

@property (nonatomic, assign) BOOL isLastCell;

@end
