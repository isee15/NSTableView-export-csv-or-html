//
// Created by rz on 14/12/14.
// Copyright (c) 2014 miracle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

@interface TableViewDataSource : NSObject <NSTableViewDataSource>
@property(copy) NSArray *tableData;
@end