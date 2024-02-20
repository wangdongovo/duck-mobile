//
//  ViewController.swift
//  duck-mobile
//
//  Created by wd on 2024/2/20.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKScriptMessageHandler {

    var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.userContentController.add(self, name: "saveImage")

        webView = WKWebView(frame: self.view.frame, configuration: webConfiguration)
        self.view.addSubview(webView)

        if let url = URL(string: "http://192.168.220.208:3000") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "saveImage", let base64String = message.body as? String {
            print("Received message from web: \(base64String)")
            saveBase64ImageToAlbum(base64String: base64String)
        }
    }

    func saveBase64ImageToAlbum(base64String: String) {
        if let imageData = Data(base64Encoded: base64String) {
            if let image = UIImage(data: imageData) {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            }
        }
    }
}

