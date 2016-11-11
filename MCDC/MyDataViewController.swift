//
//  MyDataViewController.swift
//  MCDC
//
//  Created by x13089xx on 2016/07/30.
//  Copyright © 2016年 Kosuke Nakamura. All rights reserved.
//

import UIKit

/**
 * 送信するデータを選択する
 */
class MyDataViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let fileManager = NSFileManager.defaultManager()
    let dateFormatter = NSDateFormatter()
    
    // 文字を格納した配列
    var labelList: [String] = [String]()
    // 画像を格納した配列
    var imageList: [UIImage] = [UIImage]()
    
    // 各種アイコン
    let twitterImage: UIImage = UIImage(named: "Twitter")!
    let facebookImage: UIImage = UIImage(named: "Facebook")!
    let urlImage: UIImage = UIImage(named: "URL")!
    
    // resizeか判断する
    var resizeCheck: Int = 1
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // セルの高さを自動調整
        self.tableView.estimatedRowHeight = 90
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        // 時刻の表示設定を追加
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
        dateFormatter.dateFormat = "yyyyMMddHHmmss"
        
        //----------------------------------------
        // ディレクトリにあるファイル一覧を取得
        //----------------------------------------
        let myDataPath: String = getMydataDirectory() as String
        
        // ファイルが存在しない場合、ディレクトリを作成する
        if !fileManager.fileExistsAtPath(myDataPath) {
            try! self.fileManager.createDirectoryAtPath(myDataPath, withIntermediateDirectories: true, attributes: nil)
        }
        // MyDataディレクトリの中身を取得する
        fileManager.subpathsAtPath(myDataPath)?.forEach {
            // MyDataのデータを順にlabelListに格納する
            self.labelList.insert($0, atIndex: 0)
            // imageDataに格納する
            let imagePath: String = getMydataDirectory().stringByAppendingPathComponent($0)
            let imageData: UIImage = UIImage(contentsOfFile: imagePath)!
            self.imageList.insert(imageData, atIndex: 0)
        }
        // 確認
        print("labelList.count: ", self.labelList.count)
        print("imageList.count: ", self.imageList.count)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        print("resizeCheck：", resizeCheck)
        if resizeCheck == 2 || resizeCheck == 4 || resizeCheck == 8 {
            resizeCheck = 1
            print(resizeCheck)
        }
    }
    
    /**
     * ＋ボタンを押した際の処理
     */
    @IBAction func tapAddButton(sender: AnyObject) {
        // アラートダイアログ生成
        let alertController = UIAlertController(title: "データの種類を選択",
                                                message: "送信するデータの種類を選択してください",
                                                preferredStyle: UIAlertControllerStyle.ActionSheet)
        // Pictureボタンがタップされたときの処理
        let pictureAction = UIAlertAction(title: "Picture", style: UIAlertActionStyle.Default) {
            (action: UIAlertAction) -> Void in
            // Pictureボタンが押されたときの処理を呼び出す
            self.choosePictureAction()
        }
        // Pictureボタンを追加
        alertController.addAction(pictureAction)
        
        // PDFボタンがタップされたときの処理
        let pdfAction = UIAlertAction(title: "PDF", style: UIAlertActionStyle.Default) {
            (action: UIAlertAction) -> Void in
            // PDFボタンが押されたときの処理を呼び出す
            self.choosePDFAction()
        }
        // PDFボタンを追加
        alertController.addAction(pdfAction)
        
        // Soundボタンを追加
        let soundAction = UIAlertAction(title: "Sound", style: UIAlertActionStyle.Default) {
            (action: UIAlertAction) -> Void in
            // Soundボタンが押されたときの処理を呼び出す
            self.chooseSoundAction()
        }
        // Soundボタンを追加
        alertController.addAction(soundAction)
        
        // Linkボタンを追加
        let linkAction = UIAlertAction(title: "Link", style: UIAlertActionStyle.Default) {
            (action: UIAlertAction) -> Void in
            // Linkボタンが押されたときの処理を呼び出す
            self.chooseLinkAction()
        }
        // Linkボタンを追加
        alertController.addAction(linkAction)
        
        // キャンセルボタンがタップされたときの処理
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: UIAlertActionStyle.Cancel,
                                         handler: nil)
        // キャンセルボタンを追加
        alertController.addAction(cancelAction)
        
        // アラートダイアログを表示
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    /**
     * pictureActionを選択した際の処理
     */
    func choosePictureAction() {
        // アラートダイアログ生成
        let alertController = UIAlertController(title: "解像度を選択",
                                                message: "送信する画像の解像度を選択してください",
                                                preferredStyle: UIAlertControllerStyle.ActionSheet)
        // Originalボタンがタップされたときの処理
        let originalAction = UIAlertAction(title: "Original", style: UIAlertActionStyle.Default) {
            (action: UIAlertAction) -> Void in
            // Originalボタンが押されたときの処理を呼び出す
            self.imagePicker()
        }
        // Resize(1/2)ボタンがタップされたときの処理
        let resizeOneHarfAction = UIAlertAction(title: "Resize(1/2)", style: UIAlertActionStyle.Default) {
            (action: UIAlertAction) -> Void in
            // Resizeボタンが押されたときの処理を呼び出す
            self.resizeCheck = 2
            self.imagePicker()
        }
        // Resize(1/4)ボタンがタップされたときの処理
        let resizeOneQuarterAction = UIAlertAction(title: "Resize(1/4)", style: UIAlertActionStyle.Default) {
            (action: UIAlertAction) -> Void in
            // Resizeボタンが押されたときの処理を呼び出す
            self.resizeCheck = 4
            self.imagePicker()
        }
        // Resize(1/8)ボタンがタップされたときの処理
        let resizeOneEighthAction = UIAlertAction(title: "Resize(1/8)", style: UIAlertActionStyle.Default) {
            (action: UIAlertAction) -> Void in
            // Resizeボタンが押されたときの処理を呼び出す
            self.resizeCheck = 8
            self.imagePicker()
        }
        // Originalボタンを追加
        alertController.addAction(originalAction)
        // Resize(1/2)ボタンを追加
        alertController.addAction(resizeOneHarfAction)
        // Resize(1/4)ボタンを追加
        alertController.addAction(resizeOneQuarterAction)
        // Resize(1/8)ボタンを追加
        alertController.addAction(resizeOneEighthAction)
        
        // アラートダイアログを表示
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    /**
     * 写真選択メソッド
     */
    func imagePicker() {
        // 写真を選択する
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            // 写真ライブラリ表示用のViewControllerを宣言
            let controller = UIImagePickerController()
            
            controller.delegate = self  // 許可
            
            // controllerをカメラロールで表示（カメラの場合は.Camera）
            controller.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            
            // controllerの表示をpresentViewControllerにする
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    /**
     * pdfActionを選択した際の処理
     */
    func choosePDFAction() {
        print("PDF")
    }
    
    /**
     * soundActionを選択した際の処理
     */
    func chooseSoundAction() {
        print("Sound")
    }
    
    /**
     * linkActionを選択した際の処理(　注意：禁止文字が含まれているとディレクトリに保存できない！　)
     */
    func chooseLinkAction() {
        // アラートダイアログ生成
        let alertController = UIAlertController(title: "リンク先を追加",
                                                message: "リンク先を入力して種類を選択してください",
                                                preferredStyle: UIAlertControllerStyle.Alert)
        // テキストエリアを追加
        alertController.addTextFieldWithConfigurationHandler(nil)
        
        // Facebookボタンを追加
        let faceBookAction = UIAlertAction(title: "Facebook", style: UIAlertActionStyle.Default) {
            (action: UIAlertAction) -> Void in
            // Facebookボタンが押されたときの処理
            if let textField = alertController.textFields?.first {
                // 空白文字かどうか確認する処理
                if self.checkTextField(textField.text!) == true {
                    let filename: String = "Facebook_" + textField.text!  // Facebook_username  // facebook.com/username
                    // 選択した写真をNSData型に変換
                    let imageData = UIImageJPEGRepresentation(self.facebookImage, 1.0)
                    let filePath = self.getMydataDirectory().stringByAppendingPathComponent(filename)
                    
                    // 値の挿入・行追加をテーブルへ通知する
                    self.insertData(filename, image: self.facebookImage)
                    
                    //----------------------------------------
                    // WriteToFile で MyData に保存する
                    //----------------------------------------
                    let success = imageData!.writeToFile(filePath, atomically: true)
                    // 確認
                    if success {
                        print("Save OK")
                    } else {
                        print("Save Error")
                    }
                }
            }
        }
        // Facebookボタンを追加
        alertController.addAction(faceBookAction)
        
        // Twitterボタンを追加
        let twitterAction = UIAlertAction(title: "Twitter", style: UIAlertActionStyle.Default) {
            (action: UIAlertAction) -> Void in
            // Twitterボタンが押されたときの処理
            if let textField = alertController.textFields?.first {
                // 空白文字かどうか確認する処理
                if self.checkTextField(textField.text!) == true {
                    let filename: String = "Twitter_" + textField.text!  // Twitter_username  // twitter://user?screen_name=username
                    // 選択した写真をNSData型に変換
                    let imageData = UIImageJPEGRepresentation(self.twitterImage, 1.0)
                    let filePath = self.getMydataDirectory().stringByAppendingPathComponent(filename)
                    
                    // 値の挿入・行追加をテーブルへ通知する
                    self.insertData(filename, image: self.twitterImage)
                    
                    //----------------------------------------
                    // WriteToFile で MyData に保存する
                    //----------------------------------------
                    let success = imageData!.writeToFile(filePath, atomically: true)
                    // 確認
                    if success {
                        print("Save OK")
                    } else {
                        print("Save Error")
                    }
                }
            }
        }
        // Twitterボタンを追加
        alertController.addAction(twitterAction)
        
        // URLボタンを追加
        let urlAction = UIAlertAction(title: "URL", style: UIAlertActionStyle.Default) {
            (action: UIAlertAction) -> Void in
            // URLボタンが押されたときの処理
            if let textField = alertController.textFields?.first {
                // 空白文字かどうか確認する処理
                if self.checkTextField(textField.text!) == true {
                    let filename: String = "URL_" + textField.text!  // URL_username
                    // 選択した写真をNSData型に変換
                    let imageData = UIImageJPEGRepresentation(self.urlImage, 1.0)
                    let filePath = self.getMydataDirectory().stringByAppendingPathComponent(filename)
                    
                    // 値の挿入・行追加をテーブルへ通知する
                    self.insertData(filename, image: self.urlImage)
                    
                    //----------------------------------------
                    // WriteToFile で MyData に保存する
                    //----------------------------------------
                    let success = imageData!.writeToFile(filePath, atomically: true)
                    // 確認
                    if success {
                        print("Save OK")
                    } else {
                        print("Save Error")
                    }
                }
            }
        }
        // URLボタンを追加
        alertController.addAction(urlAction)
        
        // キャンセルボタンがタップされたときの処理
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: UIAlertActionStyle.Cancel,
                                         handler: nil)
        // キャンセルボタンを追加
        alertController.addAction(cancelAction)
        
        // アラートダイアログを表示
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    /**
     * テーブルの行数を返却する
     */
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // labelListの配列の長さを返却する
        return labelList.count
    }
    
    /**
     * テーブルの行ごとのセルを返却する
     */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            // storyboardで指定したmyDataCell識別子を利用して再利用可能なセルを取得する
            let cell = tableView.dequeueReusableCellWithIdentifier("myDataCell", forIndexPath: indexPath) as! TableViewCell
            // 行番号順にそれぞれ格納する
            cell.myDataImageView!.image = imageList[indexPath.row]
            cell.myDataLabel!.text = labelList[indexPath.row]
            return cell
        }
        return UITableViewCell()
    }
    
    /**
     * セルが編集可能かどうかの判定処理
     */
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    /**
     * セルを削除した際の処理
     */
    override func tableView(tableView: UITableView,
                            commitEditingStyle editingStyle: UITableViewCellEditingStyle,
                            forRowAtIndexPath indexPath: NSIndexPath) {
        // 削除可能かどうか
        if editingStyle == .Delete {
            print("delete: ", labelList[indexPath.row])
            //--------------------
            // ファイルを削除する
            //--------------------
            let deletePath: String = getMydataDirectory().stringByAppendingPathComponent(labelList[indexPath.row])
            try! fileManager.removeItemAtPath(deletePath)
            
            // 配列から削除する
            labelList.removeAtIndex(indexPath.row)
            imageList.removeAtIndex(indexPath.row)
            // セルを削除する
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    /**
     * 写真を選択した際に呼ばれるメソッド
     */
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        // 画像
        if info[UIImagePickerControllerOriginalImage] != nil {
            // didFinishPickingMediaWithInfoを通して渡された情報をUIImageにキャストし、selectedImageに入れる
            var selectedImage: UIImage? = info[UIImagePickerControllerOriginalImage] as? UIImage
            
            if selectedImage != nil {
                // 保存名を設定する
                let date = NSDate()
                let currentTime = self.dateFormatter.stringFromDate(date)
                let filename: String = "Picture_" + currentTime  // 例：Picture_20160823141133
                // リサイズ処理
                if resizeCheck == 2 {  // 1/2
                    selectedImage = resizeImage(selectedImage!, resize: 2)
                } else if resizeCheck == 4 {  // 1/4
                    selectedImage = resizeImage(selectedImage!, resize: 4)
                } else if resizeCheck == 8 {  // 1/8
                    selectedImage = resizeImage(selectedImage!, resize: 8)
                }
                // 選択した写真をNSData型に変換
                let imageData = UIImageJPEGRepresentation(selectedImage!, 1.0)
                let filePath = getMydataDirectory().stringByAppendingPathComponent(filename)
                
                // 値の挿入・行追加をテーブルへ通知する
                insertData(filename, image: selectedImage!)
                
                //----------------------------------------
                // WriteToFile で MyData に保存する
                //----------------------------------------
                let success = imageData!.writeToFile(filePath, atomically: true)
                
                // 確認
                if success {
                    print("Save OK")
                } else {
                    print("Save Error")
                }
            }
        }
        
        // 写真選択後にカメラロール表示ViewControllerを引っ込める動作
        picker.dismissViewControllerAnimated(true, completion: nil)
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
     * 画像をリサイズする処理
     */
    func resizeImage(image: UIImage, resize: Int) -> UIImage {
        // 1/4に設定する
        let ImageWidth: Int = Int(image.size.width)/resize
        let ImageHeight: Int = Int(image.size.height)/resize
        let size: CGSize = CGSize(width: ImageWidth, height: ImageHeight)
        UIGraphicsBeginImageContext(size)
        image.drawInRect(CGRectMake(0, 0, size.width, size.height))
        
        let resizeImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizeImage
    }
    
    /**
     * 配列の先頭に追加し、テーブルに行の追加を通知する処理
     */
    func insertData(label: String, image: UIImage) {
        // 配列に値を先頭に挿入
        self.labelList.insert(label, atIndex: 0)
        // imageDataに格納する
        self.imageList.insert(image, atIndex: 0)
        // テーブルに行が追加されたことをテーブルに通知
        self.tableView.insertRowsAtIndexPaths(
            [NSIndexPath(forRow: 0, inSection: 0)],
            withRowAnimation: UITableViewRowAnimation.Right)
    }
    
    /**
     * MyDataディレクトリを参照するメソッド
     */
    func getMydataDirectory() -> NSString {
        let folderPath: NSString = NSSearchPathForDirectoriesInDomains(
            NSSearchPathDirectory.DocumentDirectory,
            NSSearchPathDomainMask.UserDomainMask, true).first! + "/" + "MyData"
        return folderPath
    }

}





