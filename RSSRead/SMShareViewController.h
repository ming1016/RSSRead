//
//  SMShareViewController.h
//  RSSRead
//
//  Created by ftxbird on 14-5-23.
//  Copyright (c) 2014年 starming. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SMShareEveryNoteDelegate <NSObject>

/**
 *  分享文章到印象笔记
 *  share article to Evernote
 *
 *  @param html content
 */
- (void)ShareEveryNoteTitle:(NSString *)title Content:(NSString *)content;

@end
@interface SMShareViewController : UIViewController

@property(nonatomic ,weak) id <SMShareEveryNoteDelegate> delegate;
@end
