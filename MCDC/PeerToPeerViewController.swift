//
//  P2PViewController.swift
//  MCDC
//
//  Created by x13089xx on 2016/07/24.
//  Copyright © 2016年 Kosuke Nakamura. All rights reserved.
//

import UIKit
import MultipeerConnectivity

/**
 * MultipeerConnectivityでデータの送受信を行う
 */
class PeerToPeerViewController: UIViewController, MCBrowserViewControllerDelegate, MCSessionDelegate, UITextFieldDelegate {
    
    @IBOutlet var messageField: UITextField!
    @IBOutlet var chatView: UITextView!
    @IBOutlet weak var roomNameNavigationItem: UINavigationItem!
    
    var serviceType = "id-number"  // ピア検索の際にアドバタイズされているサービスを識別するためのプロパティ
    
    var browser : MCBrowserViewController!  // Advertiserを見つけて接続を確立する
    var assistant : MCAdvertiserAssistant!  //　自身を周囲に知らせる
    var session : MCSession!  // P2P通信のセッションをコントロールする
    var peerID: MCPeerID!  // ピアの識別子を表す
    
    var myName: String = ""
    
    let fileManager = NSFileManager.defaultManager()
    let dateFormatter = NSDateFormatter()
    
    // 各種アイコン
    let twitterImage: UIImage = UIImage(named: "Twitter")!
    let facebookImage: UIImage = UIImage(named: "Facebook")!
    let urlImage: UIImage = UIImage(named: "URL")!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        // ディレクトリを削除する
//        try! self.fileManager.removeItemAtPath(self.getDocumentsDirectory() as String)//(self.getDocumentsDirectory() as String) + "/" + "20161017_user01")
        
        // ReturnキーをDoneに変更
        messageField.returnKeyType = .Done
        
        // 時刻の表示設定を追加
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        
        //--------------------
        // 読み込み処理を追加
        //--------------------
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let roomName = userDefaults.objectForKey("room") as? String {
            serviceType = roomName
            // 部屋名を表示
            roomNameNavigationItem.title = roomName
        }
        if let userName = userDefaults.objectForKey("user") as? String {
            myName = userName
            self.peerID = MCPeerID(displayName: myName)
        } else {
            myName = UIDevice.currentDevice().name
            self.peerID = MCPeerID(displayName: myName)
        }
        
        //--------------------
        // 保存処理を追加
        //--------------------
        userDefaults.setBool(true, forKey: "logState")
        userDefaults.synchronize()
        
        self.session = MCSession(peer: peerID)
        self.session.delegate = self
        
        self.browser = MCBrowserViewController(serviceType:serviceType, session:self.session)
        self.browser.delegate = self;
        self.assistant = MCAdvertiserAssistant(serviceType:serviceType, discoveryInfo:nil, session:self.session)
        
        self.assistant.start()  // 周囲のデバイスに通信可能だと知らせる
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /**
     * データを送信する処理
     */
    @IBAction func tapDataSend(sender: AnyObject) {
        var error: NSError?
        
        //----------------------------------------
        // MyDataディレクトリにあるファイル一覧を取得
        //----------------------------------------
        let myDataPath: String = (self.getDocumentsDirectory() as String) + "/" + "MyData"
        
        // ファイルが存在する場合
        if fileManager.fileExistsAtPath(myDataPath) {
            // Documentsの中身を取得する
            fileManager.subpathsAtPath(myDataPath)?.forEach {
                let imagePath: String = myDataPath + "/" + $0
                let imageData: UIImage = UIImage(contentsOfFile: imagePath)!
                // 選択した写真をNSData型に変換
                let selectedImage = UIImageJPEGRepresentation(imageData, 1.0)
                
                //--------------------
                // データ送信
                //--------------------
                do {
                    if checkDataType($0) == "Facebook" || checkDataType($0) == "Twitter" || checkDataType($0) == "URL" {
                        // リンクの場合
                        let link: NSData = $0.dataUsingEncoding(NSUTF8StringEncoding)!
                        try self.session.sendData(link,
                            toPeers: self.session.connectedPeers,
                            withMode: MCSessionSendDataMode.Unreliable)
                        self.chatView.text = self.chatView.text + "リンクを送信しています...\n"  // 送信通知
                    } else {
                        // 画像の場合
                        try self.session.sendData(selectedImage!,
                            toPeers: self.session.connectedPeers,
                            withMode: MCSessionSendDataMode.Unreliable)
                        self.chatView.text = self.chatView.text + "画像を送信しています...\n"  // 送信通知
                    }
                } catch let error2 as NSError {
                    error = error2
                }
                if error != nil {
                    print("Error sending data: \(error?.localizedDescription)", terminator: "")
                    self.updateChat("送信に失敗しました", fromPeer: peerID)  // エラー通知
                }
            }
            self.chatView.text = self.chatView.text + "データ送信が完了しました！\n"  // 送信完了の通知
        }
    }
    
    /**
     * メッセージを送信する処理
     */
    @IBAction func tapSendButton(sender: AnyObject) {
        // 空白文字でなければ送信して空白に戻す処理
        if checkTextField(messageField.text!) == true {
            let message = self.messageField.text!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
            
            var error: NSError?
            
            do {
                try self.session.sendData(message!, toPeers: self.session.connectedPeers, withMode: MCSessionSendDataMode.Unreliable)
            } catch let error2 as NSError {
                error = error2
            }
            
            if error != nil {
                print("Error sending data: \(error?.localizedDescription)", terminator: "")
            }
            
            // 送信する
            self.updateChat(self.messageField.text!, fromPeer: self.peerID)
            
            self.messageField.text = ""
        }
    }
    
    /**
     * TextFieldでReturnを押した際に呼ばれる処理
     */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // キーボードを閉じる
        textField.resignFirstResponder()
        return true
    }
    
    /**
     * browserに画面遷移する処理
     */
    @IBAction func tapBrowserButton(sender: AnyObject) {
        self.presentViewController(self.browser, animated: true, completion: nil)
    }
    
    /**
     * Doneで戻る処理
     */
    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
     * Cancellで戻る処理
     */
    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /**
     * NSDataを受信する処理
     */
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        dispatch_async(dispatch_get_main_queue()) {
            let date = NSDate()
            let currentTime = self.dateFormatter.stringFromDate(date)
            let folderName: String = currentTime.substringToIndex(currentTime.startIndex.advancedBy(8)) + "_" + String(peerID.displayName)  // 例：20161018_username
            // ディレクトリのパス
            let folderPath = (self.getDocumentsDirectory() as String) + "/" + folderName
            
            // ディレクトリが存在しない場合
            if !self.fileManager.fileExistsAtPath(folderPath) {
                //ディレクトリを作成する
                try! self.fileManager.createDirectoryAtPath(folderPath, withIntermediateDirectories: true, attributes: nil)
            }
            
            print("\(data)")  // 確認
            
            if NSString(data: data, encoding: NSUTF8StringEncoding) != nil {
                //--------------------
                // 文字列の場合
                //--------------------
                let msg: String = NSString(data: data, encoding: NSUTF8StringEncoding) as! String  // 相手からのメッセージ
                if self.checkDataType(msg) == "Facebook" {
                    //--------------------
                    // Facebookの場合
                    //--------------------
                    let facebookID: String = msg.substringFromIndex(msg.startIndex.advancedBy(9))
                    let fileName: String = "Facebook_" + facebookID  // 例：Facebook_id
                    // ファイルのパス
                    let filePath = (self.getDocumentsDirectory() as String) + "/" + folderName + "/" + fileName
                    // アイコンをNSDataに置き換える
                    let facebookNSData: NSData = UIImageJPEGRepresentation(self.facebookImage, 1.0)!
                    //----------------------------------------
                    // WriteToFile で Documents に保存する
                    //----------------------------------------
                    let success = facebookNSData.writeToFile(filePath, atomically: true)
                    // 確認
                    if success {
                        print("Save OK")
                        self.updateChat("FacebookIDの送信に成功しました", fromPeer: peerID)  // 受け取ったことを通知
                    } else {
                        print("Save Error")
                        self.updateChat("FacebookIDの送信に失敗しました", fromPeer: peerID)
                    }
                } else if self.checkDataType(msg) == "Twitter" {
                    //--------------------
                    // Twitterの場合
                    //--------------------
                    let twitterID: String = msg.substringFromIndex(msg.startIndex.advancedBy(8))
                    let fileName: String = "Twitter_" + twitterID  // 例：Twitter_id
                    // ファイルのパス
                    let filePath = (self.getDocumentsDirectory() as String) + "/" + folderName + "/" + fileName
                    // アイコンをNSDataに置き換える
                    let twitterNSData: NSData = UIImageJPEGRepresentation(self.twitterImage, 1.0)!
                    //----------------------------------------
                    // WriteToFile で Documents に保存する
                    //----------------------------------------
                    let success = twitterNSData.writeToFile(filePath, atomically: true)
                    // 確認
                    if success {
                        print("Save OK")
                        self.updateChat("TwitterIDの送信に成功しました", fromPeer: peerID)  // 受け取ったことを通知
                    } else {
                        print("Save Error")
                        self.updateChat("TwitterIDの送信に失敗しました", fromPeer: peerID)
                    }
                } else if self.checkDataType(msg) == "URL" {
                    //--------------------
                    // URLの場合
                    //--------------------
                    let urlID: String = msg.substringFromIndex(msg.startIndex.advancedBy(4))
                    let fileName: String = "URL_" + urlID  // 例：URL_id
                    // ファイルのパス
                    let filePath = (self.getDocumentsDirectory() as String) + "/" + folderName + "/" + fileName
                    // アイコンをNSDataに置き換える
                    let urlNSData: NSData = UIImageJPEGRepresentation(self.urlImage, 1.0)!
                    //----------------------------------------
                    // WriteToFile で Documents に保存する
                    //----------------------------------------
                    let success = urlNSData.writeToFile(filePath, atomically: true)
                    // 確認
                    if success {
                        print("Save OK")
                        self.updateChat("URLの送信に成功しました", fromPeer: peerID)  // 受け取ったことを通知
                    } else {
                        print("Save Error")
                        self.updateChat("URLの送信に失敗しました", fromPeer: peerID)
                    }
                } else {
                    //--------------------
                    // チャットの場合
                    //--------------------
                    self.updateChat(msg, fromPeer: peerID)  // updateChatメソッドで処理する
                }
            } else if UIImage(data: data) != nil {
                //--------------------
                // 画像の場合
                //--------------------
                // 保存名を設定する
                let fileName: String = "Picture_" + currentTime  // 例：Picture_20161013012733
                // ファイルのパス
                let filePath = (self.getDocumentsDirectory() as String) + "/" + folderName + "/" + fileName
                // 受信した画像をNSDataに置き換える
                let receivedImage = UIImage(data: data)
                let imageData = UIImageJPEGRepresentation(receivedImage!, 1.0)
                //----------------------------------------
                // WriteToFile で Documents に保存する
                //----------------------------------------
                let success = imageData!.writeToFile(filePath, atomically: true)
                // 確認
                if success {
                    print("Save OK")
                    self.updateChat("画像の送信に成功しました", fromPeer: peerID)
                } else {
                    print("Save Error")
                    self.updateChat("画像の送信に失敗しました", fromPeer: peerID)
                }
            } else {
                print(data.dynamicType)
            }
        }
    }
    
    /**
     * 受信したデータの処理
     */
    func updateChat(text: String, fromPeer peerID: MCPeerID) {
        var name : String
        
        switch peerID {
        case self.peerID:
            name = myName  // 自分
        default:
            name = peerID.displayName  // 相手
        }
        
        let message = "\(name): \(text)\n"
        self.chatView.text = self.chatView.text + message  // メッセージ更新
        
        /*
         Error sending data: Optional("Invalid peerIDs parameter")
         
         というエラーはpeerIDが見つからない。つまり、acceptしているもう一つの端末が見つかっていないという意味。
         2台以上の端末で通信できた時に送信するとこのエラーメッセージは消える！
         */
    }
    
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
    }
    
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
    }
    
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
    }
    
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
    }
    
    /**
     * 空白文字かどうか確認する処理
     */
    func checkTextField(text: String) -> Bool {
        // 前後の空白文字を削除する要素を追加
        let checkedText = text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        if checkedText != "" {
            return true
        }
        return false
    }
    
    /**
     * 文字列がどの種類に属するか確認してそれぞれの種類名で返す処理
     */
    func checkDataType(data: String) -> String {
        if data.characters.count >= 8 && data.substringToIndex(data.startIndex.advancedBy(8)) == "Facebook" {
            return "Facebook"
        } else if data.characters.count >= 7 && data.substringToIndex(data.startIndex.advancedBy(7)) == "Twitter" {
            return "Twitter"
        } else if data.characters.count >= 3 && data.substringToIndex(data.startIndex.advancedBy(3)) == "URL" {
            return "URL"
        }
        return data
    }
    
    /**
     * ドキュメントディレクトリを参照するメソッド
     */
    func getDocumentsDirectory() -> NSString {
        let documentsPath: NSString = NSSearchPathForDirectoriesInDomains(
            NSSearchPathDirectory.DocumentDirectory,
            NSSearchPathDomainMask.UserDomainMask, true).first!  // [0]ではなく.firstを使用すると中身が空の際に nil を返してくれる
        return documentsPath
    }

}





