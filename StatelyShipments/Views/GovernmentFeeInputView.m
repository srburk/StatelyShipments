//
//  GovernmentFeeInputView.m
//  StatelyShipments
//
//  Created by Sam Burkhard on 3/4/25.
//

#import <Foundation/Foundation.h>
#import "GovernmentFeeInputView.h"

@interface GovernmentFeeInputView () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField* textField;
@property (nonatomic, strong) UILabel* label;

- (void)setupView;

@end

@implementation GovernmentFeeInputView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    
    // set up leading label
    self.label = [[UILabel alloc] init];
    self.label.translatesAutoresizingMaskIntoConstraints = NO;
    self.label.text = @"State Border Fee:";
    self.label.textAlignment = NSTextAlignmentLeft;
    self.label.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    
    [self addSubview:self.label];
    
    // set up government state border fees
    self.textField = [[UITextField alloc] init];
    self.textField.placeholder = @"$0";
    self.textField.borderStyle = UITextBorderStyleRoundedRect;
    self.textField.backgroundColor = [UIColor systemGray5Color];
    self.textField.translatesAutoresizingMaskIntoConstraints = NO;
    self.textField.keyboardType = UIKeyboardTypeDecimalPad;
    self.textField.textAlignment = NSTextAlignmentRight;
    
    // delegate for handling closes and changing input to number
    self.textField.delegate = self;
    
    // button for closing keyboard
    UIToolbar *toolbar = [[UIToolbar alloc] init];
    [toolbar sizeToFit];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonTapped:)];
    toolbar.items = @[flexibleSpace, doneButton];
    self.textField.inputAccessoryView = toolbar;
    
    
    [self addSubview:self.textField];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.textField.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],
        [self.textField.topAnchor constraintEqualToAnchor:self.topAnchor],
        [self.textField.widthAnchor constraintEqualToAnchor:self.widthAnchor multiplier:0.45],
        
        [self.label.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [self.label.centerYAnchor constraintEqualToAnchor:self.textField.centerYAnchor],
    ]];
    
}

- (void)doneButtonTapped:(id)sender {
    [self.textField endEditing:YES];
}

#pragma mark Delegate

// reformat to dollar
- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)string {

    NSString *currentText = textField.text ?: @"";
    NSString *newText = [currentText stringByReplacingCharactersInRange:range withString:string];
    
    NSCharacterSet *nonDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSString *digitsOnly = [[newText componentsSeparatedByCharactersInSet:nonDigits] componentsJoinedByString:@""];
    
    // cap input
    NSInteger maxAllowedDigits = 8;
    if ([digitsOnly length] > maxAllowedDigits) {
        return NO;
    }
    
    double value = [digitsOnly doubleValue] / 100.0;
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    
    NSString *formatted = [formatter stringFromNumber:@(value)];
    
    textField.text = formatted;
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
}

@end
