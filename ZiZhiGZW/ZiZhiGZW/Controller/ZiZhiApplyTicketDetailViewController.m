//
//  ZiZhiApplyTicketDetailViewController.m
//  ZiZhiGZW
//
//  Created by zyz on 12/8/15.
//  Copyright © 2015 zizhi. All rights reserved.
//

#import "ZiZhiApplyTicketDetailViewController.h"
#import "BRAdmobView.h"
#import "ZiZhiBannerItemModel.h"
#import "ZiZhiTicketDetailModel.h"
#import "ZiZhiWebViewController.h"
#import "ZiZhiAfficheModel.h"
#import "MarqueeLabel.h"

@interface ZiZhiApplyTicketDetailViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet MarqueeLabel *announcementLabel;
@property (weak, nonatomic) IBOutlet UIView *bannerView;
@property (weak, nonatomic) IBOutlet UILabel *tiptitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *tipxuzhititleLabel;
@property (weak, nonatomic) IBOutlet UITextView *tipxuzhicontentTextField;

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *idCardNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *addressTextField;

@property (strong, nonatomic) NSArray *afficheArray;

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@end

@implementation ZiZhiApplyTicketDetailViewController

- (void)initBanner:(NSArray *)array {
    NSMutableArray *items = [NSMutableArray new];
    for (ZiZhiBannerItemModel *model in array) {
        AdmobInfo *info = [[AdmobInfo alloc] init];
        info.admobId = [NSString stringWithFormat:@"%@", model.id];
        info.url = [NSString stringWithFormat:@"%@%@%@", K_NETWORK_BASE, K_BASE_FIELD, model.picture];
        info.defultImage = [UIImage imageNamed:@"no_img_tip.jpg"];
        [items addObject:info];
    }
    BRAdmobView *banner = [[BRAdmobView alloc] initWithFrame:self.bannerView.bounds andData:items andInViewe:self.bannerView];
    [banner addPageControlViewWithSize:CGSizeMake(10, 10) WithPostion:KPageControlPostion_Middle];
    banner.isAutoScoller=YES;
    banner.allowSelect = YES;
    banner.admobSelect=^(id info,NSInteger index){
        ZiZhiBannerItemModel *model = [array objectAtIndex:index];
        ZiZhiWebViewController *webVC = (ZiZhiWebViewController *)[Utils getVCFromSB:@"ZiZhiWebViewController" storyBoardName:nil];
//        webVC.urlStr = [NSString stringWithFormat:@"%@%@%@", K_NETWORK_BASE, K_BASE_FIELD, model.url];
        if ([model.url hasPrefix:@"http"]) {
            webVC.urlStr = model.url;
        }else {
            webVC.urlStr = [NSString stringWithFormat:@"%@%@%@", K_NETWORK_BASE, K_BASE_FIELD, model.url];
        }
        [self.navigationController pushViewController:webVC animated:YES];
    };
    for (UIView *view in [self.bannerView subviews]) {
        [view removeFromSuperview];
    }
    [self.bannerView addSubview:banner];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.nameTextField.delegate = self;
    self.addressTextField.delegate = self;
    self.phoneTextField.delegate = self;
    self.idCardNumberTextField.delegate = self;
    
    if ([[ZiZhiUserInfoLocalHelperModel userInfoLocalHelper] isLogin]) {
        self.idCardNumberTextField.text = [ZiZhiUserInfoLocalHelperModel userInfoLocalHelper].userInfoModel.idCardNumber;
        self.phoneTextField.text = [ZiZhiUserInfoLocalHelperModel userInfoLocalHelper].userInfoModel.phone;
    }
    
    
    self.scrollView.header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self requestBanner];
        [self requestDetail];
        [self requestNotList];
    }];
    [self.scrollView.header beginRefreshing];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadWebView:(NSString *)urlStr {
    if (urlStr != nil) {
        NSURL *url = [[NSURL alloc]initWithString:urlStr];
        NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:5];//默认缓存策略
        self.webView.opaque = NO;
        self.webView.scalesPageToFit = NO;
        [self.webView loadRequest:request];
    }else {
        self.webView.hidden = YES;
        self.scrollView.contentInset = UIEdgeInsetsMake(0, 0, -self.webView.frame.size.height, 0);
    }
}

- (void)updateUI:(ZiZhiTicketDetailModel *)model {
    if (![Utils isBlankString:model.tiptitle]) {
        self.tiptitleLabel.text = model.tiptitle;
    }
    if (![Utils isBlankString:model.tipxuzhititle]) {
        self.tipxuzhititleLabel.text = model.tipxuzhititle;
    }
    if (![Utils isBlankString:model.tipxuzhicontent]) {
        self.tipxuzhicontentTextField.text = model.tipxuzhicontent;
    }
    [self loadWebView:[NSString stringWithFormat:@"%@%@%@", K_NETWORK_BASE, K_BASE_FIELD, model.tipimgcontent]];
}

- (void)gotoAfficheDetail {
    if ([self.announcementLabel isPaused]) {
        [self.announcementLabel unpauseLabel];
    }
    ZiZhiAfficheModel *model = [self.afficheArray objectAtIndex:0];
    ZiZhiWebViewController *webViewController = (ZiZhiWebViewController *)[Utils getVCFromSB:@"ZiZhiWebViewController" storyBoardName:nil];
//    webViewController.urlStr = [NSString stringWithFormat:@"%@%@%@", K_NETWORK_BASE, K_BASE_FIELD, model.url];
    if ([model.url hasPrefix:@"http"]) {
        webViewController.urlStr = model.url;
    }else {
        webViewController.urlStr = [NSString stringWithFormat:@"%@%@%@", K_NETWORK_BASE, K_BASE_FIELD, model.url];
    }
    [self.navigationController pushViewController:webViewController animated:YES];
}

- (void)updateAfficheUI {
    if (self.afficheArray.count > 0) {
        ZiZhiAfficheModel *model = [self.afficheArray objectAtIndex:0];
        self.announcementLabel.text = model.notContent;
        self.announcementLabel.marqueeType = MLContinuous;
        self.announcementLabel.rate = 24;
        self.announcementLabel.fadeLength = 10.0f;
        self.announcementLabel.trailingBuffer = 30.0f;
        
        UIGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gotoAfficheDetail)];
        self.announcementLabel.userInteractionEnabled = YES;
        [self.announcementLabel addGestureRecognizer:gesture];
    }
}

#pragma mark - Network Request
- (void)requestBanner {
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    [dictionary setObject:@(1) forKey:@"type"];
    [[ZiZhiNetworkManager sharedManager] get:k_url_advlist parameters:dictionary success:^(NSDictionary *dictionary) {
        [self.scrollView.header endRefreshing];
        ZiZhiNetworkResponseModel *model = [ZiZhiNetworkResponseModel objectWithKeyValues:dictionary];
        if (CodeSuccess == model.httpCode) {
            NSArray *array = [ZiZhiBannerItemModel objectArrayWithKeyValuesArray:[dictionary objectForKey:@"content"]];
            [self initBanner:array];
        }
    } failure:^(NSInteger errorCode, NSString *errorMsg) {
        [self.scrollView.header endRefreshing];
        CCLog(@"ZiZhiApplyTicketViewController request banner failed :%@", errorMsg);
    }];
}

- (void)requestDetail {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSMutableDictionary *dictionary = [NSMutableDictionary new];
    
    [[ZiZhiNetworkManager sharedManager] get:k_url_apply_detail parameters:dictionary success:^(NSDictionary *dictionary) {
        [self.scrollView.header endRefreshing];
        ZiZhiNetworkResponseModel *model = [ZiZhiNetworkResponseModel objectWithKeyValues:dictionary];
        if (CodeSuccess == model.httpCode) {
            [hud hide:YES];
            ZiZhiTicketDetailModel *ticketModel = [ZiZhiTicketDetailModel objectWithKeyValues:[dictionary objectForKey:@"content"]];
            [self updateUI:ticketModel];
        }else {
            hud.mode = MBProgressHUDModeText;
            hud.detailsLabelText = model.message;
            [hud hide:YES afterDelay:kMBProgressHUDTipsTime];
        }
    } failure:^(NSInteger errorCode, NSString *errorMsg) {
        [self.scrollView.header endRefreshing];
        hud.mode = MBProgressHUDModeText;
        hud.detailsLabelText = errorMsg;
        [hud hide:YES afterDelay:kMBProgressHUDTipsTime];
    }];
}

/**
 *  申请赠票
 *
 *  @param name   姓名
 *  @param idcardnumber    身份证号
 *  @param phone   手机号
 *  @param address 收货地址
 *  @param loginedidcardnumber   <#errorBlock description#>
 */

- (void)requestApply {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    ZiZhiUserInfoLocalHelperModel *helper = [ZiZhiUserInfoLocalHelperModel userInfoLocalHelper];
    NSMutableDictionary *params = [NSMutableDictionary new];
    NSString *name = self.nameTextField.text;
    NSString *idCardNumber = self.idCardNumberTextField.text;
    NSString *address = self.addressTextField.text;
    NSString *phone = self.phoneTextField.text;
    [params setObject:name forKey:@"name"];
    [params setObject:idCardNumber forKey:@"idcardnumber"];
    [params setObject:address forKey:@"address"];
    [params setObject:phone forKey:@"phone"];
    if ([helper isLogin]) {
        [params setObject:helper.userInfoModel.idCardNumber forKey:@"loginedidcardnumber"];
    }
    [[ZiZhiNetworkManager sharedManager] post:k_url_apply_apply parameters:params success:^(NSDictionary *dictionary) {
        [self.scrollView.header endRefreshing];
        ZiZhiNetworkResponseModel *model = [ZiZhiNetworkResponseModel objectWithKeyValues:dictionary];
        if (CodeSuccess == model.httpCode) {
            hud.mode = MBProgressHUDModeText;
            hud.detailsLabelText = model.message;
            [hud hide:YES afterDelay:6.0];
            
            //申请成功，后自动登录（如果本地已经登录则不替换）
            if ([[ZiZhiUserInfoLocalHelperModel userInfoLocalHelper] isLogin]) {
                //刷新我的报名列表
                [[NSNotificationCenter defaultCenter] postNotificationName:kMyTicketRefreshNotification object:nil];
            }else {
//                NSMutableDictionary *dictionary = [NSMutableDictionary new];
//                [dictionary setObject:idCardNumber forKey:@"idcardnumber"];
//                [dictionary setObject:phone forKey:@"phone"];
//                [[NSNotificationCenter defaultCenter] postNotificationName:kLoginNotification object:dictionary];
                [self requestLogin:idCardNumber phone:phone];
            }
        }else {
            hud.mode = MBProgressHUDModeText;
            hud.detailsLabelText = model.message;
            [hud hide:YES afterDelay:6.0];
        }
        
    } failure:^(NSInteger errorCode, NSString *errorMsg) {
        [self.scrollView.header endRefreshing];
        hud.mode = MBProgressHUDModeText;
        hud.detailsLabelText = errorMsg;
        [hud hide:YES afterDelay:kMBProgressHUDTipsTime];
    }];
}

/**
 *  获取公告
 *  @param type=1申请赠票 2栏目报名
 */
//static NSString * const k_url_notlist = @"/client/adv/notlist.do";
- (void)requestNotList {
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setObject:@(1) forKey:@"type"];
    [[ZiZhiNetworkManager sharedManager] get:k_url_notlist parameters:params success:^(NSDictionary *dictionary) {
        [self.scrollView.header endRefreshing];
        ZiZhiNetworkResponseModel *model = [ZiZhiNetworkResponseModel objectWithKeyValues:dictionary];
        if (CodeSuccess == model.httpCode) {
            self.afficheArray = [ZiZhiAfficheModel objectArrayWithKeyValuesArray:[dictionary objectForKey:@"content"]];
            //界面处理
            [self updateAfficheUI];
        }
    } failure:^(NSInteger errorCode, NSString *errorMsg) {
        [self.scrollView.header endRefreshing];
        CCLog(@"request notlist error:%@", errorMsg);
    }];
}

- (void)requestLogin:(NSString *)idCardNumber phone:(NSString *)phone {    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setObject:idCardNumber forKey:@"idcardnumber"];
    [params setObject:phone forKey:@"phone"];
    [params setObject:@"ios" forKey:@"devicetype"];
    ZiZhiUserInfoLocalHelperModel *helper = [ZiZhiUserInfoLocalHelperModel userInfoLocalHelper];
    if (helper.bChannerId != nil) {
        [params setObject:helper.bChannerId forKey:@"bchannelid"];
    }
    if (helper.bUserId != nil) {
        [params setObject:helper.bUserId forKey:@"buserid"];
    }
    [[ZiZhiNetworkManager sharedManager] post:k_url_login parameters:params success:^(NSDictionary *dictionary) {
        ZiZhiNetworkResponseModel *model = [ZiZhiNetworkResponseModel objectWithKeyValues:dictionary];
        if (CodeSuccess == model.httpCode) {
            //本地化
            ZiZhiUserInfoModel *userInfo = [ZiZhiUserInfoModel objectWithKeyValues:[dictionary objectForKey:@"content"]];
            [[ZiZhiUserInfoLocalHelperModel userInfoLocalHelper] login:userInfo];
        }
    } failure:^(NSInteger errorCode, NSString *errorMsg) {
    }];
}


#pragma mark - Touch Event
- (IBAction)touchSubmitButton:(id)sender {
    [self.nameTextField resignFirstResponder];
    [self.idCardNumberTextField resignFirstResponder];
    [self.phoneTextField resignFirstResponder];
    [self.addressTextField resignFirstResponder];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *name = self.nameTextField.text;
    NSString *idCardNumber = self.idCardNumberTextField.text;
    NSString *address = self.addressTextField.text;
    NSString *phone = self.phoneTextField.text;
    if ([Utils isBlankString:name]) {
        hud.mode = MBProgressHUDModeText;
        hud.detailsLabelText = @"姓名不能为空";
        [hud hide:YES afterDelay:kMBProgressHUDTipsTime];
        return;
    }
    if ([Utils isBlankString:idCardNumber]) {
        hud.mode = MBProgressHUDModeText;
        hud.detailsLabelText = @"身份证号不能为空";
        [hud hide:YES afterDelay:kMBProgressHUDTipsTime];
        return;
    }else {
        if (![Utils isIdentityCardNo:idCardNumber]) {
            hud.mode = MBProgressHUDModeText;
            hud.detailsLabelText = @"请输入正确的身份证号";
            [hud hide:YES afterDelay:kMBProgressHUDTipsTime];
            return;
        }
    }
    
    if ([Utils isBlankString:phone]) {
        hud.mode = MBProgressHUDModeText;
        hud.detailsLabelText = @"手机号不能为空";
        [hud hide:YES afterDelay:kMBProgressHUDTipsTime];
        return;
    }else {
        if (![Utils isMobileNumber:phone]) {
            hud.mode = MBProgressHUDModeText;
            hud.detailsLabelText = @"请输入正确的手机号";
            [hud hide:YES afterDelay:kMBProgressHUDTipsTime];
            return;
        }
    }
    if ([Utils isBlankString:address]) {
        hud.mode = MBProgressHUDModeText;
        hud.detailsLabelText = @"收货地址不能为空";
        [hud hide:YES afterDelay:kMBProgressHUDTipsTime];
        [self.addressTextField becomeFirstResponder];
        return;
    }
    [hud hide:YES];
    
    [self requestApply];
}

#pragma mark - TextField method
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    [theTextField resignFirstResponder];
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
