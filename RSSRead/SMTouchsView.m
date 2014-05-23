//
//  SMTouchsView.m
//  RSSRead
//
//  Created by ftxbird on 14-5-23.
//  Copyright (c) 2014年 starming. All rights reserved.
//

#import "SMTouchsView.h"

@implementation SMTouchsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    CGPoint location = [[[event allTouches] anyObject] locationInView:self.window];
    if(location.y > 0 && location.y < 100&&location.x<60) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"touchCloseBtnClick" object:nil];

        
    }
}



@end
