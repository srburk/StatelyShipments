//
//  ShippingRouteCellView.m
//  StatelyShipments
//
//  Created by Sam Burkhard on 3/5/25.
//

#import <Foundation/Foundation.h>
#import "ShippingRouteCellView.h"

@interface ShippingRouteCellView ()

@property (nonatomic, strong) UILabel *stateLabel;
@property (nonatomic, strong) UILabel *fuelCostLabel;

@property (nonatomic, strong) NSLayoutConstraint *verticalBarHeight;
@property (nonatomic, strong) UIView *verticalBar;

@end

@implementation ShippingRouteCellView

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
        
    self.stateLabel = [[UILabel alloc] init];
    self.stateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.stateLabel.font = [UIFont boldSystemFontOfSize:17];
    [self.contentView addSubview:self.stateLabel];

    self.fuelCostLabel = [[UILabel alloc] init];
    self.fuelCostLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.fuelCostLabel.font = [UIFont systemFontOfSize:15];
    [self.contentView addSubview:self.fuelCostLabel];

    [NSLayoutConstraint activateConstraints:@[
        [self.stateLabel.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],

        [self.fuelCostLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-25],
        [self.fuelCostLabel.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
    ]];
    
    // vertical line going through all cells
    self.verticalBar = [[UIView alloc] init];
    self.verticalBar.translatesAutoresizingMaskIntoConstraints = NO;
    self.verticalBar.backgroundColor = [UIColor tintColor];
    
    [self.contentView addSubview:self.verticalBar];
    
    self.verticalBarHeight = [self.verticalBar.heightAnchor constraintEqualToAnchor:self.heightAnchor];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.verticalBar.widthAnchor constraintEqualToConstant:10],
        self.verticalBarHeight,
        [self.verticalBar.topAnchor constraintEqualToAnchor:self.contentView.topAnchor],
        [self.verticalBar.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant: 35]
    ]];
    
    // Circle View
    UIView *circleView = [[UIView alloc] init];
    circleView.translatesAutoresizingMaskIntoConstraints = NO;
    
#define CIRCLE_SIZE 20
#define STROKE_WIDTH 5
    
    // destination indicator
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, CIRCLE_SIZE, CIRCLE_SIZE)];
    
    CAShapeLayer *circleShapeLayer = [CAShapeLayer layer];
    circleShapeLayer.path = circlePath.CGPath;
    circleShapeLayer.fillColor = [UIColor systemBackgroundColor].CGColor;
    circleShapeLayer.strokeColor = [UIColor tintColor].CGColor;
    circleShapeLayer.lineWidth = 5;
    [circleView.layer addSublayer:circleShapeLayer];
    
    [self.contentView addSubview:circleView];
    
    [NSLayoutConstraint activateConstraints:@[
        [circleView.centerYAnchor constraintEqualToAnchor:self.contentView.centerYAnchor],
        [circleView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant: 30],
        [circleView.widthAnchor constraintEqualToConstant:CIRCLE_SIZE],
        [circleView.heightAnchor constraintEqualToConstant:CIRCLE_SIZE]
    ]];
}

- (void)setIsLastCell:(BOOL)isLastCell {
    if (isLastCell != _isLastCell) {
        
        CGFloat multiplier = isLastCell ? 0.5 : 1.0;
        
        if (self.verticalBarHeight) {
            [NSLayoutConstraint deactivateConstraints:@[self.verticalBarHeight]];
        }
        self.verticalBarHeight = [self.verticalBar.heightAnchor constraintEqualToAnchor:self.heightAnchor multiplier:multiplier];
        self.verticalBarHeight.active = YES;
        
        [self setNeedsLayout];
        [self layoutIfNeeded];
    }
    _isLastCell = isLastCell;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.stateLabel = nil;
    self.fuelCostLabel = nil;
}
@end
