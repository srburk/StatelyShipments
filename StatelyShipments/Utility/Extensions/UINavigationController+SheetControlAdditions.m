//
//  UINavigationController+SheetControlAdditions.m
//  StatelyShipments
//
//  Created by Sam Burkhard on 3/5/25.
//

#import <Foundation/Foundation.h>
#import "UINavigationController+SheetControlAdditions.h"

@implementation UINavigationController (SheetControlAdditions)

- (void)setSmallDetentOnly {
    if (self.sheetPresentationController) {
        
        UISheetPresentationControllerDetent *smallDetent = [UISheetPresentationControllerDetent customDetentWithIdentifier:@"customSmall" resolver:^CGFloat(id<UISheetPresentationControllerDetentResolutionContext>  _Nonnull context) {
            return 250.0;
        }];
        
        [self.sheetPresentationController animateChanges:^{
            self.sheetPresentationController.detents = @[smallDetent];
            self.sheetPresentationController.largestUndimmedDetentIdentifier = smallDetent.identifier;
        }];

        self.sheetPresentationController.prefersScrollingExpandsWhenScrolledToEdge = NO;
        self.sheetPresentationController.prefersGrabberVisible = NO;
    }
    
}

- (void)setMediumDetentOnly {
    
    // check for sheetPresentationController
    if (self.sheetPresentationController) {
        self.sheetPresentationController.prefersScrollingExpandsWhenScrolledToEdge = NO;
        
        [self.sheetPresentationController animateChanges:^{
            self.sheetPresentationController.detents = @[[UISheetPresentationControllerDetent mediumDetent]];
            self.sheetPresentationController.largestUndimmedDetentIdentifier = UISheetPresentationControllerDetentIdentifierMedium;
        }];

        self.sheetPresentationController.prefersGrabberVisible = NO;
    }
}

@end
