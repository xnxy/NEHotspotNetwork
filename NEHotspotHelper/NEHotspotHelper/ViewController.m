//
//  ViewController.m
//  NEHotspotHelper
//
//  Created by dev on 2017/10/16.
//  Copyright © 2017年 dev. All rights reserved.
//

#import "ViewController.h"

#import <NetworkExtension/NetworkExtension.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *btn;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (nonatomic, copy) NSString *infoString;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    [self.btn setEnabled:[self scanWifiInfo]];
    
}

#pragma mark ---
#pragma mark --- 打开 无线局域网设置 ---
- (IBAction)clickBtn:(UIButton *)sender {
    
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark ---
#pragma mark --- 扫描周围的无线网络 ---
- (BOOL)scanWifiInfo{
    
    self.textView.text = @"1.start";
    NSLog(@"----- 1.start ----");
    
    NSMutableDictionary* options = [[NSMutableDictionary alloc] init];
    [options setObject:@"NEHotspotHelper" forKey: kNEHotspotHelperOptionDisplayName];
    dispatch_queue_t queue = dispatch_queue_create("EFNEHotspotHelperDemo", NULL);
    
    self.textView.text = @"2.Try";
    NSLog(@"----- 2.Try ------");
    
    __weak typeof(self) weakself = self;
    BOOL returnType = [NEHotspotHelper registerWithOptions: options queue: queue handler: ^(NEHotspotHelperCommand * cmd) {
        
        NSLog(@"4.Finish");
        NSLog(@"----- 4.Finish ------");
        
        NSMutableString* resultString = [[NSMutableString alloc] initWithString: @""];
        
        NEHotspotNetwork* network;
        if (cmd.commandType == kNEHotspotHelperCommandTypeEvaluate || cmd.commandType == kNEHotspotHelperCommandTypeFilterScanList) {
            // 遍历 WiFi 列表，打印基本信息
            for (network in cmd.networkList) {
                NSString* wifiInfoString = [[NSString alloc] initWithFormat: @"SSID: %@\nMac地址: %@\n信号强度: %f\nCommandType:%ld\n\n",
                                            network.SSID, network.BSSID, network.signalStrength, (long)cmd.commandType];
                NSLog(@"------ %@ ------",wifiInfoString);
                [resultString appendString: wifiInfoString];
                
//                // 检测到指定 WiFi 可设定密码直接连接
//                if ([network.SSID isEqualToString: @"测试 WiFi"]) {
//                    [network setConfidence: kNEHotspotHelperConfidenceHigh];
//                    [network setPassword: @"123456789"];
//                    NEHotspotHelperResponse *response = [cmd createResponse: kNEHotspotHelperResultSuccess];
//                    NSLog(@"Response CMD: %@", response);
//                    [response setNetworkList: @[network]];
//                    [response setNetwork: network];
//                    [response deliver];
//                }
            }
        }
        
        weakself.infoString = resultString;
    }];
    
    // 注册成功 returnType 会返回一个 Yes 值，否则 No
    NSString* logString = [[NSString alloc] initWithFormat: @"3.Result: %@", returnType == YES ? @"Yes" : @"No"];
    NSLog(@"%@", logString);
    self.textView.text = logString;
    
    return returnType;
    
}

- (void)scanTheWifiAndConnect{
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:@"Try here", kNEHotspotHelperOptionDisplayName, nil];
    
    dispatch_queue_t queue = dispatch_queue_create("come.Roam2freeJone.ShowWifi", 0);
    
    BOOL isAvailable = [NEHotspotHelper registerWithOptions:options queue:queue handler: ^(NEHotspotHelperCommand * cmd) {
        
        NSMutableArray *hotspotList = [NSMutableArray new];
        
        if(cmd.commandType == kNEHotspotHelperCommandTypeEvaluate || cmd.commandType == kNEHotspotHelperCommandTypeFilterScanList) {
            
            for (NEHotspotNetwork* network  in cmd.networkList) {
                
                if ([network.SSID isEqualToString:@"roam2free_dev_5G"]) {
                    
                    [network setConfidence:kNEHotspotHelperConfidenceHigh];
                    [network setPassword:@"mypassword"];
                    
                    NSLog(@"Confidence set to high for ssid: %@ (%@)\n\n", network.SSID, network.BSSID);
                    
                    [hotspotList addObject:network];
                }
            }
            
            NEHotspotHelperResponse *response = [cmd createResponse:kNEHotspotHelperResultSuccess];
            [response setNetworkList:hotspotList];
            [response deliver];
        }
    }];
    
}



@end
