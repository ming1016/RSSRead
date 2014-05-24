//
//  SMShareViewController.m
//  RSSRead
//
//  Created by ftxbird on 14-5-23.
//  Copyright (c) 2014年 starming. All rights reserved.
//

#import "SMShareViewController.h"
#import "SMAppDelegate.h"
#import "EvernoteSession.h"
#import "EvernoteUserStore.h"
#import "ENMLUtility.h"
#import "ENAPI.h"
#import "EvernoteNoteStore.h"

@interface SMShareViewController ()

@end

@implementation SMShareViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.view.frame =[UIScreen mainScreen].bounds;
        self.view.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

/**
 *  OAUTH授权
 *
 *  @param EvernoteSession * session
 */

- (void)oauthUSingSession
{
    EvernoteSession *session = [EvernoteSession sharedSession];
    [session authenticateWithViewController:self completionHandler:^(NSError *error) {
        if (error || !session.isAuthenticated){
            if (error) {
                NSLog(@"Error authenticating with Evernote Cloud API: %@", error);
            }
            if (!session.isAuthenticated) {
                NSLog(@"Session not authenticated");
            }
        } else {
            // 授权成功!
            EvernoteUserStore *userStore = [EvernoteUserStore userStore];
            [userStore getUserWithSuccess:^(EDAMUser *user) {
                // 获取用户信息
                NSLog(@"Authenticated as %@", [user username]);
            } failure:^(NSError *error) {
                // failure
                NSLog(@"Error getting user: %@", error);
            } ];
        }
    }];
}
/**
 *  创建印象笔记  (如果已经授权 可直接调用该方法发送笔记)
 *
 *  @param noteTile       笔记标题
 *  @param noteBody       笔记内容
 *  @param resources      笔记附件
 *  @param parentNotebook 笔记本信息(指定存储笔记本)
 */
- (void)makeNoteWithTitle:(NSString*)noteTile withBody:(NSString*) noteBody withResources:(NSMutableArray*)resources withParentBotebook:(EDAMNotebook*)parentNotebook {
    
    EvernoteSession *session = [EvernoteSession sharedSession];
    if(!session.isAuthenticated)
    {
        [self oauthUSingSession];
    }
    
    NSString *noteContent = [NSString stringWithFormat:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                             "<!DOCTYPE en-note SYSTEM \"http://xml.evernote.com/pub/enml2.dtd\">"
                             "<en-note>"
                             "%@",noteBody];
    
    // Add resource objects to note body
    if(resources.count > 0) {
        noteContent = [noteContent stringByAppendingString:
                       @"<br />"];
    }
    // Include ENMLUtility.h .
    for (EDAMResource* resource in resources) {
        noteContent = [noteContent stringByAppendingFormat:@"Attachment : <br /> %@",
                       [ENMLUtility mediaTagWithDataHash:resource.data.bodyHash
                                                    mime:resource.mime]];
    }
    
    noteContent = [noteContent stringByAppendingString:@"</en-note>"];
    
    // Parent notebook is optional; if omitted, default notebook is used
    NSString* parentNotebookGUID;
    if(parentNotebook) {
        parentNotebookGUID = parentNotebook.guid;
    }
    
    //  创建笔记对象
    EDAMNote *ourNote = [[EDAMNote alloc] initWithGuid:nil title:noteTile content:noteContent contentHash:nil contentLength:noteContent.length created:0 updated:0 deleted:0 active:YES updateSequenceNum:0 notebookGuid:parentNotebookGUID tagGuids:nil resources:resources attributes:nil tagNames:nil];
    //EvernoteNoteStore *notestore= [EvernoteNoteStore noteStore];
   // NSLog(@"%@",notestore);
    
    // 将笔记对象传入指定账户中
    [[EvernoteNoteStore noteStore] createNote:ourNote success:^(EDAMNote *note) {
        // Log the created note object
        NSLog(@"Note created : %@",note);
    } failure:^(NSError *error) {
        // Something was wrong with the note data
        // See EDAMErrorCode enumeration for error code explanation
        // http://dev.evernote.com/documentation/reference/Errors.html#Enum_EDAMErrorCode
        NSLog(@"Error : %@",error);
    }];
}



@end
