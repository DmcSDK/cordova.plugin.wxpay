# cordova.plugin.wxpay

cordova 微信支付插件

```npm
 cordova plugin add https://github.com/DmcSDK/cordova.plugin.wxpay.git --variable WXAPPID=公众账号ID
```

## Example
```js
       cordova.plugins.WXpay.pay(data,(s)=>{
	  //成功
       },(e)=>{
	  //失败
       });  
```
```js
	# data参数说明：格式为JSON格式
	{
	appid: 公众账号ID
	noncestr: 随机字符串
	partnerid: 商户号
	prepayid: 预支付交易会话ID
	timestamp: 时间戳
	sign: 签名
	}
```
