package com.dmc.wxpay;

import android.util.Log;

import com.tencent.mm.opensdk.modelbase.BaseResp;
import com.tencent.mm.opensdk.modelpay.PayReq;
import com.tencent.mm.opensdk.openapi.IWXAPI;
import com.tencent.mm.opensdk.openapi.WXAPIFactory;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaPlugin;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

/**
 * This class echoes a string called from JavaScript.
 */
public class WxpayPlugin extends CordovaPlugin {

    static CallbackContext payCallback;
    public static String appId;

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        if (action.equals("pay")) {
            Log.e("wxpay", "pay============= " + args.getJSONObject(0));
            payCallback = callbackContext;
            this.pay(args.getJSONObject(0));
            return true;
        }
        return false;
    }

    private void pay(final JSONObject json) {
        try {
            appId = json.getString("appid");
            final IWXAPI api = WXAPIFactory.createWXAPI(cordova.getActivity(), json.getString("appid"));
            api.registerApp(json.getString("appid"));
            cordova.getThreadPool().execute(new Runnable() {
                @Override
                public void run() {
                    PayReq req = new PayReq();
                    try {
                        req.appId = json.getString("appid");
                        req.partnerId = json.getString("mch_id");
                        req.prepayId = json.getString("prepay_id");
                        req.packageValue = "Sign=WXPay";
                        req.nonceStr = json.getString("nonce_str");
                        req.timeStamp = json.getString("timestamp");
                        req.sign = json.getString("sign");
                    } catch (JSONException e) {
                        e.printStackTrace();
                    }
                    api.sendReq(req);
                }
            });
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void sendResult(BaseResp resp) {
        try {

            JSONObject result = new JSONObject();
            result.put("errCode", resp.errCode);
            result.put("errStr", resp.errStr);
            result.put("transaction", resp.transaction);
            result.put("openId", resp.openId);
            if (0 == resp.errCode) {
                payCallback.success(result);
            } else {
                payCallback.error(result);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
