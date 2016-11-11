//
//  ImageViewController.swift
//  MCDC
//
//  Created by x13089xx on 2016/11/02.
//  Copyright © 2016年 Kosuke Nakamura. All rights reserved.
//

import UIKit

/**
 * 画像を閲覧する
 */
class ImageViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var selectedImg: UIImage!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = imageName
        
        // imageViewに画像をセットする
        imageView.image = selectedImg
        // 画像のアスペクト比維持
        if imageView != nil {
            imageView.contentMode = UIViewContentMode.ScaleAspectFit
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /**
     * 画像をカメラロールに保存する
     */
    @IBAction func saveBarButton(sender: AnyObject) {
        // アラートダイアログ生成
        let alertController = UIAlertController(title: "保存完了",
                                                message: "アルバムに保存しました",
                                                preferredStyle: UIAlertControllerStyle.Alert)
        // OKボタンを追加
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        alertController.addAction(okAction)
        presentViewController(alertController, animated: true, completion: nil)
        
        // カメラロールに保存する
        UIImageWriteToSavedPhotosAlbum(selectedImg, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    /**
     * 保存結果処理
     */
    func image(image: UIImage, didFinishSavingWithError error: NSError!, contextInfo: UnsafeMutablePointer<Void>) {
        // 失敗した場合
        if error != nil {
            print(error.code)
        }
    }

}
