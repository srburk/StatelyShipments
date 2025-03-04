//
//  MainViewController.m
//  StatelyShipments
//
//  Created by Sam Burkhard on 3/4/25.
//

#import <Foundation/Foundation.h>

#import "MainViewController.h"
#import "ShippingEntryViewController.h"

@interface MainViewController ()

@property (nonatomic, strong) UINavigationController* drawerNavigationController;

@end

@implementation MainViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor systemGray4Color];
    
    self.drawerNavigationController = [[UINavigationController alloc] init];
    self.drawerNavigationController.modalInPresentation = YES;
    self.drawerNavigationController.navigationBarHidden = YES;
    
    self.drawerNavigationController.navigationBar.tintColor = [UIColor blackColor];
    
    ShippingEntryViewController *root = [[ShippingEntryViewController alloc] initWithNavigationController:self.drawerNavigationController];
    
    [self.drawerNavigationController setViewControllers:@[root]];
}

- (void)viewDidAppear:(BOOL)animated {
    if (self.drawerNavigationController.sheetPresentationController) {
        UISheetPresentationControllerDetent *mediumDetent = [UISheetPresentationControllerDetent mediumDetent];
        self.drawerNavigationController.sheetPresentationController.detents = @[mediumDetent];
        self.drawerNavigationController.sheetPresentationController.largestUndimmedDetentIdentifier = UISheetPresentationControllerDetentIdentifierMedium;
    }
    [self presentViewController:self.drawerNavigationController animated:NO completion:nil];
}

@end
