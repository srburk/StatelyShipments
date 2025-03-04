//
//  StatePickerViewController.m
//  StatelyShipments
//
//  Created by Sam Burkhard on 3/3/25.
//

#import <Foundation/Foundation.h>
#import "StatePickerViewController.h"

@implementation StatePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"State Picker";
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if ([self.delegate respondsToSelector:@selector(statePicker:didSelectOption:)]) {
        [self.delegate statePicker:self didSelectOption:self.states[self.selectedIndex]];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndex = indexPath.row;
    [tableView reloadData];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.states.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = self.states[indexPath.row];
    cell.accessoryType = (indexPath.row == self.selectedIndex) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;

    return cell;
}

- (id)initWithStates:(NSArray *)stateList {
    if (self = [super init]) {
        self.states = stateList;
        self.states = [self.states sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    }
    return self;
}

@end
