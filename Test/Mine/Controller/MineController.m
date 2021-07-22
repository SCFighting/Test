//
//  MineController.m
//  Test
//
//  Created by SC on 2020/10/22.
//

#import "MineController.h"

@interface MineController ()
@property (strong, nonatomic) UITextView *logTextView;
@end

@implementation MineController

-(void)loadView
{
    [super loadView];
    self.logTextView = [[UITextView alloc] init];
    self.logTextView.editable = NO;
    [self.logTextView setTextColor:[UIColor whiteColor]];
    [self.logTextView setFont:[UIFont systemFontOfSize:14]];
    [self.logTextView setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.7]];
    [self.view addSubview:self.logTextView];
    [self.logTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"日志" style:UIBarButtonItemStyleDone target:self action:@selector(loadLog)]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)loadLog
{
    DDLogDebug(@"加载日志");
    [[[DDLog sharedInstance] allLoggers] enumerateObjectsUsingBlock:^(id<DDLogger>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[DDFileLogger class]])
        {
            NSString *str = [NSString stringWithContentsOfFile:[(DDFileLogger *)obj currentLogFileInfo].filePath encoding:NSUTF8StringEncoding error:nil];
            [self.logTextView setText:str];
        }
    }];

}

@end
