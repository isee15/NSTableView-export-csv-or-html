//
//  MainViewController.m
//  TableViewExport
//
//  Created by isee15 on 15/5/9.
//  Copyright (c) 2015年 isee15. All rights reserved.
//

#import "MainViewController.h"
#import "TableViewDataSource.h"
#import "ExportMenu.h"

@interface MainViewController ()

@property(weak) IBOutlet NSTableView *tableView;
@property TableViewDataSource *dataSource;
@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do view setup here.
    self.dataSource = [[TableViewDataSource alloc] init];
    while ([[self.tableView tableColumns] count] > 0) {
        [self.tableView removeTableColumn:[[self.tableView tableColumns] lastObject]];
    }
    self.dataSource.tableData = @[@{@"col1" : @"1111", @"col2" : @"2222"},
            @{@"col1" : @"vvvvv", @"col2" : @"zzzz"}];

    for (NSString *key in @[@"col1", @"col2"]) {
        NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:key];
        [[column headerCell] setStringValue:key];
        //column.title = key;
        [self.tableView addTableColumn:column];
    }
    self.tableView.dataSource = self.dataSource;
    [self.tableView reloadData];
    self.tableView.menu = [[ExportMenu alloc] initWithTableView:self.tableView];
}

@end
