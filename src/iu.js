#!/usr/bin/env node

module.exports = function(context) {
    var path = context.requireCordovaModule('path'), //node的模块
        fs = context.requireCordovaModule('fs'),
        shell = context.requireCordovaModule('shelljs'),
        projectRoot = context.opts.projectRoot,
        plugins = context.opts.plugins || [];

    // 判断调用此脚本时加载或者卸载的插件是否是当前微信插件
    if (plugins.length > 0 && plugins.indexOf('cordova.plugin.wxpay.dmcbig') === -1) {
        return;
    }

    var ConfigParser = null; //获取config.xml实例
    try {
        ConfigParser = context.requireCordovaModule('cordova-common').ConfigParser;
    } catch (e) {
        // fallback
        ConfigParser = context.requireCordovaModule('cordova-lib/src/configparser/ConfigParser');
    }

    var config = new ConfigParser(path.join(context.opts.projectRoot, "config.xml")),
        packageName = config.android_packageName() || config.packageName(); //获取包名

    // replace dash (-) with underscore (_)
    packageName = packageName.replace(/-/g, "_");

    console.info("Running android-install.Hook: " + context.hook + ", Package: " + packageName + ", Path: " + projectRoot + ".");

    if (!packageName) {
        console.error("Package name could not be found!");
        return;
    }

    //判断是否是android插件，否则不需要执行此插件
    if (context.opts.cordova.platforms.indexOf("android") === -1) {
        console.info("Android platform has not been added.");
        return;
    }

    //获取要生成WXActivity和WXPayEntry的目录
    var targetDir = path.join(projectRoot, "platforms", "android", "src", packageName.replace(/\./g, path.sep), "wxapi");
    targetFiles = ["WXPayEntryActivity.java"];

    //如果卸载插件时，删除原有的Activity
    if (['after_plugin_add', 'after_plugin_install'].indexOf(context.hook) === -1) {
        targetFiles.forEach(function(f) {
            try {
                fs.unlinkSync(path.join(targetDir, f));
            } catch (err) {}
        });
        try{fs.rmdirSync(targetDir);}catch (err) {}
    } else {
        // create directory
        shell.mkdir('-p', targetDir);

        // sync the content
        targetFiles.forEach(function(f) {
            fs.readFile(path.join(context.opts.plugin.dir, 'src', 'android', f), { encoding: 'utf-8' }, function(err, data) {
                if (err) {
                    throw err;
                }
                //替换包名
                data = data.replace(/^package __PACKAGE_NAME__;/m, 'package ' + packageName + '.wxapi;');
                //将两个activity写入到指定的目录
                fs.writeFileSync(path.join(targetDir, f), data);
            });
        });
    }
};