//
//  StatePickerButton.m
//  StatelyShipments
//
//  Created by Sam Burkhard on 3/3/25.
//

#import <Foundation/Foundation.h>
#import "StatePickerButton.h"

@interface StatePickerButton ()
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UILabel *label;
@end

@implementation StatePickerButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    
    self.button = [UIButton buttonWithType:UIButtonTypeSystem];
    NSString *buttonTitle = (self.selectedState) ? self.selectedState.stateCode : @"Select";
    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:buttonTitle
                                                                          attributes:@{NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleTitle1]}];
    
    [self.button setAttributedTitle:attributedTitle forState:UIControlStateNormal];
    self.button.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:self.button];
    
    self.label = [[UILabel alloc] init];
    self.label.translatesAutoresizingMaskIntoConstraints = NO;
    self.label.text = @"Label Text";
    self.label.textAlignment = NSTextAlignmentLeft;
    self.label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    
    [self addSubview:self.label];
    
    [NSLayoutConstraint activateConstraints:@[
       [self.label.topAnchor constraintEqualToAnchor:self.topAnchor],
       [self.label.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
       [self.label.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
       
       // top padding of 10 between them for breathing room
       [self.button.topAnchor constraintEqualToAnchor:self.label.bottomAnchor constant:10],
       [self.button.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
       [self.button.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
       [self.button.bottomAnchor constraintEqualToAnchor:self.bottomAnchor]
    ]];
    
    self.label.userInteractionEnabled = NO;
}

@end
