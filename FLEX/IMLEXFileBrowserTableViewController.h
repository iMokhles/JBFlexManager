//
//  IMLEXFileBrowserTableViewController.h
//  Flipboard
//
//  Created by Ryan Olson on 6/9/14.
//  Based on previous work by Evan Doll
//

#import "IMLEXTableViewController.h"
#import "IMLEXGlobalsEntry.h"
#import "IMLEXFileBrowserSearchOperation.h"

@interface IMLEXFileBrowserTableViewController : IMLEXTableViewController <IMLEXGlobalsEntry>

+ (instancetype)path:(NSString *)path;
- (id)initWithPath:(NSString *)path;

@end
