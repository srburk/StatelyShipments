//
//  StatePickerButton.m
//  StatelyShipments
//
//  Created by Sam Burkhard on 3/3/25.
//

#import <Foundation/Foundation.h>
#import "StatePickerButton.h"

#import "../Utility/StatesLoader.h"

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
        
    UIButtonConfiguration* buttonConfiguration = [UIButtonConfiguration grayButtonConfiguration];
    
    NSString *buttonTitle = (self.selectedState) ? self.selectedState.stateCode : @"State";
    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:buttonTitle attributes:@{NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleTitle1]}];

    buttonConfiguration.attributedTitle = attributedTitle;
    buttonConfiguration.baseForegroundColor = [UIColor colorNamed:@"PrimaryColor"];
    buttonConfiguration.baseBackgroundColor = [UIColor systemGray5Color];
    buttonConfiguration.image = [UIImage systemImageNamed:@"chevron.up.chevron.down"];
    buttonConfiguration.imagePadding = 5;
    
    self.button = [UIButton buttonWithConfiguration:buttonConfiguration primaryAction:nil];
    [self.button setAttributedTitle:attributedTitle forState:UIControlStateNormal];
    self.button.translatesAutoresizingMaskIntoConstraints = NO;
//    self.button.showsMenuAsPrimaryAction = YES;
    
    [self addSubview:self.button];
    
    self.label = [[UILabel alloc] init];
    self.label.translatesAutoresizingMaskIntoConstraints = NO;
    self.label.text = @"Label Text";
    self.label.textAlignment = NSTextAlignmentLeft;
    self.label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    self.label.textColor = [UIColor labelColor];
    
    [self addSubview:self.label];
    
    // padding priority
    NSLayoutConstraint *paddingConstraint = [self.button.topAnchor constraintEqualToAnchor:self.label.bottomAnchor constant:10];
    paddingConstraint.priority = UILayoutPriorityDefaultHigh;
    
    [NSLayoutConstraint activateConstraints:@[
       [self.label.topAnchor constraintEqualToAnchor:self.topAnchor],
       [self.label.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
       [self.label.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
       
       // top padding of 10 between them for breathing room
       paddingConstraint,
       
       [self.button.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
       [self.button.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
       [self.button.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
    ]];
    
    self.label.userInteractionEnabled = NO;
}

- (void)updateSelectedState:(State*) newSelectedState {
    self.selectedState = newSelectedState;
    
    NSString *newTitle = ([self.selectedState isKindOfClass:[State class]]) ? self.selectedState.stateCode : @"State";
    
    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:newTitle attributes:@{NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleTitle1]}];
    [self.button setAttributedTitle:attributedTitle forState:UIControlStateNormal];
}

@end
