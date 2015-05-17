//
//  ExportMenu.m
//  TableViewExport
//
//  Created by isee15 on 15/5/9.
//  Copyright (c) 2015年 isee15. All rights reserved.
//

#import "ExportMenu.h"

typedef NS_ENUM(int, OpMethod)
{
    OpViewHtml,
    OpExportCsv,
    OpExprotWindowsCsv,
    OpExportHtml

};


@interface ExportMenu ()
@property(weak) NSTableView *tableView;
@end

@implementation ExportMenu

- (instancetype)initWithTableView:(NSTableView *)tableView
{
    if (self = [super init]) {
        _tableView = tableView;
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"Export as Mac CSV" action:@selector(onMenuClick:) keyEquivalent:@""];
        item.tag = OpExportCsv;
        item.target = self;
        [self addItem:item];
        item = [[NSMenuItem alloc] initWithTitle:@"Export as Windows CSV" action:@selector(onMenuClick:) keyEquivalent:@""];
        item.tag = OpExprotWindowsCsv;
        item.target = self;
        [self addItem:item];
        item = [[NSMenuItem alloc] initWithTitle:@"Export as Html" action:@selector(onMenuClick:) keyEquivalent:@""];
        item.tag = OpExportHtml;
        item.target = self;
        [self addItem:item];
        item = [[NSMenuItem alloc] initWithTitle:@"View as Html" action:@selector(onMenuClick:) keyEquivalent:@""];
        item.tag = OpViewHtml;
        item.target = self;
        [self addItem:item];
    }
    return self;
}

- (NSString *)stringByEncodingXMLEntities:(NSString *)str
{
    if (nil == str || str.length == 0)
        return @"";
    NSMutableString *result = [NSMutableString stringWithString:str];
    [result replaceOccurrencesOfString:@"&" withString:@"&amp;" options:NSLiteralSearch range:NSMakeRange(0, result.length)];
    [result replaceOccurrencesOfString:@"'" withString:@"&apos;" options:NSLiteralSearch range:NSMakeRange(0, result.length)];
    [result replaceOccurrencesOfString:@"\"" withString:@"&quot;" options:NSLiteralSearch range:NSMakeRange(0, result.length)];
    [result replaceOccurrencesOfString:@"<" withString:@"&lt;" options:NSLiteralSearch range:NSMakeRange(0, result.length)];
    [result replaceOccurrencesOfString:@">" withString:@"&gt;" options:NSLiteralSearch range:NSMakeRange(0, result.length)];
    return result;
}

- (NSString *)genCsv:(NSString *)splitChar
{
    NSMutableString *data = [NSMutableString string];
    NSArray *cols = self.tableView.tableColumns;
    NSInteger rowCount = self.tableView.numberOfRows;
    for (NSTableColumn *col in cols) {
        [data appendFormat:@"\"%@\"%@", [[col.headerCell title] stringByReplacingOccurrencesOfString:@"\"" withString:@"\"\""], splitChar];
    }
    [data appendString:@"\n"];
    for (int i = 0; i < rowCount; i++) {
        for (NSTableColumn *col in cols) {
            id cell = [self.tableView.dataSource tableView:self.tableView objectValueForTableColumn:col row:i];
            [data appendFormat:@"\"%@\"%@", [(cell != nil ? [cell description] : @"") stringByReplacingOccurrencesOfString:@"\"" withString:@"\"\""], splitChar];
        }
        [data appendString:@"\n"];
    }
    return [data copy];
}

- (NSString *)genHtml
{
    NSMutableString *data = [NSMutableString string];
    NSArray *cols = self.tableView.tableColumns;
    NSInteger rowCount = self.tableView.numberOfRows;
    //[data appendString:@"\357\273\277"];
    [data appendFormat:@"<!DOCTYPE HTML>\
     <html>\
     <head>\
     <meta http-equiv='Content-Type' content='text/html; charset=utf-8'/>\
     <script src='http://libs.baidu.com/jquery/2.0.0/jquery.min.js'></script>\
     <script src='http://cdn.datatables.net/1.10.7/js/jquery.dataTables.min.js'></script>\
     <script>\
     $(document).ready(function () {\
        $('#resultTb').dataTable({\
            'paging': false,\
            'info': false\
        });\
    });\
     </script>\
     <link href='http://cdn.datatables.net/1.10.7/css/jquery.dataTables.css' rel='stylesheet'>\
     <style type='text/css'>\
     td {\
         max-width: 400px;\
         word-wrap:break-word;\
     }\
     </style>\
     </head>\
     <body><h1>%@</h1>\
     <div>\
     <table id='resultTb' class='display cell-border' cellspacing='0' width=100%%> \
     <thead>\
     <tr>\
     ", self.tableView.window.title];
    for (NSTableColumn *col in cols) {
        [data appendFormat:@"<th>%@</th>", [self stringByEncodingXMLEntities:[col.headerCell title]]];
    }
    [data appendString:@"</tr></thead><tbody>"];
    for (int i = 0; i < rowCount; i++) {
        [data appendString:@"<tr>"];
        for (NSTableColumn *col in cols) {
            id cell = [self.tableView.dataSource tableView:self.tableView objectValueForTableColumn:col row:i];
            [data appendFormat:@"<td>%@</td>", [self stringByEncodingXMLEntities:(cell ? [cell description] : @"")]];
        }
        [data appendString:@"</tr>"];
    }
    [data appendString:@"</tbody></table></div></body></html>"];
    return [data copy];
}

- (void)saveFile:(NSString *)suffix withData:(NSString *)data
{
    NSSavePanel *panel = [NSSavePanel savePanel];
    [panel setNameFieldStringValue:@"export"];
    [panel setMessage:@"Choose the path to save"];
    [panel setAllowsOtherFileTypes:NO];
    [panel setAllowedFileTypes:@[suffix]];
    [panel setExtensionHidden:NO];
    [panel setCanCreateDirectories:YES];
    [panel beginSheetModalForWindow:self.tableView.window completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSString *path = [[panel URL] path];
            [data writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
        }
    }];
}

- (void)onMenuClick:(NSMenuItem *)sender
{
    NSLog(@"click: %ld", sender.tag);
    switch (sender.tag) {
        case OpExportCsv: {
            NSString *data = [self genCsv:@";"];
            [self saveFile:@"csv" withData:data];

        }
        case OpExprotWindowsCsv: {
            NSString *data = [self genCsv:@","];
            [self saveFile:@"csv" withData:data];
        };

            break;
        case OpExportHtml: {
            NSString *data = [self genHtml];
            [self saveFile:@"html" withData:data];
        }
            break;
        case OpViewHtml: {
            NSString *data = [self genHtml];
//            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//            NSString *documentsDirectory = [paths objectAtIndex:0];
//            NSString *path = [documentsDirectory stringByAppendingPathComponent:@"export.html"];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyyMMdd-HHmmss"];
            NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@",[dateFormatter stringFromDate:[NSDate date]],@"export.html"]];
            [data writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
            [[NSWorkspace sharedWorkspace] openURL:[NSURL fileURLWithPath:path]];
        }
            break;

        default:
            break;
    }
}
@end
