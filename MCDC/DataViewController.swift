//
//  DataViewController.swift
//  MCDC
//
//  Created by x13089xx on 2016/07/24.
//  Copyright © 2016年 Kosuke Nakamura. All rights reserved.
//

// 各フォルダのパス
var dataListPath: String = ""
// 画像の名前
var imageName: String = ""


import UIKit

/**
 * データの中身を参照する
 */
class DataViewController: UITableViewController {
    
    let fileManager = NSFileManager.defaultManager()
    
    // 文字を格納した配列
    var labelList: [String] = [String]()
    // 画像を格納した配列
    var imageList: [UIImage] = [UIImage]()
    
    var selectedImage: UIImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(dataListPath + " ディレクトリにいます")
        
        // セルの高さを自動調整
        self.tableView.estimatedRowHeight = 90
        self.tableView.rowHeight = UITableViewAutomaticDimension
        // ナビゲーションバーのタイトルをそれぞれ選択したセルごとに変更する
        if dataListPath == "MyData" {
            self.title = dataListPath
        } else {
            // ユーザ名のみ抜き出し
            self.title = dataListPath.substringFromIndex(dataListPath.startIndex.advancedBy(9))
        }
        
        //----------------------------------------
        // ディレクトリにあるファイル一覧を取得
        //----------------------------------------
        fileManager.subpathsAtPath(getDataDirectory() as String)?.forEach {
            print($0)
            // dataListから得たデータを順にlabelListに格納する
            self.labelList.insert($0, atIndex: 0)
            // imageDataに格納する
            let imagePath: String = getDataDirectory().stringByAppendingPathComponent($0)
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
            // storyboardで指定したdataCell識別子を利用して再利用可能なセルを取得する
            let cell = tableView.dequeueReusableCellWithIdentifier("dataCell", forIndexPath: indexPath) as! TableViewCell
            // 行番号順にそれぞれ格納する
//            labelList[indexPath.row].substringFromIndex((labelList[indexPath.row].rangeOfString("_")?.endIndex)!) {
//            }
            cell.dataLabel!.text = labelList[indexPath.row]
            cell.dataImageView!.image = imageList[indexPath.row]
            return cell
        }
        return UITableViewCell()
    }
    
    /**
     * セル選択時の処理
     */
    override func tableView(tableView: UITableView?, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print(labelList[indexPath.row])
        
        let cellData: String = labelList[indexPath.row]
        let category: String = checkDataType(cellData)
        
        // セルのデータを取得してそれぞれ画面遷移する
        switch (category) {
        case "URL":
            let path: String = cellData.substringFromIndex(cellData.startIndex.advancedBy(4))
            UIApplication.sharedApplication().openURL(NSURL(string: "https://" + path)!)
        case "Facebook":
            let path: String = cellData.substringFromIndex(cellData.startIndex.advancedBy(9))
            UIApplication.sharedApplication().openURL(NSURL(string: "https://www.facebook.com/" + path)!)
        case "Twitter":
            let path: String = cellData.substringFromIndex(cellData.startIndex.advancedBy(8))
            UIApplication.sharedApplication().openURL(NSURL(string: "twitter://user?screen_name=" + path)!)
        case "Picture":
            let path: String = cellData.substringFromIndex(cellData.startIndex.advancedBy(8))
            imageName = path
            selectedImage = imageList[indexPath.row]
            
            if selectedImage != nil {
                // ImageViewController へ遷移するために Segue を呼び出す
                performSegueWithIdentifier("toImageViewController", sender: nil)
            }
        default:
            print("該当なし")
        }
    }
    
    /**
     * Segue 準備
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toImageViewController" {
            if let imageVC = segue.destinationViewController as? ImageViewController {
                // 遷移先の画像を格納する
                imageVC.selectedImg = selectedImage
            }
        }
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
            let deletePath: String = getDataDirectory().stringByAppendingPathComponent(labelList[indexPath.row])
            try! fileManager.removeItemAtPath(deletePath)
            
            // 配列から削除する
            labelList.removeAtIndex(indexPath.row)
            imageList.removeAtIndex(indexPath.row)
            // セルを削除する
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
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
        } else if data.characters.count >= 7 && data.substringToIndex(data.startIndex.advancedBy(7)) == "Picture" {
            return "Picture"
        }
        return data
    }
    
    /**
     * 各DataList内のディレクトリを参照するメソッド
     */
    func getDataDirectory() -> NSString {
        let documentsPath: NSString = NSSearchPathForDirectoriesInDomains(
            NSSearchPathDirectory.DocumentDirectory,
            NSSearchPathDomainMask.UserDomainMask, true).first! + "/" + dataListPath
        return documentsPath
    }

}
