//
//  SMDetailViewController.m
//  RSSRead
//
//  Created by ming on 14-3-21.
//  Copyright (c) 2014年 starming. All rights reserved.
//

#import "SMDetailViewController.h"
#import "SMDetailViewBottomBar.h"
#import "SMUIKitHelper.h"
#import "SMRSSModel.h"
#import "SMPreferences.h"
#import <ViewUtils.h>
#import "SMShareViewController.h"
#import "SMAppDelegate.h"
#import "EvernoteSession.h"
#import "EvernoteUserStore.h"
#import "ENMLUtility.h"
#import "ENAPI.h"
#import "EvernoteNoteStore.h"
#import "EvernoteNoteStore+Extras.h"

@interface SMDetailViewController ()<SMDetailViewBottomBarDelegate,ENSessionDelegate>

@property(nonatomic,strong)NSString *showContent;
@property(nonatomic,strong)SMRSSModel *rssModel;
@property(nonatomic,strong)UIWebView *webView;
@property(nonatomic,strong)SMDetailViewBottomBar *bottomBar;
@property(nonatomic,strong)UIView *statusBarBackView;

@end

@implementation SMDetailViewController

-(void)doBack {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)loadView {
    [super loadView];
    
    _bottomBar = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([SMDetailViewBottomBar class]) owner:nil options:nil] lastObject];
    _bottomBar.delegate = self;
    _bottomBar.bottom = self.view.bounds.size.height;
    _bottomBar.width = self.view.bounds.size.width;
    _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    _webView.height -= _bottomBar.height;
    [_webView setBackgroundColor:[UIColor yellowColor]];
    _webView.scalesPageToFit = YES;
    _webView.scrollView.directionalLockEnabled = YES;
    _webView.scrollView.showsHorizontalScrollIndicator = NO;
    [_webView setOpaque:NO]; // 默认是透明的
    [self.view addSubview:_webView];
    [self.view addSubview:_bottomBar];

    _statusBarBackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, STATUS_BAR_HEIGHT)];
//    [self.view addSubview:_statusBarBackView];
    [self setupStatusBar];

}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _rssModel = [[SMRSSModel alloc]init];

    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    self.title = _rss.title;
    [self renderDetailViewFromRSS];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //手势返回
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(doBack)];
    recognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:recognizer];
    // Do any additional setup after loading the view.
}

-(void)renderDetailViewFromRSS {
    
    _showContent = _rss.content;
    if ([_rss.content isEqualToString:@"无内容"]) {
        _showContent = _rss.summary;
    }
    [self loadHTML];
    
    [_rssModel markAsRead:_rss];
    [_bottomBar fillWithRSS:_rss];
}

- (void)setupStatusBar
{
    
    if([[SMPreferences sharedInstance] theme] == eAppThemeBlack) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        [_statusBarBackView setBackgroundColor:[UIColor colorFromRGB:0x252525]];
        [_webView setBackgroundColor:[UIColor colorFromRGB:0x252525]];
    } else {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        [_statusBarBackView setBackgroundColor:[UIColor whiteColor]];
        [_webView setBackgroundColor:[UIColor whiteColor]];
    }

}

- (void)loadHTML
{
//    NSString *filePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"js.html"];
    NSString *cssFilePath;
    
    if([[SMPreferences sharedInstance] theme] == eAppThemeBlack) {
        // 黑色
        cssFilePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"css_dark.html"];
    } else {
        // 白色
        cssFilePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"css.html"];
    }
    
    NSError *err=nil;
//    NSString *mTxt=[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&err];
    NSString *mTxt= @"";
    NSString *cssString=[NSString stringWithContentsOfFile:cssFilePath encoding:NSUTF8StringEncoding error:&err];
    
    NSDateFormatter *formatter;
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM.dd HH:mm"];
    NSString *publishDate = [formatter stringFromDate:_rss.date];
    NSString *htmlStr = [NSString stringWithFormat:@"<!DOCTYPE html><html lang=\"zh-CN\"><head><meta charset=\"utf-8\"><meta http-equiv=\"X-UA-Compatible\" content=\"IE=edge\"><meta name=\"viewport\" content=\"width=device-width initial-scale=1.0\">%@</head><body><a class=\"title\" href=\"%@\">%@</a>\
                         <div class=\"diver\"></div><p style=\"text-align:left;font-size:9pt;margin-left: 14px;margin-top: 10px;margin-bottom: 10px;color:#CCCCCC\">%@ 发表于 %@</p><div class=\"content\">%@</div>%@</body></html>", cssString, _rss.link, _rss.title, _rss.author, publishDate, _showContent, mTxt];
    [_webView loadHTMLString:htmlStr baseURL:nil];
    
}

-(void)favRSS {
    _rss.isFav = @1;
    [_bottomBar fillWithRSS:_rss];
    [_rssModel favRSS:_rss];
    [self.delegate faved];
}

-(void)unFavRSS {
    [_rssModel unFavRSS:_rss];
    _rss.isFav = @0;
    [_bottomBar fillWithRSS:_rss];
    [self.delegate unFav];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SMDetailViewBottomBarDelegate

- (void)bottomBarBackButtonTouched:(id)sender;
{
    [self doBack];
}

- (void)bottomBarFavButtonTouched:(id)sender;
{
    if ([_rss.isFav isEqual:@1]) {
        [self unFavRSS];
    } else {
        [self favRSS];
    }
}

- (void)bottomBarThemeButtonTouched:(id)sender
{
    [self loadHTML];
    [self setupStatusBar];
}

- (void)bottomBarShareButtonTouched:(id)sender
{
    //SMShareViewController *share = [[SMShareViewController alloc] init];
   // [self presentViewController:share animated:YES completion:nil];
    //
//    EvernoteSession *session = [EvernoteSession sharedSession];
//    NSString * defaultStr = @"<RSSRead>";
//    NSString * title = [defaultStr stringByAppendingString:_rss.title];
//    NSString * content = _showContent;
//    if(!session.isAuthenticated)
//    {
//        [self oauthWithTile:title andContent:content];
//    }
//    else
//    {
//        [self makeNoteWithTitle:title withBody:content withResources:nil    withParentBotebook:nil];
//    }
    
    NSURL *url = [[NSURL alloc]initWithString:_rss.link];
    NSMutableArray *ar = [[NSMutableArray alloc]initWithCapacity:2];
    NSString *title = [NSString stringWithFormat:@"<已阅>%@",_rss.title];
    [ar addObject:title];
    [ar addObject:url];
    UIActivityViewController *act = [[UIActivityViewController alloc]initWithActivityItems:ar applicationActivities:nil];
    [self.navigationController presentViewController:act animated:true completion:nil];
}


- (void)oauthWithTile:(NSString *)title andContent:(NSString *)content
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
                // 获取用户信息  这里可以作发送笔记
                [self makeNoteWithTitle:title withBody:content withResources:nil    withParentBotebook:nil];
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
    [[EvernoteSession sharedSession] setDelegate:self];
    //该方法需要key激活,否则app 会出现同步失败情况.
    [[EvernoteNoteStore noteStore] saveNewNoteToEvernoteApp:ourNote withType:@"text/html"];
    // 将笔记对象传入指定账户中
//    [[EvernoteNoteStore noteStore] createNote:ourNote success:^(EDAMNote *note) {
//        // Log the created note object
//        NSLog(@"Note created : %@",note);
//        //按钮取消点击 并提示用户成功保存
//    } failure:^(NSError *error) {
//        // Something was wrong with the note data
//        // See EDAMErrorCode enumeration for error code explanation
//        // http://dev.evernote.com/documentation/reference/Errors.html#Enum_EDAMErrorCode
//        NSLog(@"Error : %@",error);
//    }];
}


@end
