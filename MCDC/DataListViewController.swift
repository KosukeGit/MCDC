//
//  DataListViewController.swift
//  MCDC
//
//  Created by x13089xx on 2016/07/24.
//  Copyright © 2016年 Kosuke Nakamura. All rights reserved.
//

import UIKit

/**
 * ユーザ名一覧参照
 */
class DataListViewController: UITableViewController {
    
    let fileManager = NSFileManager.defaultManager()
    
    // 文字を格納した配列
    var labelList: [String] = [String]()
//    // 正規表現用のインスタンス
//    let predicate = NSPredicate(format: "SELF MATCHES '\\\\d+'")
//    // 作成したフォルダ(頭8桁が数字のとき(例：20161019_username))
//    predicate.evaluateWithObject($0.substringToIndex($0.startIndex.advancedBy(8))) == true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //--------------------------------------------------
        // ドキュメントディレクトリにあるファイル一覧を取得
        //--------------------------------------------------
        fileManager.subpathsAtPath(getDocumentsDirectory() as String)?.forEach {
            // MyDataと文字列に / が含まれない場合のみ
            if $0 == "MyData" || $0.containsString("/") == false {
                print($0)
                // ドキュメントディレクトリのデータを順にlabelListに格納する
                self.labelList.insert($0, atIndex: 0)
            }
        }
        // 確認
        print("labelList.count: ", self.labelList.count)
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
            // storyboardで指定したuserNameCell識別子を利用して再利用可能なセルを取得する
            let cell = tableView.dequeueReusableCellWithIdentifier("dataListCell", forIndexPath: indexPath) as! TableViewCell
            // 行番号順にそれぞれ格納する
            if labelList[indexPath.row] == "MyData" {
                // 日付
                cell.dataListDateLabel!.text = "---"
                // ユーザ名
                cell.dataListUserNameLabel!.text = labelList[indexPath.row]
            } else {
                var date: String = labelList[indexPath.row].substringToIndex(labelList[indexPath.row].startIndex.advancedBy(8))
                // 日付に / を入れる
                date.insert("/", atIndex: date.startIndex.advancedBy(4))
                date.insert("/", atIndex: date.startIndex.advancedBy(7))
                // 日付
                cell.dataListDateLabel!.text = date
                // ユーザ名
                cell.dataListUserNameLabel!.text =
                    labelList[indexPath.row].substringFromIndex(
                        labelList[indexPath.row].startIndex.advancedBy(9)
                )
            }
            return cell
        }
        return UITableViewCell()
    }
    
    /**
     * セル選択時の処理
     */
    override func tableView(tableView: UITableView?, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // セルのデータを取得して受け渡す
        dataListPath = labelList[indexPath.row]
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
            let deletePath: String = getDocumentsDirectory().stringByAppendingPathComponent(labelList[indexPath.row])
            try! fileManager.removeItemAtPath(deletePath)
            
            // 配列から削除する
            labelList.removeAtIndex(indexPath.row)
            // セルを削除する
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    /**
     * ドキュメントディレクトリを参照するメソッド
     */
    func getDocumentsDirectory() -> NSString {
        let documentsPath: NSString = NSSearchPathForDirectoriesInDomains(
            NSSearchPathDirectory.DocumentDirectory,
            NSSearchPathDomainMask.UserDomainMask, true).first!
        return documentsPath
    }

}
