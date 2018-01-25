//
//  CDVWxpay.h
//  cordova-plugin-wxpay
//
//  Created by tong.wu on 06/30/15.
//
//

#import <Cordova/CDV.h>
#import "WXApi.h"
#import "WXApiObject.h"

@interface WxpayPlugin:CDVPlugin <WXApiDelegate>{
	  NSString *callbackId;
}

- (void)pay:(CDVInvokedUrlCommand*)command;

@end