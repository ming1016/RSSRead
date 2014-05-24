//
//  SMShareViewController.h
//  RSSRead
//
//  Created by ftxbird on 14-5-23.
//  Copyright (c) 2014年 starming. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SMShareViewController;
@class EDAMNotebook;


@interface SMShareViewController : UIViewController
/**
 *  分享文章到印象笔记
 *  share article to Evernote
 */
-(void)makeNoteWithTitle:(NSString*)noteTile withBody:(NSString*) noteBody withResources:(NSMutableArray*)resources withParentBotebook:(EDAMNotebook*)parentNotebook;
@end
