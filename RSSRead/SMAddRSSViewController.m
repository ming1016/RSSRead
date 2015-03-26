//
//  SMAddRSSViewController.m
//  RSSRead
//
//  Created by ming on 14-3-18.
//  Copyright (c) 2014年 starming. All rights reserved.
//

#import "SMAddRSSViewController.h"
#import "SMUIKitHelper.h"
#import "SMAppDelegate.h"
#import "RSS.h"
#import "SMRSSModel.h"


@interface SMAddRSSViewController ()
@property(nonatomic,retain)NSManagedObjectContext *managedObjectContext;
@property(nonatomic,strong)UITextField *tfValue;
@property(nonatomic,strong)MWFeedParser *feedParser;
@property(nonatomic,strong)Subscribes *subscribe;
@property(nonatomic,strong)RSS *rss;

@property(nonatomic,strong)MWFeedInfo *feedInfo;
@property(nonatomic,strong)NSMutableArray *parsedItems;
@property(nonatomic,strong)SMAppDelegate *appDelegate;
@property(nonatomic,strong)UILabel *lbSending;
@end

@implementation SMAddRSSViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.view.backgroundColor = [SMUIKitHelper colorWithHexString:COLOR_BACKGROUND];
    }
    return self;
}
-(void)doBack {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)loadView {
    [super loadView];
    UISwipeGestureRecognizer *recognizer;
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(doBack)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [[self view]addGestureRecognizer:recognizer];
    recognizer = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _tfValue = [[UITextField alloc]initWithFrame:CGRectMake(20, NAVBARHEIGHT, 276, 52)];
    _tfValue.backgroundColor = [UIColor whiteColor];
    _tfValue.delegate = self;
    _tfValue.returnKeyType = UIReturnKeyDone;
    _tfValue.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _tfValue.placeholder = @"请输入RSS地址";
    [_tfValue becomeFirstResponder];
    [self.view addSubview:_tfValue];
    
    CGRect rect = _tfValue.frame;
    rect.origin.y += 55;
    NSString *sendingText = @"您输入的rss正在添加中，请耐心等待...";
    rect.size = [sendingText sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}];
    //label of sending
    _lbSending = [SMUIKitHelper labelShadowWithRect:rect text:sendingText textColor:@"#333333" fontSize:14];
    [self.view addSubview:_lbSending];
    _lbSending.hidden = YES;
    
    //init
    _parsedItems = [NSMutableArray array];
    
    //Core Data
    _appDelegate = [UIApplication sharedApplication].delegate;
    _managedObjectContext = _appDelegate.managedObjectContext;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TextField delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [_tfValue resignFirstResponder];
    if (_tfValue.text != nil) {
        //
        NSString *tfString =nil;
        if ([[_tfValue.text substringToIndex:7]isEqualToString:@"http://"]) {
            //
            NSLog(@"show it %@",[_tfValue.text substringToIndex:7]);
            tfString = _tfValue.text;
        } else {
            tfString = [NSString stringWithFormat:@"http://%@",_tfValue.text];
        }
        
        _lbSending.hidden = NO;
        //读取解析rss
        NSURL *feedURL = [NSURL URLWithString:tfString];
        _feedParser = [[MWFeedParser alloc]initWithFeedURL:feedURL];
        _feedParser.delegate = self;
        _feedParser.feedParseType = ParseTypeFull;
        _feedParser.connectionType = ConnectionTypeSynchronously;
        [_feedParser parse];
        //这里需要一个hud不让用户操作。
    }
    return YES;
}

#pragma mark - MWFeedParserDelegate
-(void)feedParserDidStart:(MWFeedParser *)parser {
    NSLog(@"Started Parsing");
}

-(void)feedParser:(MWFeedParser *)parser didParseFeedInfo:(MWFeedInfo *)info {
    if (info.title) {
        _feedInfo = info;
    } else {
        
    }
}

-(void)feedParser:(MWFeedParser *)parser didParseFeedItem:(MWFeedItem *)item {
    if (item.title) {
        [_parsedItems addObject:item];
        //        NSLog(@"title:%@ author:%@ sum:%@ content:%@",item.title,item.author,item.summary,item.content);
    } else {
        NSLog(@"failed by item");
    }
    
}

-(void)feedParserDidFinish:(MWFeedParser *)parser {
    SMGetFetchedRecordsModel *getModel = [[SMGetFetchedRecordsModel alloc]init];
    getModel.entityName = @"Subscribes";
    getModel.predicate = [NSPredicate predicateWithFormat:@"url=%@",[_feedInfo.url absoluteString]];
    NSArray *fetchedRecords = [APP_DELEGATE getFetchedRecords:getModel];
    NSError *error;
    if (fetchedRecords.count == 0) {
        _subscribe = [NSEntityDescription insertNewObjectForEntityForName:@"Subscribes" inManagedObjectContext:APP_DELEGATE.managedObjectContext];
        _subscribe.title = _feedInfo.title ? _feedInfo.title : @"未命名";
        _subscribe.summary = _feedInfo.summary ? _feedInfo.summary : @"无描述";
        _subscribe.link = _feedInfo.link ? _feedInfo.link : @"无连接";
        _subscribe.url = [_feedInfo.url absoluteString] ? [_feedInfo.url absoluteString] : @"无连接";
        _subscribe.createDate = [NSDate date];
        _subscribe.total = [NSNumber numberWithInteger:_parsedItems.count];
        _subscribe.lastUpdateTime = [NSDate dateWithTimeIntervalSince1970:0];
        _subscribe.updateTimeInterval = @60;
        
        
        if (_subscribe.title) {
            [APP_DELEGATE.managedObjectContext save:&error];
            [_smAddRSSViewControllerDelegate addedRSS:_subscribe];
        }
    } else {
        //已存在订阅的情况
    }
    
    SMRSSModel *rssModel = [[SMRSSModel alloc]init];
    [rssModel insertRSSFeedItems:_parsedItems ofFeedUrlStr:[_feedInfo.url absoluteString]];
    
    _lbSending.hidden = YES;
    NSLog(@"finished");
    [self doBack];
}

-(void)feedParser:(MWFeedParser *)parser didFailWithError:(NSError *)error {
    [_lbSending setText:@"链接无效，请尝试其它链接"];
}

@end