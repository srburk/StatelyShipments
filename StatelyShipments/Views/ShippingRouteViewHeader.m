//
//  ShippingRouteViewHeader.m
//  StatelyShipments
//
//  Created by Sam Burkhard on 3/9/25.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ShippingRouteViewHeader.h"

@implementation ShippingRouteViewHeader

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    
    UIFontDescriptor *title1Descriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleTitle1];
    UIFontDescriptor *boldTitle1Descriptor = [title1Descriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
    
    self.layer.cornerRadius = 12.5;
    self.layer.cornerCurve = kCACornerCurveCircular;
    self.backgroundColor = [UIColor tintColor];
    
    // MARK: Header View
    
    UIStackView *headerLabelStackView = [[UIStackView alloc] init];
    headerLabelStackView.axis = UILayoutConstraintAxisHorizontal;
    headerLabelStackView.alignment = UIStackViewAlignmentCenter;
    headerLabelStackView.distribution = UIStackViewDistributionFill;
//    routeShorthandLabelStackView.spacing = 5;
    headerLabelStackView.translatesAutoresizingMaskIntoConstraints = NO;
        
    UILabel *routeHeaderLabel = [[UILabel alloc] init];
    routeHeaderLabel.text = @"Route";
    routeHeaderLabel.textColor = [UIColor blackColor];
    routeHeaderLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    routeHeaderLabel.translatesAutoresizingMaskIntoConstraints = NO;

    [headerLabelStackView addArrangedSubview:routeHeaderLabel];
    
    UILabel *totalCostLabelHeader = [[UILabel alloc] init];
    totalCostLabelHeader.text = @"Total Cost";
    totalCostLabelHeader.textColor = [UIColor blackColor];
    totalCostLabelHeader.font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    totalCostLabelHeader.translatesAutoresizingMaskIntoConstraints = NO;

    [headerLabelStackView addArrangedSubview:totalCostLabelHeader];
    
    // MARK: Content View
    
    UIStackView *contentLabelStackView = [[UIStackView alloc] init];
    contentLabelStackView.axis = UILayoutConstraintAxisHorizontal;
    contentLabelStackView.alignment = UIStackViewAlignmentCenter;
    contentLabelStackView.distribution = UIStackViewDistributionEqualSpacing;
//    routeShorthandLabelStackView.spacing = 5;
    contentLabelStackView.translatesAutoresizingMaskIntoConstraints = NO;
        
    // route label
    UIStackView *routeShorthandLabelStackView = [[UIStackView alloc] init];
    routeShorthandLabelStackView.axis = UILayoutConstraintAxisHorizontal;
    routeShorthandLabelStackView.alignment = UIStackViewAlignmentLeading;
//    routeShorthandLabelStackView.distribution = UIStackViewDistributionEqualSpacing;
    routeShorthandLabelStackView.spacing = 2;
    routeShorthandLabelStackView.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.sourceStateLabel = [[UILabel alloc] init];
    self.sourceStateLabel.textColor = [UIColor blackColor];
    self.sourceStateLabel.font = [UIFont fontWithDescriptor:boldTitle1Descriptor size:0];
    self.sourceStateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    [routeShorthandLabelStackView addArrangedSubview:self.sourceStateLabel];
    
    UIImage *arrowImage = [UIImage systemImageNamed:@"arrow.right" withConfiguration:[UIImageSymbolConfiguration configurationWithFont:[UIFont fontWithDescriptor:boldTitle1Descriptor size:0]]];
    UIImageView *arrowImageView = [[UIImageView alloc] initWithImage:arrowImage];
    arrowImageView.tintColor = [UIColor blackColor];
    arrowImageView.translatesAutoresizingMaskIntoConstraints = NO;
    arrowImageView.contentMode = UIViewContentModeScaleAspectFit;

    // Add the arrow image view to the routeShorthandLabelStackView
    [routeShorthandLabelStackView addArrangedSubview:arrowImageView];
    
    self.destinationStateLabel = [[UILabel alloc] init];
    self.destinationStateLabel.textColor = [UIColor blackColor];
    self.destinationStateLabel.font = [UIFont fontWithDescriptor:boldTitle1Descriptor size:0];
    self.destinationStateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    [routeShorthandLabelStackView addArrangedSubview:self.destinationStateLabel];
    
    [contentLabelStackView addArrangedSubview:routeShorthandLabelStackView];

    // cost label
    self.totalCostLabel = [[UILabel alloc] init];
    self.totalCostLabel.textColor = [UIColor blackColor];
    self.totalCostLabel.font = [UIFont fontWithDescriptor:boldTitle1Descriptor size:0];
    self.totalCostLabel.translatesAutoresizingMaskIntoConstraints = NO;

    [contentLabelStackView addArrangedSubview:self.totalCostLabel];
    
    // new main container
    UIStackView *mainStackView = [[UIStackView alloc] init];
    mainStackView.axis = UILayoutConstraintAxisVertical;
    mainStackView.alignment = UIStackViewAlignmentFill;
    mainStackView.distribution = UIStackViewDistributionEqualSpacing;
    mainStackView.spacing = 5;
    mainStackView.translatesAutoresizingMaskIntoConstraints = NO;
    
    [mainStackView addArrangedSubview:headerLabelStackView];
    [mainStackView addArrangedSubview:contentLabelStackView];
    
    [self addSubview:mainStackView];
    
    [NSLayoutConstraint activateConstraints:@[
        [headerLabelStackView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor constant:15],
        [headerLabelStackView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor constant:-15],
    ]];
    
    [NSLayoutConstraint activateConstraints:@[
        [contentLabelStackView.leadingAnchor constraintEqualToAnchor:headerLabelStackView.leadingAnchor],
        [contentLabelStackView.trailingAnchor constraintEqualToAnchor:headerLabelStackView.trailingAnchor],
    ]];
    
    [NSLayoutConstraint activateConstraints:@[
        [mainStackView.centerYAnchor constraintEqualToAnchor:self.centerYAnchor],
    ]];
}

@end

