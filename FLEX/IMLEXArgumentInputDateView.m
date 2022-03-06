//
//  IMLEXArgumentInputDataView.m
//  Flipboard
//
//  Created by Daniel Rodriguez Troitino on 2/14/15.
//  Copyright (c) 2020 Flipboard. All rights reserved.
//

#import "IMLEXArgumentInputDateView.h"
#import "IMLEXRuntimeUtility.h"

@interface IMLEXArgumentInputDateView ()

@property (nonatomic) UIDatePicker *datePicker;

@end

@implementation IMLEXArgumentInputDateView

- (instancetype)initWithArgumentTypeEncoding:(const char *)typeEncoding {
    self = [super initWithArgumentTypeEncoding:typeEncoding];
    if (self) {
        self.datePicker = [UIDatePicker new];
        self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
        // Using UTC, because that's what the NSDate description prints
        self.datePicker.calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
        self.datePicker.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
        [self addSubview:self.datePicker];
    }
    return self;
}

- (void)setInputValue:(id)inputValue {
    if ([inputValue isKindOfClass:[NSDate class]]) {
        self.datePicker.date = inputValue;
    }
}

- (id)inputValue {
    return self.datePicker.date;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.datePicker.frame = self.bounds;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat height = [self.datePicker sizeThatFits:size].height;
    return CGSizeMake(size.width, height);
}

+ (BOOL)supportsObjCType:(const char *)type withCurrentValue:(id)value {
    NSParameterAssert(type);
    return strcmp(type, IMLEXEncodeClass(NSDate)) == 0;
}

@end
