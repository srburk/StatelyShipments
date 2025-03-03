//
//  StatePickerViewController.h
//  StatelyShipments
//
//  Created by Sam Burkhard on 3/3/25.
//

#import <UIKit/UIKit.h>

@protocol StatePickerViewControllerDelegate <NSObject>
- (void)statePicker:(UIViewController *)picker didSelectOption:(NSString *)option;
@end

@interface StatePickerViewController: UITableViewController

@property NSInteger selectedIndex;
@property NSArray *states;
@property (nonatomic, weak) id delegate;

- (id) initWithStates:(NSArray*)stateList;

@end
