/********* WxpayPlugin.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>
#import "WxpayPlugin.h"
@implementation WxpayPlugin


- (void)pay:(CDVInvokedUrlCommand*)command
{
    @try {
        
        callbackId = command.callbackId;
        NSDictionary *params = [command.arguments objectAtIndex:0];
        [WXApi registerApp:[params objectForKey:@"appid"]];
        PayReq* req             = [[[PayReq alloc] init]init];
        req.partnerId           = [params objectForKey:@"mch_id"];
        req.prepayId            = [params objectForKey:@"prepay_id"];
        req.nonceStr            = [params objectForKey:@"nonce_str"];
        req.timeStamp           = [[params objectForKey:@"timestamp"]intValue];
        req.sign                = [params objectForKey:@"sign"];
        req.package             = @"Sign=WXPay";

        [WXApi sendReq:req];
    } @catch (NSException *exception) {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"params erro"];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

-(void)onResp:(BaseResp*)resp{
    if([resp isKindOfClass:[PayResp class]]){
        //支付返回结果，实际支付结果需要去微信服务器端查询
        NSString *strMsg = [NSString stringWithFormat:@"支付结果"];
        if(resp.errCode==WXSuccess){
            strMsg = @"支付结果：成功！";
            NSLog(@"支付成功－PaySuccess，retcode = %d", resp.errCode);
            CDVPluginResult *pluginResultOk = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:strMsg];
            [self.commandDelegate sendPluginResult:pluginResultOk callbackId:callbackId];
        }else{
            strMsg = [NSString stringWithFormat:@"支付结果：失败！retcode = %d, retstr = %@", resp.errCode,resp.errStr];
            NSLog(@"错误，retcode = %d, retstr = %@", resp.errCode,resp.errStr);
            CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:strMsg];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
        }
    }
}

- (id)settingForKey:(NSString*)key
{
    return [self.commandDelegate.settings objectForKey:[key lowercaseString]];
}

- (void)handleOpenURL:(NSNotification *)notification {
    NSURL *url = [notification object];
    if ([url isKindOfClass:[NSURL class]] && [url.scheme isEqualToString:[self settingForKey: @"wxappid"]]) {
        [WXApi handleOpenURL:url delegate:self];
    }
}


@end

