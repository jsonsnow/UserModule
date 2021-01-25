//
//  ViewController.m
//  WeAblum
//
//  Created by Apple on 2017/2/24.
//  Copyright © 2017年 WeAblum. All rights reserved.
//

#import "ViewController.h"
#import <Sensors/Sensors-Swift.h>
#import <Mediator/WGUserModuleService.h>
#import <Mediator/WGAppModuleService.h>
#import <Mediator/WGWebModuleService.h>
#import <WGNet/WGNet-Swift.h>
#import <WGCommon/WGCommon-Swift.h>
#import <UserModule/UserModule-Swift.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface ViewController ()
@property (strong, nonatomic)  UIButton *loginButton;
@property (strong, nonatomic)  UIImageView *imageView;
@property (strong, nonatomic)  UIButton *mobileButton;

@property (nonatomic, strong) UILabel *protocolLabel;

@property (nonatomic, strong) UIButton *protocolBtn;
@property (nonatomic, assign) BOOL isSupportMobileLogin;
@property (nonatomic, copy) BifrostRouteCompletion routeCallback;
@property (nonatomic, weak) id <AppCommonModuleService> appService;
@property (nonatomic, weak) id <WGUserModuleService> userService;

@end

@implementation ViewController

+ (void)load {
    [Bifrost bindURL:kRouterUserLogin toHandler:^id _Nullable(NSDictionary * _Nullable parameters) {
        ViewController *login = [[ViewController alloc] init];
        login.routeCallback = parameters[kBifrostRouteCompletion];
        return login;
    }];
}

#pragma mark -- life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configServices];
    [self setupUI];
    [self configBtnInfo];
    [self checkSupportMobileLogin];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.loginButton];
    [self.view addSubview: self.mobileButton];
    [self.view addSubview:self.protocolLabel];
    [self.view addSubview:self.protocolBtn];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.imageView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    if (UIDevice.currentDevice.isPad) {
        [self.imageView setImage:[UserBundleLoad imageNamed:@"index"]];
    }else{
        if (UIDevice.currentDevice.iSiPhoneNotchScreen) {
            [self.imageView setImage:[UserBundleLoad imageNamed:@"iPhone_log_bg"]];
        } else {
            [self.imageView setImage:[UserBundleLoad imageNamed:@"group-2"]];
        }
    }
    if (UIDevice.currentDevice.iSiPhoneNotchScreen) {
        self.mobileButton.frame = CGRectMake(20, UIScreen.height-62-34, UIScreen.width-40, 20);
        self.loginButton.frame = CGRectMake(20, UIScreen.height-120-34, UIScreen.width-40, 44);
        self.protocolLabel.frame = CGRectMake(UIScreen.width/2-100, UIScreen.height-42-34, 100, 44);
        self.protocolBtn.frame = CGRectMake(UIScreen.width/2, UIScreen.height-42-34, 120, 44);
    } else {
        self.mobileButton.frame = CGRectMake(20, UIScreen.height-62, UIScreen.width-40, 20);
        self.loginButton.frame = CGRectMake(20, UIScreen.height-120, UIScreen.width-40, 44);
        self.protocolLabel.frame = CGRectMake(UIScreen.width/2-100, UIScreen.height-42, 100, 44);
        self.protocolBtn.frame = CGRectMake(UIScreen.width/2, UIScreen.height-42, 120, 44);
    }
}

- (void)dealloc {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark -- private method

- (void)configServices {
    self.appService = (id<AppCommonModuleService>) [Bifrost moduleByService:@protocol(AppCommonModuleService)];
    self.userService = (id<WGUserModuleService>) [Bifrost moduleByService:@protocol(WGUserModuleService)];
}

- (void)checkSupportMobileLogin {
    if (![self.appService um_wechat_Social_isInstall]) {
        [[NetLayer net] albumRequstWithPath:@"service/account/guest_login.js" params:@{@"is_guest": @"1"} callback:^(WGConnectData * _Nonnull data) {
            int code = [data.errcode intValue];
            if (code == 502) {
                self.isSupportMobileLogin = YES;
            }
            [self.mobileButton setHidden:!self.isSupportMobileLogin];
        }];
    }
}

- (void)configBtnInfo {
    if (![self.appService um_wechat_Social_isInstall]) {
        if (!TARGET_IPHONE_SIMULATOR) {
            [self.loginButton setTitle:[self.appService localizedStringForKey:@"游客登录"] forState:normal];
            [self.mobileButton setHidden:YES];
        }
    }
}

- (void)segueToWebViewController:(NSString *)url andIsIndex:(BOOL)isIndex {
    if (self.routeCallback) {
        self.routeCallback(nil);
    }
}

- (void)wechatAuth {
    __weak ViewController *weakSelf = self;
    [self.appService authWechatCurrentViewController:self completion:^(id  _Nonnull result, NSError * _Nonnull error) {
        if (error) {
            [weakSelf.appService logModule:@"[WEIXIN]=>[BACK]" verbose:[NSString stringWithFormat:@"ERROR:%@", error]];
            [SVProgressHUD dismiss];
            [weakSelf getUserDataFailed];
            return;
        }
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:result];
        userInfo[@"anonymousId"] = [DataAnlyticsManager anlytic].anonymousId;
        userInfo[@"act"] = @"decodeUserInfo";
        [weakSelf loginByInfo:userInfo];
    }];
}

- (void)guestLogin {
    __weak ViewController *weakSelf = self;
    //不是游客登录接口，而是后续行为的依据
    [[NetLayer net] albumRequstWithPath:@"service/account/guest_login.js" params:@{@"is_guest": @"1"} callback:^(WGConnectData * _Nonnull data) {
        if (data.isSuccess) {
            int code = [data.errcode intValue];
            if (code == 0) {
                NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
                [userInfo setValue:@"oTmHYjr8fk0Z6J8Necoqx99oTYnM" forKey:@"uid"];
                [userInfo setValue:@"otHyZwwjTYdDK91wX2eu6x2V0RrA" forKey:@"open_id"];
                userInfo[@"anonymousId"] = [DataAnlyticsManager anlytic].anonymousId;
                userInfo[@"act"] = @"decodeUserInfo";
                [self loginByInfo:userInfo];
            } else if (code == 502) {
                [SVProgressHUD dismiss];
                NSString *download = @"http://itunes.apple.com/cn/app/id414478124?mt=8";
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:download]];
            } else {
                [SVProgressHUD dismiss];
                [self loginFailAlertMessage:@"服务器返回数据失败，请重试..." errorCode:code];
            }
        } else {
            [SVProgressHUD dismiss];
            [weakSelf showLoginFailWithNetWork];
        }
    }];
}

- (void)loginByInfo:(NSDictionary *)info {
    __weak ViewController *weakSelf = self;
    [[NetLayer net] albumRequstWithPath:@"service/account/app_auth.jsp" params:info callback:^(WGConnectData * _Nonnull data) {
        [SVProgressHUD dismiss];
        if (data.isSuccess) {
            [weakSelf updateToken:data.token uid:data.uid dev:data.result[@"dev"]];
            if ([data.redirect_url containsString:@"#/reg"]) {
                [weakSelf logRedirectTo:data.redirect_url];
            } else {
                [weakSelf loginWithInfo:data.result token:data.token];
            }
            [weakSelf updateAppbageNumber];
        } else {
            [weakSelf showLoginFailWithNetWork];
        }
    }];
}

- (void)userLogin {
    BOOL isInstall = [self.appService um_wechat_Social_isInstall];
    [SVProgressHUD showWithStatus:@"授权跳转中..."];
    if (isInstall) {
        [self wechatAuth];
    } else {
        [self guestLogin];
    }
}

- (void)trachLoginEvent:(NSDictionary *)info {
    LoginEvent *event = [[LoginEvent alloc] initWithMethod:@"微信" shop_name:info[@"shop_name"] loginId:info[@"shop_id"]];
    [self.userService saveLoginUserInfo:info];
    [event send];
}

- (void)configSensorEvent:(NSDictionary *)result {
    [self trachLoginEvent:result];
    [[NetLayer net] albumRequstWithPath:@"service/account/app_auth.jsp?act=track_signUp"
                                 params:@{
                                     @"shop_id": result[@"shop_id"],
                                     @"anonymous_id": [DataAnlyticsManager anlytic].anonymousId }
                               callback:^(WGConnectData * _Nonnull data) {
        if (data.isSuccess) {
            [DataAnlyticsManager anlytic].config.sensors_is_vip = data.result[@"is_vip"];
        }
    }];
}


- (void)logRedirectTo:(NSString *)redirect_url {
    UIViewController *ctr = [Bifrost handleURL:kRouteWebPath complexParams:@{kkRouteWebIsRegParams: @(YES), kRouteWebUrlParams: redirect_url} completion:nil];
    [self.navigationController pushViewController:ctr animated:YES];
}

- (void)loginWithInfo:(NSDictionary *)result token:(NSString *)token {
    [self configSensorEvent:result];
    [self segueToWebViewController:nil andIsIndex:NO];
}

- (void)updateAppbageNumber {
    NSUInteger badgeNumber = [[NSUserDefaults standardUserDefaults] integerForKey:@"BadgeNumber"];
    [UIApplication sharedApplication].applicationIconBadgeNumber = badgeNumber;
}

- (void)updateToken:(NSString *)token uid:(NSString *)uid dev:(NSString *)dev {
    [self.userService saveUserToken:token];
    [self.userService setJSDevelop:dev];
    [self.appService configUMAlias:uid];
}


#pragma mark - 配置环境

- (void)getUserDataFailed {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"获取微信数据失败，请检查网络权限是否打开" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionLeft = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    UIAlertAction *actionRight = [UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if([[UIApplication sharedApplication] canOpenURL:settingsURL]) {
            [[UIApplication sharedApplication] openURL:settingsURL];
        }
    }];
    [alert addAction:actionLeft];
    [alert addAction:actionRight];
    [self presentViewController:alert animated:YES completion:nil];
}


- (void)showLoginFailWithNetWork {
    UIColor *color = [[UIColor alloc] init:@"#285B9A" defaultColor: UIColor.clearColor];
    WGAlertActionBtn *contact = [[WGAlertActionBtn alloc] initWithTitle:@"联系客服" font:17 color:color hideRightLine:NO action:^{
        [self jumpContactCtr];
    }];
    WGAlertActionBtn *solve = [[WGAlertActionBtn alloc] initWithTitle:@"解决方案" font:17 color:nil hideRightLine:YES action:^{
        [self jumpSolveCtr];
    }];
    WGAlertPopView *alert = [[WGAlertPopView alloc] initWithTitle:@"登录失败" msg:@"请查看登录失败的解决方案，如有疑问，联系客服咨询"];
    [[[alert addActionBtn:contact] addActionBtn:solve] showTo:nil];
}

- (void)jumpSolveCtr {
    NSString *url = @"http://mp.weixin.qq.com/s/kNu7VaUszjzIhF0rY_ZhgA";
    UIViewController *web = [Bifrost handleURL:kRouteMQWebPath complexParams:@{kRouteWebUrlParams: url} completion:nil];
    [self.navigationController pushViewController:web animated:YES];
}

- (void)jumpContactCtr {
    [self jumpConactCustomerCtr];
}

- (void)openMqcCtr:(NSString *)url {
    UIViewController *ctr = [Bifrost handleURL:kRouteMQWebPath complexParams:@{kRouteWebUrlParams: url} completion:nil];
    [self.navigationController pushViewController:ctr animated:YES];
}

- (void)loginFailWithNetWork {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"网络问题,登录未成功" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionLeft = [UIAlertAction actionWithTitle:[self.appService localizedStringForKey:@"查看解决方案"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *url = @"http://mp.weixin.qq.com/s/kNu7VaUszjzIhF0rY_ZhgA";
        [self openMqcCtr:url];
    }];
    UIAlertAction *actionRight = [UIAlertAction actionWithTitle:[self.appService localizedStringForKey:@"关闭"] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:actionLeft];
    [alert addAction:actionRight];
    [self presentViewController:alert animated:YES completion:nil];
}


//登录失败
- (void)loginFailAlertMessage:(NSString *)message errorCode:(NSInteger)errorCode {
    NSString *title = [NSString stringWithFormat:@"%@ \n errorCode:%ld",message,(long)errorCode];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionLeft = [UIAlertAction actionWithTitle:[self.appService localizedStringForKey:@"查看解决方案"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *url = @"http://mp.weixin.qq.com/s/kNu7VaUszjzIhF0rY_ZhgA";
        [self openMqcCtr:url];
    }];
    UIAlertAction *actionRight = [UIAlertAction actionWithTitle:[self.appService localizedStringForKey:@"联系客服"] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self jumpConactCustomerCtr];
    }];
    [alert addAction:actionRight];
    [alert addAction:actionLeft];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)jumpConactCustomerCtr {
    NSArray * scripts = @[@"const wg_titleBar = document.getElementsByClassName('title-normal')[0];wg_titleBar.style.display='none'"];
    UIViewController *ctr = [Bifrost handleURL:kRouteWebPath
                                 complexParams:@{
                                     kRouteWebUrlParams: [self.appService conact_customer_link],
                                    kRouteWebScriptsParams:scripts
                                 } completion:nil];
    [self.navigationController pushViewController:ctr animated:YES];
}

- (void)mobileLogin {
    NSString *mobileLoginURL = [NSString stringWithFormat:@"%@static/index.html?link_type=phone_login&anonymousId=%@", [self.appService mediator_base_url],[DataAnlyticsManager anlytic].anonymousId];
    UIViewController *ctr = [Bifrost handleURL:kRouteWebPath complexParams:@{kRouteWebUrlParams:  mobileLoginURL} completion:nil];
    [self.navigationController pushViewController:ctr animated:YES];

}

- (void)protocolBtnClick {
    NSString *mobileLoginURL = @"https://mp.weixin.qq.com/s/9W-YveWqvEwpr8MUDOTV0g";
    UIViewController *ctr = [Bifrost handleURL:kRouteWebPath complexParams:@{kRouteWebUrlParams:  mobileLoginURL} completion:nil];
    [self.navigationController pushViewController:ctr animated:YES];
}

#pragma mark - Private Methods

#pragma mark - 懒加载

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc]init];
        _imageView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        if (UIDevice.currentDevice.iSiPhoneNotchScreen) {
            [_imageView setImage:[UserBundleLoad imageNamed:@"iPhone_log_bg"]];
        } else {
            [_imageView setImage:[UserBundleLoad imageNamed:@"group-2"]];
        }
    }
    return _imageView;
}

- (UIButton *)loginButton {
    if (!_loginButton) {
        _loginButton = [[UIButton alloc]init];
        [_loginButton addTarget:self action:@selector(userLogin) forControlEvents:UIControlEventTouchUpInside];
        _loginButton.backgroundColor = [[UIColor alloc] init:@"#25ac1d" defaultColor:UIColor.clearColor];
        [_loginButton setTitle:@"微信登录" forState:UIControlStateNormal];
        [_loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _loginButton.titleLabel.font = [UIFont systemFontOfSize:16];
        _loginButton.layer.shadowColor = [[UIColor alloc] init:@"#040404" defaultColor:UIColor.clearColor].CGColor;
        _loginButton.layer.shadowRadius = 5;
        _loginButton.layer.shadowOpacity = 0.8;
        _loginButton.layer.shadowOffset = CGSizeMake(0, 2);
        _loginButton.layer.cornerRadius = 5;
    }
    return _loginButton;
}

- (UIButton *)mobileButton {
    if (!_mobileButton) {
        _mobileButton = [[UIButton alloc]init];
        [_mobileButton addTarget:self action:@selector(mobileLogin) forControlEvents:UIControlEventTouchUpInside];
        _mobileButton.backgroundColor = [UIColor clearColor];
        [_mobileButton setTitle:@"手机号登录" forState:UIControlStateNormal];
        [_mobileButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _mobileButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _mobileButton.layer.cornerRadius = 3;
        _mobileButton.layer.masksToBounds = YES;
    }
    return _mobileButton;
}

- (UILabel *)protocolLabel {
    if (!_protocolLabel) {
        _protocolLabel = [[UILabel alloc]init];
        _protocolLabel.text = @"登录即代表你同意";
        _protocolLabel.textColor = [UIColor darkGrayColor];
        _protocolLabel.font = [UIFont systemFontOfSize:11];
        _protocolLabel.textAlignment = NSTextAlignmentRight;
    }
    return _protocolLabel;
}

- (UIButton *)protocolBtn {
    if (!_protocolBtn) {
        _protocolBtn = [[UIButton alloc]init];
        [_protocolBtn addTarget:self action:@selector(protocolBtnClick) forControlEvents:UIControlEventTouchUpInside];
        _protocolBtn.backgroundColor = [UIColor clearColor];
        [_protocolBtn setTitle:@"《微商相册登录协议》" forState:UIControlStateNormal];
        [_protocolBtn setTitleColor:[[UIColor alloc] init:@"#4b6580" defaultColor:UIColor.clearColor] forState:UIControlStateNormal];
        _protocolBtn.titleLabel.font = [UIFont systemFontOfSize:11];
        _protocolBtn.titleEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 5);
    }
    return _protocolBtn;
}

@end
