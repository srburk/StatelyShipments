//
//  ShippingRouteViewCell.m
//  StatelyShipments
//
//  Created by Sam Burkhard on 3/5/25.
//

#import <Foundation/Foundation.h>
#import "ShippingRouteViewCell.h"

@interface ShippingRouteViewCell ()

@property (nonatomic, strong) UILabel *stateLabel;
@property (nonatomic, strong) UILabel *fuelCostLabel;

@end

@implementation ShippingRouteViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    
    self.contentView.layoutMargins = UIEdgeInsetsMake(10, 0, 10, 0);
    
    self.stateLabel = [[UILabel alloc] init];
    self.stateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.stateLabel.font = [UIFont boldSystemFontOfSize:17];
    [self.contentView addSubview:self.stateLabel];

    self.fuelCostLabel = [[UILabel alloc] init];
    self.fuelCostLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.fuelCostLabel.font = [UIFont systemFontOfSize:15];
    [self.contentView addSubview:self.fuelCostLabel];

    [NSLayoutConstraint activateConstraints:@[
//        [self.stateLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:15],
        [self.stateLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-15],
        [self.stateLabel.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
//        [self.stateLabel.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:10],

//        [self.fuelCostLabel.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:15],
        [self.fuelCostLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-15],
        [self.fuelCostLabel.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
//        [self.fuelCostLabel.topAnchor constraintEqualToAnchor:self.stateLabel.bottomAnchor constant:5],
//        [self.fuelCostLabel.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-10]
    ]];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.stateLabel = nil;
    self.fuelCostLabel = nil;
}
@end
