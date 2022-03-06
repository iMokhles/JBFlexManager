//
//  IMLEXNetworkTransactionDetailTableViewController.m
//  Flipboard
//
//  Created by Ryan Olson on 2/10/15.
//  Copyright (c) 2020 Flipboard. All rights reserved.
//

#import "IMLEXColor.h"
#import "IMLEXNetworkTransactionDetailTableViewController.h"
#import "IMLEXNetworkCurlLogger.h"
#import "IMLEXNetworkRecorder.h"
#import "IMLEXNetworkTransaction.h"
#import "IMLEXWebViewController.h"
#import "IMLEXImagePreviewViewController.h"
#import "IMLEXMultilineTableViewCell.h"
#import "IMLEXUtility.h"
#import "IMLEXManager+Private.h"
#import "IMLEXTableView.h"
#import "UIBarButtonItem+IMLEX.h"

typedef UIViewController *(^IMLEXNetworkDetailRowSelectionFuture)(void);

@interface IMLEXNetworkDetailRow : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *detailText;
@property (nonatomic, copy) IMLEXNetworkDetailRowSelectionFuture selectionFuture;

@end

@implementation IMLEXNetworkDetailRow

@end

@interface IMLEXNetworkDetailSection : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSArray<IMLEXNetworkDetailRow *> *rows;

@end

@implementation IMLEXNetworkDetailSection

@end

@interface IMLEXNetworkTransactionDetailTableViewController ()

@property (nonatomic, copy) NSArray<IMLEXNetworkDetailSection *> *sections;

@end

@implementation IMLEXNetworkTransactionDetailTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style {
    // Force grouped style
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        [NSNotificationCenter.defaultCenter addObserver:self
            selector:@selector(handleTransactionUpdatedNotification:)
            name:kIMLEXNetworkRecorderTransactionUpdatedNotification
            object:nil
        ];
        self.toolbarItems = @[
            UIBarButtonItem.IMLEX_IMLEXibleSpace,
            [UIBarButtonItem
                itemWithTitle:@"Copy curl" target:self action:@selector(copyButtonPressed:)
            ]
        ];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.tableView registerClass:[IMLEXMultilineTableViewCell class] forCellReuseIdentifier:kIMLEXMultilineCell];
}

- (void)setTransaction:(IMLEXNetworkTransaction *)transaction {
    if (![_transaction isEqual:transaction]) {
        _transaction = transaction;
        self.title = [transaction.request.URL lastPathComponent];
        [self rebuildTableSections];
    }
}

- (void)setSections:(NSArray<IMLEXNetworkDetailSection *> *)sections {
    if (![_sections isEqual:sections]) {
        _sections = [sections copy];
        [self.tableView reloadData];
    }
}

- (void)rebuildTableSections {
    NSMutableArray<IMLEXNetworkDetailSection *> *sections = [NSMutableArray new];

    IMLEXNetworkDetailSection *generalSection = [[self class] generalSectionForTransaction:self.transaction];
    if (generalSection.rows.count > 0) {
        [sections addObject:generalSection];
    }
    IMLEXNetworkDetailSection *requestHeadersSection = [[self class] requestHeadersSectionForTransaction:self.transaction];
    if (requestHeadersSection.rows.count > 0) {
        [sections addObject:requestHeadersSection];
    }
    IMLEXNetworkDetailSection *queryParametersSection = [[self class] queryParametersSectionForTransaction:self.transaction];
    if (queryParametersSection.rows.count > 0) {
        [sections addObject:queryParametersSection];
    }
    IMLEXNetworkDetailSection *postBodySection = [[self class] postBodySectionForTransaction:self.transaction];
    if (postBodySection.rows.count > 0) {
        [sections addObject:postBodySection];
    }
    IMLEXNetworkDetailSection *responseHeadersSection = [[self class] responseHeadersSectionForTransaction:self.transaction];
    if (responseHeadersSection.rows.count > 0) {
        [sections addObject:responseHeadersSection];
    }

    self.sections = sections;
}

- (void)handleTransactionUpdatedNotification:(NSNotification *)notification {
    IMLEXNetworkTransaction *transaction = [[notification userInfo] objectForKey:kIMLEXNetworkRecorderUserInfoTransactionKey];
    if (transaction == self.transaction) {
        [self rebuildTableSections];
    }
}

- (void)copyButtonPressed:(id)sender {
    [UIPasteboard.generalPasteboard setString:[IMLEXNetworkCurlLogger curlCommandString:_transaction.request]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    IMLEXNetworkDetailSection *sectionModel = self.sections[section];
    return sectionModel.rows.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    IMLEXNetworkDetailSection *sectionModel = self.sections[section];
    return sectionModel.title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    IMLEXMultilineTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kIMLEXMultilineCell forIndexPath:indexPath];

    IMLEXNetworkDetailRow *rowModel = [self rowModelAtIndexPath:indexPath];

    cell.textLabel.attributedText = [[self class] attributedTextForRow:rowModel];
    cell.accessoryType = rowModel.selectionFuture ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
    cell.selectionStyle = rowModel.selectionFuture ? UITableViewCellSelectionStyleDefault : UITableViewCellSelectionStyleNone;

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    IMLEXNetworkDetailRow *rowModel = [self rowModelAtIndexPath:indexPath];

    UIViewController *viewController = nil;
    if (rowModel.selectionFuture) {
        viewController = rowModel.selectionFuture();
    }

    if ([viewController isKindOfClass:UIAlertController.class]) {
        [self presentViewController:viewController animated:YES completion:nil];
    } else if (viewController) {
        [self.navigationController pushViewController:viewController animated:YES];
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    IMLEXNetworkDetailRow *row = [self rowModelAtIndexPath:indexPath];
    NSAttributedString *attributedText = [[self class] attributedTextForRow:row];
    BOOL showsAccessory = row.selectionFuture != nil;
    return [IMLEXMultilineTableViewCell
        preferredHeightWithAttributedText:attributedText
        maxWidth:tableView.bounds.size.width
        style:tableView.style
        showsAccessory:showsAccessory
    ];
}

- (IMLEXNetworkDetailRow *)rowModelAtIndexPath:(NSIndexPath *)indexPath {
    IMLEXNetworkDetailSection *sectionModel = self.sections[indexPath.section];
    return sectionModel.rows[indexPath.row];
}

#pragma mark - Cell Copying

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    return action == @selector(copy:);
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    if (action == @selector(copy:)) {
        IMLEXNetworkDetailRow *row = [self rowModelAtIndexPath:indexPath];
        UIPasteboard.generalPasteboard.string = row.detailText;
    }
}

#if IMLEX_AT_LEAST_IOS13_SDK

- (UIContextMenuConfiguration *)tableView:(UITableView *)tableView contextMenuConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath point:(CGPoint)point __IOS_AVAILABLE(13.0) {
    return [UIContextMenuConfiguration
        configurationWithIdentifier:nil
        previewProvider:nil
        actionProvider:^UIMenu *(NSArray<UIMenuElement *> *suggestedActions) {
            UIAction *copy = [UIAction
                actionWithTitle:@"Copy"
                image:nil
                identifier:nil
                handler:^(__kindof UIAction *action) {
                    IMLEXNetworkDetailRow *row = [self rowModelAtIndexPath:indexPath];
                    UIPasteboard.generalPasteboard.string = row.detailText;
                }
            ];
            return [UIMenu
                menuWithTitle:@"" image:nil identifier:nil
                options:UIMenuOptionsDisplayInline
                children:@[copy]
            ];
        }
    ];
}

#endif

#pragma mark - View Configuration

+ (NSAttributedString *)attributedTextForRow:(IMLEXNetworkDetailRow *)row {
    NSDictionary<NSString *, id> *titleAttributes = @{ NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-Medium" size:12.0],
                                                       NSForegroundColorAttributeName : [UIColor colorWithWhite:0.5 alpha:1.0] };
    NSDictionary<NSString *, id> *detailAttributes = @{ NSFontAttributeName : UIFont.IMLEX_defaultTableCellFont,
                                                        NSForegroundColorAttributeName : IMLEXColor.primaryTextColor };

    NSString *title = [NSString stringWithFormat:@"%@: ", row.title];
    NSString *detailText = row.detailText ?: @"";
    NSMutableAttributedString *attributedText = [NSMutableAttributedString new];
    [attributedText appendAttributedString:[[NSAttributedString alloc] initWithString:title attributes:titleAttributes]];
    [attributedText appendAttributedString:[[NSAttributedString alloc] initWithString:detailText attributes:detailAttributes]];

    return attributedText;
}

#pragma mark - Table Data Generation

+ (IMLEXNetworkDetailSection *)generalSectionForTransaction:(IMLEXNetworkTransaction *)transaction {
    NSMutableArray<IMLEXNetworkDetailRow *> *rows = [NSMutableArray new];

    IMLEXNetworkDetailRow *requestURLRow = [IMLEXNetworkDetailRow new];
    requestURLRow.title = @"Request URL";
    NSURL *url = transaction.request.URL;
    requestURLRow.detailText = url.absoluteString;
    requestURLRow.selectionFuture = ^{
        UIViewController *urlWebViewController = [[IMLEXWebViewController alloc] initWithURL:url];
        urlWebViewController.title = url.absoluteString;
        return urlWebViewController;
    };
    [rows addObject:requestURLRow];

    IMLEXNetworkDetailRow *requestMethodRow = [IMLEXNetworkDetailRow new];
    requestMethodRow.title = @"Request Method";
    requestMethodRow.detailText = transaction.request.HTTPMethod;
    [rows addObject:requestMethodRow];

    if (transaction.cachedRequestBody.length > 0) {
        IMLEXNetworkDetailRow *postBodySizeRow = [IMLEXNetworkDetailRow new];
        postBodySizeRow.title = @"Request Body Size";
        postBodySizeRow.detailText = [NSByteCountFormatter stringFromByteCount:transaction.cachedRequestBody.length countStyle:NSByteCountFormatterCountStyleBinary];
        [rows addObject:postBodySizeRow];

        IMLEXNetworkDetailRow *postBodyRow = [IMLEXNetworkDetailRow new];
        postBodyRow.title = @"Request Body";
        postBodyRow.detailText = @"tap to view";
        postBodyRow.selectionFuture = ^UIViewController * () {
            // Show the body if we can
            NSString *contentType = [transaction.request valueForHTTPHeaderField:@"Content-Type"];
            UIViewController *detailViewController = [self detailViewControllerForMIMEType:contentType data:[self postBodyDataForTransaction:transaction]];
            if (detailViewController) {
                detailViewController.title = @"Request Body";
                return detailViewController;
            }

            // We can't show the body, alert user
            return [IMLEXAlert makeAlert:^(IMLEXAlert *make) {
                make.title(@"Can't View HTTP Body Data");
                make.message(@"IMLEX does not have a viewer for request body data with MIME type: ");
                make.message(contentType);
                make.button(@"Dismiss").cancelStyle();
            }];
        };

        [rows addObject:postBodyRow];
    }

    NSString *statusCodeString = [IMLEXUtility statusCodeStringFromURLResponse:transaction.response];
    if (statusCodeString.length > 0) {
        IMLEXNetworkDetailRow *statusCodeRow = [IMLEXNetworkDetailRow new];
        statusCodeRow.title = @"Status Code";
        statusCodeRow.detailText = statusCodeString;
        [rows addObject:statusCodeRow];
    }

    if (transaction.error) {
        IMLEXNetworkDetailRow *errorRow = [IMLEXNetworkDetailRow new];
        errorRow.title = @"Error";
        errorRow.detailText = transaction.error.localizedDescription;
        [rows addObject:errorRow];
    }

    IMLEXNetworkDetailRow *responseBodyRow = [IMLEXNetworkDetailRow new];
    responseBodyRow.title = @"Response Body";
    NSData *responseData = [IMLEXNetworkRecorder.defaultRecorder cachedResponseBodyForTransaction:transaction];
    if (responseData.length > 0) {
        responseBodyRow.detailText = @"tap to view";

        // Avoid a long lived strong reference to the response data in case we need to purge it from the cache.
        __weak NSData *weakResponseData = responseData;
        responseBodyRow.selectionFuture = ^UIViewController * () {

            // Show the response if we can
            NSString *contentType = transaction.response.MIMEType;
            NSData *strongResponseData = weakResponseData;
            if (strongResponseData) {
                UIViewController *bodyDetailController = [self detailViewControllerForMIMEType:contentType data:strongResponseData];
                if (bodyDetailController) {
                    bodyDetailController.title = @"Response";
                    return bodyDetailController;
                }
            }

            // We can't show the response, alert user
            return [IMLEXAlert makeAlert:^(IMLEXAlert *make) {
                make.title(@"Unable to View Response");
                if (strongResponseData) {
                    make.message(@"No viewer content type: ").message(contentType);
                } else {
                    make.message(@"The response has been purged from the cache");
                }
                make.button(@"OK").cancelStyle();
            }];
        };
    } else {
        BOOL emptyResponse = transaction.receivedDataLength == 0;
        responseBodyRow.detailText = emptyResponse ? @"empty" : @"not in cache";
    }

    [rows addObject:responseBodyRow];

    IMLEXNetworkDetailRow *responseSizeRow = [IMLEXNetworkDetailRow new];
    responseSizeRow.title = @"Response Size";
    responseSizeRow.detailText = [NSByteCountFormatter stringFromByteCount:transaction.receivedDataLength countStyle:NSByteCountFormatterCountStyleBinary];
    [rows addObject:responseSizeRow];

    IMLEXNetworkDetailRow *mimeTypeRow = [IMLEXNetworkDetailRow new];
    mimeTypeRow.title = @"MIME Type";
    mimeTypeRow.detailText = transaction.response.MIMEType;
    [rows addObject:mimeTypeRow];

    IMLEXNetworkDetailRow *mechanismRow = [IMLEXNetworkDetailRow new];
    mechanismRow.title = @"Mechanism";
    mechanismRow.detailText = transaction.requestMechanism;
    [rows addObject:mechanismRow];

    NSDateFormatter *startTimeFormatter = [NSDateFormatter new];
    startTimeFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";

    IMLEXNetworkDetailRow *localStartTimeRow = [IMLEXNetworkDetailRow new];
    localStartTimeRow.title = [NSString stringWithFormat:@"Start Time (%@)", [NSTimeZone.localTimeZone abbreviationForDate:transaction.startTime]];
    localStartTimeRow.detailText = [startTimeFormatter stringFromDate:transaction.startTime];
    [rows addObject:localStartTimeRow];

    startTimeFormatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];

    IMLEXNetworkDetailRow *utcStartTimeRow = [IMLEXNetworkDetailRow new];
    utcStartTimeRow.title = @"Start Time (UTC)";
    utcStartTimeRow.detailText = [startTimeFormatter stringFromDate:transaction.startTime];
    [rows addObject:utcStartTimeRow];

    IMLEXNetworkDetailRow *unixStartTime = [IMLEXNetworkDetailRow new];
    unixStartTime.title = @"Unix Start Time";
    unixStartTime.detailText = [NSString stringWithFormat:@"%f", [transaction.startTime timeIntervalSince1970]];
    [rows addObject:unixStartTime];

    IMLEXNetworkDetailRow *durationRow = [IMLEXNetworkDetailRow new];
    durationRow.title = @"Total Duration";
    durationRow.detailText = [IMLEXUtility stringFromRequestDuration:transaction.duration];
    [rows addObject:durationRow];

    IMLEXNetworkDetailRow *latencyRow = [IMLEXNetworkDetailRow new];
    latencyRow.title = @"Latency";
    latencyRow.detailText = [IMLEXUtility stringFromRequestDuration:transaction.latency];
    [rows addObject:latencyRow];

    IMLEXNetworkDetailSection *generalSection = [IMLEXNetworkDetailSection new];
    generalSection.title = @"General";
    generalSection.rows = rows;

    return generalSection;
}

+ (IMLEXNetworkDetailSection *)requestHeadersSectionForTransaction:(IMLEXNetworkTransaction *)transaction {
    IMLEXNetworkDetailSection *requestHeadersSection = [IMLEXNetworkDetailSection new];
    requestHeadersSection.title = @"Request Headers";
    requestHeadersSection.rows = [self networkDetailRowsFromDictionary:transaction.request.allHTTPHeaderFields];

    return requestHeadersSection;
}

+ (IMLEXNetworkDetailSection *)postBodySectionForTransaction:(IMLEXNetworkTransaction *)transaction {
    IMLEXNetworkDetailSection *postBodySection = [IMLEXNetworkDetailSection new];
    postBodySection.title = @"Request Body Parameters";
    if (transaction.cachedRequestBody.length > 0) {
        NSString *contentType = [transaction.request valueForHTTPHeaderField:@"Content-Type"];
        if ([contentType hasPrefix:@"application/x-www-form-urlencoded"]) {
            NSString *bodyString = [NSString stringWithCString:[self postBodyDataForTransaction:transaction].bytes encoding:NSUTF8StringEncoding];
            postBodySection.rows = [self networkDetailRowsFromQueryItems:[IMLEXUtility itemsFromQueryString:bodyString]];
        }
    }
    return postBodySection;
}

+ (IMLEXNetworkDetailSection *)queryParametersSectionForTransaction:(IMLEXNetworkTransaction *)transaction {
    NSArray<NSURLQueryItem *> *queries = [IMLEXUtility itemsFromQueryString:transaction.request.URL.query];
    IMLEXNetworkDetailSection *querySection = [IMLEXNetworkDetailSection new];
    querySection.title = @"Query Parameters";
    querySection.rows = [self networkDetailRowsFromQueryItems:queries];

    return querySection;
}

+ (IMLEXNetworkDetailSection *)responseHeadersSectionForTransaction:(IMLEXNetworkTransaction *)transaction {
    IMLEXNetworkDetailSection *responseHeadersSection = [IMLEXNetworkDetailSection new];
    responseHeadersSection.title = @"Response Headers";
    if ([transaction.response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)transaction.response;
        responseHeadersSection.rows = [self networkDetailRowsFromDictionary:httpResponse.allHeaderFields];
    }
    return responseHeadersSection;
}

+ (NSArray<IMLEXNetworkDetailRow *> *)networkDetailRowsFromDictionary:(NSDictionary<NSString *, id> *)dictionary {
    NSMutableArray<IMLEXNetworkDetailRow *> *rows = [NSMutableArray new];
    NSArray<NSString *> *sortedKeys = [dictionary.allKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    
    for (NSString *key in sortedKeys) {
        id value = dictionary[key];
        IMLEXNetworkDetailRow *row = [IMLEXNetworkDetailRow new];
        row.title = key;
        row.detailText = [value description];
        [rows addObject:row];
    }

    return rows.copy;
}

+ (NSArray<IMLEXNetworkDetailRow *> *)networkDetailRowsFromQueryItems:(NSArray<NSURLQueryItem *> *)items {
    // Sort the items by name
    items = [items sortedArrayUsingComparator:^NSComparisonResult(NSURLQueryItem *item1, NSURLQueryItem *item2) {
        return [item1.name caseInsensitiveCompare:item2.name];
    }];

    NSMutableArray<IMLEXNetworkDetailRow *> *rows = [NSMutableArray new];
    for (NSURLQueryItem *item in items) {
        IMLEXNetworkDetailRow *row = [IMLEXNetworkDetailRow new];
        row.title = item.name;
        row.detailText = item.value;
        [rows addObject:row];
    }

    return [rows copy];
}

+ (UIViewController *)detailViewControllerForMIMEType:(NSString *)mimeType data:(NSData *)data {
    IMLEXCustomContentViewerFuture makeCustomViewer = IMLEXManager.sharedManager.customContentTypeViewers[mimeType.lowercaseString];

    if (makeCustomViewer) {
        UIViewController *viewer = makeCustomViewer(data);

        if (viewer) {
            return viewer;
        }
    }

    // FIXME (RKO): Don't rely on UTF8 string encoding
    UIViewController *detailViewController = nil;
    if ([IMLEXUtility isValidJSONData:data]) {
        NSString *prettyJSON = [IMLEXUtility prettyJSONStringFromData:data];
        if (prettyJSON.length > 0) {
            detailViewController = [[IMLEXWebViewController alloc] initWithText:prettyJSON];
        }
    } else if ([mimeType hasPrefix:@"image/"]) {
        UIImage *image = [UIImage imageWithData:data];
        detailViewController = [IMLEXImagePreviewViewController forImage:image];
    } else if ([mimeType isEqual:@"application/x-plist"]) {
        id propertyList = [NSPropertyListSerialization propertyListWithData:data options:0 format:NULL error:NULL];
        detailViewController = [[IMLEXWebViewController alloc] initWithText:[propertyList description]];
    }

    // Fall back to trying to show the response as text
    if (!detailViewController) {
        NSString *text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (text.length > 0) {
            detailViewController = [[IMLEXWebViewController alloc] initWithText:text];
        }
    }
    return detailViewController;
}

+ (NSData *)postBodyDataForTransaction:(IMLEXNetworkTransaction *)transaction {
    NSData *bodyData = transaction.cachedRequestBody;
    if (bodyData.length > 0) {
        NSString *contentEncoding = [transaction.request valueForHTTPHeaderField:@"Content-Encoding"];
        if ([contentEncoding rangeOfString:@"deflate" options:NSCaseInsensitiveSearch].length > 0 || [contentEncoding rangeOfString:@"gzip" options:NSCaseInsensitiveSearch].length > 0) {
            bodyData = [IMLEXUtility inflatedDataFromCompressedData:bodyData];
        }
    }
    return bodyData;
}

@end
