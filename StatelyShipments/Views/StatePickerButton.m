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
    NSString *buttonTitle = (self.selectedState) ? self.selectedState.stateCode : @"Select";
    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:buttonTitle attributes:@{NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2]}];

    buttonConfiguration.attributedTitle = attributedTitle;
    buttonConfiguration.baseForegroundColor = [UIColor blackColor];
    buttonConfiguration.image = [UIImage systemImageNamed:@"chevron.up.chevron.down"];
    buttonConfiguration.imagePadding = 5;
    
    self.button = [UIButton buttonWithConfiguration:buttonConfiguration primaryAction:nil];
    [self.button setAttributedTitle:attributedTitle forState:UIControlStateNormal];
    self.button.translatesAutoresizingMaskIntoConstraints = NO;
    self.button.showsMenuAsPrimaryAction = YES;
    
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

- (void)setupPickerMenu:(NSArray<State *> *)states {
    NSMutableArray<UIAction *> *actions = [NSMutableArray array];
    for (State *state in states) {
        UIAction *action = [UIAction actionWithTitle:state.stateCode image:nil identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
            
            [self updateSelectedState:state];
            
            if (self.selectionHandler) {
                self.selectionHandler(self.selectedState);
            }
        }];
        
        [actions addObject:action];
    }
    UIMenu *menu = [UIMenu menuWithChildren:actions];
    self.button.menu = menu;
}

- (void)updateSelectedState:(State*) newSelectedState {
    self.selectedState = newSelectedState;
    
    NSString *newTitle = ([self.selectedState isKindOfClass:[State class]]) ? self.selectedState.stateCode : @"Select";
    
    NSAttributedString *attributedTitle = [[NSAttributedString alloc] initWithString:newTitle attributes:@{NSFontAttributeName: [UIFont preferredFontForTextStyle:UIFontTextStyleTitle2]}];
    [self.button setAttributedTitle:attributedTitle forState:UIControlStateNormal];
}

@end
