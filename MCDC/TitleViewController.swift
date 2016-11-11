//
//  ViewController.swift
//  MCDC
//
//  Created by x13089xx on 2016/07/24.
//  Copyright © 2016年 Kosuke Nakamura. All rights reserved.
//

import UIKit

/**
 * タイトル画面
 */
class TitleViewController: UIViewController, UITextFieldDelegate {  // TextFieldでReturnを押したときに処理をするため UITextFieldDelegate を追加
    
    @IBOutlet var roomTextField: UITextField!
    @IBOutlet var userTextField: UITextField!
    @IBOutlet var startButton: UIButton!
    
    var logoutState: Bool = false
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // キーボードの種類を変更
        roomTextField.keyboardType = .ASCIICapable
        userTextField.keyboardType = .ASCIICapable
        // ReturnキーをDoneに変更
        roomTextField.returnKeyType = .Done
        userTextField.returnKeyType = .Done
        
        // NSNotificationCenterでUITextFieldTextDidChangeNotificationの通知を受け取ることで文字入力したことを検出
        NSNotificationCenter.defaultCenter().addObserver(
            self, selector: #selector(TitleViewController.textFieldDidChange(_:)),
            name: UITextFieldTextDidChangeNotification,
            object: roomTextField)
        
        NSNotificationCenter.defaultCenter().addObserver(
            self, selector: #selector(TitleViewController.textFieldDidChange(_:)),
            name: UITextFieldTextDidChangeNotification,
            object: userTextField)
        //--------------------
        // 読み込み処理を追加
        //--------------------
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let roomName = userDefaults.objectForKey("room") as? String {
            roomTextField.text = roomName
        }
        if let userName = userDefaults.objectForKey("user") as? String {
            userTextField.text = userName
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        //--------------------
        // 読み込み処理を追加
        //--------------------
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let logState: Bool = userDefaults.boolForKey("logState") {
            logoutState = logState
            //--------------------
            // 保存処理を追加
            //--------------------
            userDefaults.setBool(false, forKey: "logState")
            userDefaults.synchronize()
        }
        // PeerToPeerViewControllerから戻って来たとき
        if logoutState == true {
            // アラートダイアログ生成
            let alertController = UIAlertController(title: "Logout",
                                                    message: "ログアウトしました。",
                                                    preferredStyle: UIAlertControllerStyle.Alert)
            // OKボタンがタップされたときの処理
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                (action: UIAlertAction) -> Void in
                self.logoutState = false
            }
            // OKボタンを追加
            alertController.addAction(okAction)
            
            // アラートダイアログを表示
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    deinit {
        // 登録したオブサーバを解除
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    /**
     * TextFieldに変化があった際に呼ばれる処理
     */
    func textFieldDidChange(notification: NSNotification) {
        // 最大文字数
        let maxLength: Int = 15  // ASCllの小文字、数字、ハイフンのみで1~15文字以内(userNameはUTF-8の文字列で63byte以内)
        let textField = notification.object as! UITextField
        if let text = textField.text {
            // 最大文字数を超えた分は切り落とす（markedTextRangeで入力し終えた後に切り落とす）
            if textField.markedTextRange == nil && text.characters.count >= maxLength {
                textField.text = text.substringToIndex(text.startIndex.advancedBy(maxLength))
            }
        }
    }
    
    /**
     * TextFieldでReturnを押した際に呼ばれる処理
     */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // 空白文字かどうか確認する処理
        if checkTextField(roomTextField.text!) == true && checkTextField(userTextField.text!) == true {
            // NSUserDefaultsに保存
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setObject(roomTextField.text, forKey: "room")
            userDefaults.setObject(userTextField.text, forKey: "user")
            userDefaults.synchronize()
            
            // Startボタンを表示
            startButton.hidden = false
            // キーボードを閉じる
            textField.resignFirstResponder()
        } else {
            // Startボタンを非表示
            startButton.hidden = true
        }
        return true
    }
    
//    /**
//     * Textが編集された際に呼ばれる処理
//     */
//    func textField(textField: UITextField, shouldChangeCharactersInRangee range: NSRange, replacementString string: String) -> Bool {
//        // 最大文字数
//        let roomMaxLength: Int = 15
//        let userMaxLength: Int = 32
//        
//        // 文字数が各maxLength以下ならtrueを返す
//        if roomTextField.text!.characters.count <= roomMaxLength && userTextField.text!.characters.count <= userMaxLength {
//            return true
//        }
//        return false
//    }
    
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

}

