//
//  ViewController.m
//  WeAblum
//
//  Created by Apple on 2017/2/24.
//  Copyright © 2017年 WeAblum. All rights reserved.
//

#import "ViewController.h"
//#import "WebViewController.h"
//#import "CommonUtils.h"
//#import "FJTabBarViewController.h"
//#import "FJNavgationViewController.h"
//#import "WGImageAttributeManager.h"
//#import "MQWebViewController.h"
//#import "WXApi.h"
//#import "WXRespManager.h"
//#import "WGConnectData.h"
//#import "WebViewController+Script.h"
//#import "RouterFile.h"
//#import "UIColor+Hex.h"
//#import "UMSocialManager+WGDouYinShare.h"
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
        login.routeCallback = parameters[kRouterUserLogin];
        return login;
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configServices];
    [self setupUI];
    [self configBtnInfo];
    [self checkSupportMobileLogin];
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

- (void)configServices {
    self.appService = (id<AppCommonModuleService>) [Bifrost moduleByService:@protocol(AppCommonModuleService)];
    self.userService = (id<WGUserModuleService>) [Bifrost moduleByService:@protocol(WGUserModuleService)];
    
}

- (void)checkSupportMobileLogin {
    if ([self.appService um_wechat_Social_isInstall]) {
        [[NetLayer net] albumRequstWithPath:@"" params:nil callback:^(WGConnectData * _Nonnull data) {
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"viewcontroller  viewWillAppear");
    self.navigationController.navigationBarHidden = YES;
}

- (void)segueToWebViewController:(NSString *)url andIsIndex:(BOOL)isIndex
{
//    NSLog(@"segueToWebViewController:url==%@",url);
//    if ([WGImageAttributeManager getImageAttributeManager].isNative) {
//        WebViewController *webVC=[[WebViewController alloc] init];
//        FJNavgationViewController *nvc = [[FJNavgationViewController alloc]initWithRootViewController:webVC];
//        [webVC setUrlString:url andTitle:nil andIsIndex:isIndex];
//        [UIApplication sharedApplication].keyWindow.rootViewController = nvc;
//        [[UIApplication sharedApplication].keyWindow makeKeyAndVisible];
//    }else{
//        FJTabBarViewController *TBVC=[[FJTabBarViewController alloc] init];
//        [UIApplication sharedApplication].keyWindow.rootViewController = TBVC;
//        [[UIApplication sharedApplication].keyWindow makeKeyAndVisible];
//    }
    if (self.routeCallback) {
        self.routeCallback(nil);
    }

}

- (void)wechatAuth {
    __weak ViewController *weakSelf = self;
    [self.appService authWechatCurrentViewController:self completion:^(id  _Nonnull result, NSError * _Nonnull error) {
        if (error) {
            [self.appService logModule:@"[WEIXIN]=>[BACK]" verbose:[NSString stringWithFormat:@"ERROR:%@", error]];
            [SVProgressHUD dismiss];
            [weakSelf getUserDataFailed];
            return;
        }
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:result];
        userInfo[@"anonymousId"] = [DataAnlyticsManager anlytic].anonymousId;
        userInfo[@"act"] = @"decodeUserInfo";
        [[NetLayer net] albumRequstWithPath:@"service/account/app_auth.jsp" params:userInfo callback:^(WGConnectData * _Nonnull data) {
            [SVProgressHUD dismiss];
            if (data.isSuccess) {
                [weakSelf updateToken:data.token uid:data.uid dev:data.result[@"dev"]];
                [weakSelf requestUid];
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
    }];
}

- (void)guestLogin {
    
}
- (void)userLogin {
    BOOL isInstall = [self.appService um_wechat_Social_isInstall];
    [SVProgressHUD showWithStatus:@"授权跳转中..."];
    if (isInstall) {
        [self wechatAuth];
    } else {
        
    }
//    [CommonUtils setSVProgressHUD:@"授权跳转中..."];
//    weakSelf(self);
//    if (isInstall) {
//        [[UMSocialManager defaultManager] authWechatCurrentViewController:self completion:^(id result, NSError *error) {
//            if (error) {
//                LLog(@"从微信返回..........",[NSString stringWithFormat:@"error:%@",error]);
//                [SVProgressHUD dismiss];
//                [weakself getUserDataFailed];
//                return;
//            }
//            NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:result];
//            userInfo[@"anonymousId"] = [DataAnlyticsManager anlytic].anonymousId;
//            userInfo[@"act"] = @"decodeUserInfo";
//            [[WGConnectHelper shareInstance] postUrl:@"service/account/app_auth.jsp" params:userInfo entiyClass:nil parserJsonBlock:nil complateBlock:^(NSURLSessionDataTask * _Nullable task, WGConnectData * _Nonnull connectData) {
//                if (connectData.isSuccess) {
//                    [SVProgressHUD dismiss];
//                    [weakself updateToken:connectData.token uid:connectData.uid dev:connectData.responseData[@"dev"]];
//                    [weakself requestUid];
//                    if ([connectData.redirect_url containsString:@"#/reg"]) {
//                        [weakself logRedirectTo:connectData.redirect_url];
//                    } else {
//                        [weakself loginWithInfo:connectData.responseData token:connectData.token];
//                    }
//                    [weakself updateAppbageNumber];
//                } else {
//                    [SVProgressHUD dismiss];
//                    [weakself showLoginFailWithNetWork];
//                }
//            }];
//        }];
//
//    } else {
//        [[HttpClient shareInstance] LoginGuest:^(id responseObject, NSError *error) {
//            if (!error) {
//                int responseErrcode = [[responseObject objectForKey:@"errcode"] intValue];
//
//                if (responseErrcode == 0 && responseObject) {
//                    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
//                    [userInfo setValue:@"oTmHYjr8fk0Z6J8Necoqx99oTYnM" forKey:@"uid"];
//                    [userInfo setValue:@"otHyZwwjTYdDK91wX2eu6x2V0RrA" forKey:@"open_id"];
//                    userInfo[@"anonymousId"] = [DataAnlyticsManager anlytic].anonymousId;
//                    [self loginIndex:userInfo];
//                }else if (responseErrcode ==502){
//                    [SVProgressHUD dismiss];
//                    //直接跳转到微信安装
//                    NSString *download = @"http://itunes.apple.com/cn/app/id414478124?mt=8";
//                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:download]];
//                }else{
//                    [SVProgressHUD dismiss];
//                    [self loginFailAlertMessage:@"服务器返回数据失败，请重试..." errorCode:responseErrcode];
//                }
//            }else{
//                [SVProgressHUD dismiss];
//                [self loginFailAlertMessage:@"请求失败，请重试..." errorCode:error.code];
//            }
//
//
//        }];
//    }


}



- (void)trachLoginEvent:(NSDictionary *)info {
    LoginEvent *event = [[LoginEvent alloc] initWithMethod:@"微信" shop_name:info[@"shop_name"] loginId:info[@"shop_id"]];
    [self.userService saveLoginUserInfo:info];
    [event send];
}

- (void)configSensorEvent:(NSDictionary *)result {
//    [self trachLoginEvent:result];
//    [[HttpClient shareInstance] trackSignUp:@{
//        @"shop_id":result[@"shop_id"],
//        @"anonymous_id":[DataAnlyticsManager anlytic].anonymousId
//    }resultBlock:^(WGConnectData *connectData) {
//        if (connectData.isSuccess) {
//            [DataAnlyticsManager anlytic].config.sensors_is_vip = connectData.responseData[@"is_vip"];
//        }
//    }];
}


- (void)logRedirectTo:(NSString *)redirect_url {
    [Bifrost handleURL:kRouteWebPath complexParams:@{kkRouteWebIsRegParams: @(YES)} completion:nil];
}

- (void)loginWithInfo:(NSDictionary *)result token:(NSString *)token {
//    [self configSensorEvent:result];
//    NSString *lastUrl = [NSString stringWithFormat:@"%@static/index.html#/album_home", [CommonUtils getBaseURL]];
//    NSString *subURL = [CommonUtils saveLoginStatusURL:lastUrl];
//    [[UserData shareInstance] setParam:SUB_URL_KEY ValueOfParam:subURL];
//    [[UserData shareInstance] setParam:LAST_URL_KEY ValueOfParam:lastUrl];
//    [self segueToWebViewController:lastUrl andIsIndex:[CommonUtils isIndex:lastUrl]];
}

- (void)updateAppbageNumber {
    NSUInteger badgeNumber = [[NSUserDefaults standardUserDefaults] integerForKey:@"BadgeNumber"];
    [UIApplication sharedApplication].applicationIconBadgeNumber = badgeNumber;
}

- (void)updateToken:(NSString *)token uid:(NSString *)uid dev:(NSString *)dev {
//    [self configUmAlais:uid];
//    [[UserData shareInstance] updateToken:token];
//    [[UserData shareInstance] setValueInGroupValue:dev key:JS_DEVELOP];
}

- (void)configUmAlais:(NSString *)unid {
//    if (unid.length > 0) {
//        [[UserData shareInstance] setParam:@"uidkey" ValueOfParam:unid];
//        [UMessage addAlias:unid type:kUMessageAliasTypeWeiXin response:^(id responseObject, NSError *UMError) {
//            if (UMError) {
//                LLog(@"PUSH->SET:==>",[NSString stringWithFormat:@"info:%@", UMError.userInfo]);
//            }
//        }];
//    }
}
//登录成功
- (void)loginIndex:(NSDictionary *)userInfo {
//    [[HttpClient shareInstance] LoginBase:userInfo resultBlock:^(id responseObject, NSError *error) {
//        if (!error) {
//            int responseErrcode = [[responseObject objectForKey:@"errcode"] intValue];
//            NSString *responseErrormsg = [responseObject objectForKey:@"errmsg"];
//            if (responseErrcode == 0 && responseObject) {
//                NSDictionary * result = responseObject[@"result"];
//                NSString *redirect_url = [responseObject objectForKey:@"redirect_url"];
//                NSString *token = [responseObject objectForKey:@"token"];
//                NSString *uid = [responseObject objectForKey:@"uid"];
//                //绑定用户信息到deviceToken
//                [self updateToken:token uid:uid dev:result[@"dev"]];
//                [self requestUid];
//                if ([redirect_url containsString:@"#/reg"]) {
//                    [SVProgressHUD dismiss];
//                    [self logRedirectTo:redirect_url];
//                } else {
//                    [self loginWithInfo:result token:token];
//                }
//                [self updateAppbageNumber];
//                LLog(@"返回的数据-----------",[NSString stringWithFormat:@"errcode:%ld--------token:%@",(long)[responseObject[@"errcode"] integerValue],responseObject[@"token"]]);
//
//            } else {
//                [SVProgressHUD dismiss];
//                [self showLoginFailWithNetWork];
//            }
//        } else {
//            [SVProgressHUD dismiss];
//            [self showLoginFailWithNetWork];
//        }
//    }];
}

//获取相册id
- (void)requestUid{
//    [[WGConnectHelper shareInstance]postUrl:WGGetUidAPI params:nil entiyClass:nil parserJsonBlock:nil complateBlock:^(NSURLSessionDataTask * _Nullable task, WGConnectData * _Nonnull connectData) {
//        if (connectData.isSuccess) {
//            [[UserData shareInstance]setParam:WGUIDKEY ValueOfParam:connectData.responseData[@"userId"]];
//        }
//    }];
}

#pragma mark - 配置环境

- (void)getUserDataFailed{
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
    [self presentViewController:alert animated:YES completion:^{
    }];
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

- (void)loginFailWithNetWork{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"网络问题,登录未成功" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *actionLeft = [UIAlertAction actionWithTitle:[self.appService localizedStringForKey:@"查看解决方案"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *url = @"http://mp.weixin.qq.com/s/kNu7VaUszjzIhF0rY_ZhgA";
        [self openMqcCtr:url];
    }];
    UIAlertAction *actionRight = [UIAlertAction actionWithTitle:[self.appService localizedStringForKey:@"关闭"] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:actionLeft];
    [alert addAction:actionRight];
    [self presentViewController:alert animated:YES completion:^{
    }];
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
    [self presentViewController:alert animated:YES completion:^{
    }];
}

- (void)jumpConactCustomerCtr {
//    WebViewController *webVC=[[WebViewController alloc] init];
     NSArray * scripts = @[@"const wg_titleBar = document.getElementsByClassName('title-normal')[0];wg_titleBar.style.display='none'"];
//    [webVC setUrlString:kconact_customer_link andTitle:nil andIsIndex:0];
//    [self.navigationController pushViewController:webVC animated:YES];
    UIViewController *ctr = [Bifrost handleURL:kRouteWebPath
                                 complexParams:@{
                                     kRouteWebUrlParams:@"",
                                    kRouteWebScriptsParams:scripts
                                 } completion:nil];
    [self.navigationController pushViewController:ctr animated:YES];
}

- (void)mobileLogin {
    NSString *mobileLoginURL = [NSString stringWithFormat:@"%@static/index.html?link_type=phone_login&anonymousId=%@", [self.appService mediator_base_url],[DataAnlyticsManager anlytic].anonymousId];
    UIViewController *ctr = [Bifrost handleURL:kRouteWebPath complexParams:@{kRouteWebUrlParams:  mobileLoginURL} completion:nil];
    [self.navigationController pushViewController:ctr animated:YES];

}

- (void)protocolBtnClick{
    NSString *mobileLoginURL = @"https://mp.weixin.qq.com/s/9W-YveWqvEwpr8MUDOTV0g";
    UIViewController *ctr = [Bifrost handleURL:kRouteWebPath complexParams:@{kRouteWebUrlParams:  mobileLoginURL} completion:nil];
    [self.navigationController pushViewController:ctr animated:YES];
}

#pragma mark - Private Methods

#pragma mark - 懒加载

- (UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc]init];
        _imageView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        if (UIDevice.currentDevice.isIPhoneNotchScreen) {
            [_imageView setImage:[UserBundleLoad imageNamed:@"iPhone_log_bg"]];
        } else {
            [_imageView setImage:[UserBundleLoad imageNamed:@"group-2"]];
        }
    }
    return _imageView;
}

- (UIButton *)loginButton{
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

- (UIButton *)mobileButton{
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

- (UILabel *)protocolLabel{
    if (!_protocolLabel) {
        _protocolLabel = [[UILabel alloc]init];
        _protocolLabel.text = @"登录即代表你同意";
        _protocolLabel.textColor = [UIColor darkGrayColor];
        _protocolLabel.font = [UIFont systemFontOfSize:11];
        _protocolLabel.textAlignment = NSTextAlignmentRight;
    }
    return _protocolLabel;
}

- (UIButton *)protocolBtn{
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

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];

    self.imageView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    if (UIDevice.currentDevice.isPad) {
        [self.imageView setImage:[UserBundleLoad imageNamed:@"index"]];
    }else{
        if (UIDevice.currentDevice.isIPhoneNotchScreen) {
            [self.imageView setImage:[UserBundleLoad imageNamed:@"iPhone_log_bg"]];
        } else {
            [self.imageView setImage:[UserBundleLoad imageNamed:@"group-2"]];
        }
    }
    if (UIDevice.currentDevice.isIPhoneNotchScreen) {
        self.mobileButton.frame = CGRectMake(20, UIScreen.height-62-34, UIScreen.width-40, 20);
        self.loginButton.frame = CGRectMake(20, UIScreen.height-120-34, UIScreen.width-40, 44);
        self.protocolLabel.frame = CGRectMake(UIScreen.width/2-100, UIScreen.height-42-34, 100, 44);
        self.protocolBtn.frame = CGRectMake(UIScreen.width/2, UIScreen.height-42-34, 120, 44);
    }else{
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

@end
