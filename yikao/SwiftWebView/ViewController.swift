//
//  ViewController.swift
//  SwiftWebView
//

import UIKit
import WebKit

import Foundation
import UIKit
import WebViewJavascriptBridge



extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}


class ViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {

    let kredirectUrl = "http://ykcc.tudingsoft.com/api/auth/wb_callback"
    let screenWeith = UIScreen.main.bounds.size.width
    
    let screenHeight = UIScreen.main.bounds.size.height
    
    
    let kstatusBar  = UIApplication.shared.statusBarFrame.size.height
   
    var webView: WKWebView!
    var firstLoadPayUrl = true
    var appUrl = "http://ykcc-app.tudingsoft.com/#/home"
    var returnUrl = "http://youxin-app.tudingsoft.com/"
    var appScheme = "app.tljbhzs.com://"
    
    fileprivate lazy var loginBtn:UIButton = {
        let btn = UIButton()
        btn.setTitle("微博登录", for: .normal)
        btn.backgroundColor = UIColor.yellow
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        btn.addTarget(self, action: #selector(loginClick), for: .touchUpInside)
        return btn
    }()
    
    override func loadView() {
        super.loadView()
        registerFromKeyboardNotifications()
        
        self.view.backgroundColor = UIColor(hexString: "#ffffff")
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.mediaPlaybackRequiresUserAction = false
        webConfiguration.preferences.javaScriptCanOpenWindowsAutomatically = true
        webConfiguration.preferences.javaScriptEnabled = true
        webView = WKWebView(frame: CGRect(x:0, y:0, width:view.frame.size.width, height:view.frame.size.height),
                            configuration: webConfiguration)   // 20
        //        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.scrollView.bounces = false;
        webView.scrollView.showsVerticalScrollIndicator = false
        webView.scrollView.showsHorizontalScrollIndicator = false
        
        
        view.addSubview(webView)
        loginBtn.frame = CGRect(x: (screenWeith - 100)/2, y:(screenHeight - 40)/2, width: 100, height: 40)
        view.addSubview(loginBtn)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let dt = Date().timeIntervalSince1970
        
        let myURL = URL(string: appUrl + "?_v=\(Int(dt))")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
        
        
        /// 添加微博登录的回调
         NotificationCenter.default.addObserver(self, selector: #selector(notify(_:)), name: Notification.Name(rawValue: "weiboSuccess"), object: nil)
    }
    
    //    func preferredStatusBarStyle() -> UIStatusBarStyle {
    //        return UIStatusBarStyle.lightContent
    //    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    /// 微博登录
    @objc func loginClick(){
        let request = WBAuthorizeRequest.request() as! WBAuthorizeRequest
        request.redirectURI = kredirectUrl
        request.scope = "all"
        request.userInfo = ["SSO_From":"ViewController","Other_Info_1":"test"]
        WeiboSDK.send(request)
        
    }
    
    
    /// 微博登录成功的通知
    @objc fileprivate func notify(_ noti:Notification){
        let param = noti.userInfo
        
        let rep = param!["info"] as! WBBaseResponse
        print(rep.statusCode)
        print(rep.userInfo)
        
        let users = rep as! WBAuthorizeResponse
        
        print(users.accessToken)
        
        print(users.userID)
        
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        // 判断服务器采用的验证方法
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            if challenge.previousFailureCount == 0 {
                // 如果没有错误的情况下 创建一个凭证，并使用证书
                let credential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
                completionHandler(.useCredential, credential)
            } else {
                // 验证失败，取消本次验证
                completionHandler(.cancelAuthenticationChallenge, nil)
            }
        } else {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
    
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        //        if navigationAction.navigationType == .formSubmitted {
        
        if let url = navigationAction.request.url {
            
            if url.absoluteString.hasPrefix("alipay://") || url.absoluteString.hasPrefix("alipays://") ||
                url.absoluteString.hasPrefix("weixin://wap/pay")
            {
                firstLoadPayUrl = true
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url, completionHandler:{
                        success in
                        let myURL = URL(string: self.returnUrl)
                        let myRequest = URLRequest(url: myURL!)
                        self.webView.load(myRequest)
                    })
                }
                else {
                    UIApplication.shared.openURL(url)
                    let myURL = URL(string: returnUrl)
                    let myRequest = URLRequest(url: myURL!)
                    webView.load(myRequest)
                }
                
                decisionHandler(.allow)
                return
            }
            else if firstLoadPayUrl &&
                url.absoluteString.contains("wx.tenpay.com/") {
                firstLoadPayUrl = false
                var request = navigationAction.request
                request.addValue(appScheme, forHTTPHeaderField: "Referer")
                webView.load(request)
                decisionHandler(.cancel)
                return
            }
            else if url.scheme != nil && appScheme.contains(url.scheme!) {
                //                var request = navigationAction.request
                print("pay return")
                print(url)
                let _url = URL(string: url.absoluteURL.absoluteString.replacingOccurrences(of: appScheme, with: "http://"))
                print(_url!)
                firstLoadPayUrl = true
                //                webView.load(URLRequest(url: _url!))
                //                decisionHandler(.allow)
                
                let dt = Date().timeIntervalSince1970
                let myURL = URL(string: appUrl + "?_v=\(Int(dt))")
                let myRequest = URLRequest(url: myURL!)
                webView.load(myRequest)
                decisionHandler(.cancel)
                return
            }
        }
        firstLoadPayUrl = true
//        if (navigationAction.targetFrame != nil) {
//            webView.load(navigationAction.request)
//        }
        
        decisionHandler(.allow)
        
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let url = navigationAction.request.url,
            let _ = url.host, url.absoluteString.range(of: "/pay/payh5") != nil,
            UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.openURL(url)
        }
        return nil
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func registerFromKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func deregisterFromKeyboardNotifications(){
        //Removing notifies on keyboard appearing
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWasShown(notification: NSNotification){
        //Need to calculate keyboard exact size due to Apple suggestions
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        var frame : CGRect = self.webView.frame
        
        let y = frame.origin.y + frame.size.height - (self.view.frame.size.height - keyboardSize!.height)
        self.webView.frame = CGRect(x:0, y:statusBarHeight, width:frame.size.width, height:frame.size.height-statusBarHeight);
    }
    
    @objc func keyboardWillBeHidden(notification: NSNotification){
        //Once keyboard disappears, restore original positions
        print("KEYBOARD HIDDEN")
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        
        self.webView.frame = CGRect(x:0, y:statusBarHeight, width:self.view.frame.size.width, height:self.view.frame.size.height-statusBarHeight);
    }
    
}

