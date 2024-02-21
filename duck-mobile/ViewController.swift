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
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
            }
        }
    }

    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        var message: String
        if let error = error {
            message = "保存失败，错误：\(error.localizedDescription)"
        } else {
            message = "图片已成功保存到相册"
        }
        // 向网页发送消息，通知保存状态
        let jsScript = "window.BridgeInterface.handleSaveResult('\(message)');"
        webView.evaluateJavaScript(jsScript, completionHandler: nil)
    }
}

