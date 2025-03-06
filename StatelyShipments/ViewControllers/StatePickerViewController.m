//
//  StatePickerViewController.m
//  StatelyShipments
//
//  Created by Sam Burkhard on 3/5/25.
//

#import <Foundation/Foundation.h>
#import "StatePickerViewController.h"
#import "../Utility/Extensions/UINavigationController+SheetControlAdditions.h"
#import "../Models/State.h"
#import "../Utility/StatesLoader.h"

@interface StatePickerViewController () <UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating>

@property (strong, nonatomic) UISearchController *searchController;
@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) NSArray<State*>* states;
@property (nonatomic, strong) NSArray<State*>* filteredStates;

- (void)closeTapped;

@end

@implementation StatePickerViewController

- (void)viewWillDisappear:(BOOL)animated {
    // call callback
    if (self.selectionHandler) {
        self.selectionHandler(self.selectedState);
    }
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.states = [[StatesLoader shared] allStatesAlphabetical];
    self.filteredStates = self.states;
    
    // force medium detent
    [self.navigationController animateMediumDetent];
    
    // set up navigation bar
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    // custom back button
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeClose];
    [closeButton addTarget:self action:@selector(closeTapped) forControlEvents:UIControlEventTouchUpInside];
    [closeButton sizeToFit];

    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:closeButton];
    self.navigationItem.leftBarButtonItem = barButtonItem;
    
    self.navigationItem.title = @"Select a State";
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.obscuresBackgroundDuringPresentation = NO;
    self.searchController.searchBar.placeholder = @"Search States";
    self.navigationItem.searchController = self.searchController;
    self.navigationItem.hidesSearchBarWhenScrolling = NO;
    self.definesPresentationContext = YES;
    
    // set up tableview
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.scrollEnabled = YES;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.delegate = self;
    
    [self.view addSubview:self.tableView];
    
    [NSLayoutConstraint activateConstraints:@[
        [self.tableView.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.tableView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];
}

- (void)closeTapped {
    [self.navigationController popViewControllerAnimated:NO];
    [self.navigationController animateSmallDetent];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

#pragma mark Delegate SearchField Actions

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    NSString *searchText = searchController.searchBar.text;
    
    if (searchText.length == 0) {
        self.filteredStates = self.states;
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(State *state, NSDictionary *bindings) {
            return [state.stateName localizedCaseInsensitiveContainsString:searchText];
        }];
        self.filteredStates = [self.states filteredArrayUsingPredicate:predicate];
    }
    
    [self.tableView reloadData];
}

#pragma mark Delegate TableView Actions

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // fixed height for all cells
    return 50;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    static NSString * const cellIdentifier = @"stateCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    State* state = self.filteredStates[indexPath.row];
    cell.textLabel.text = state.stateName;
    
    if (self.selectedState && [self.selectedState isEqual:state]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredStates.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    State *selectedState = self.filteredStates[indexPath.row];
    self.selectedState = selectedState;
    NSLog(@"Selected state %@", selectedState);
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [tableView reloadData];
}

@end
