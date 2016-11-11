//
//  TableViewCell.swift
//  MCDC
//
//  Created by x13089xx on 2016/08/17.
//  Copyright © 2016年 Kosuke Nakamura. All rights reserved.
//

import UIKit

/**
 * 各Cellの中身をここでつなげておく(CustomTableViewCell)
 */
class TableViewCell: UITableViewCell {
    
    // MyDataViewControllerクラス用
    @IBOutlet weak var myDataImageView: UIImageView!
    @IBOutlet weak var myDataLabel: UILabel!
    
    // DataListViewControllerクラス用
    @IBOutlet weak var dataListDateLabel: UILabel!
    @IBOutlet weak var dataListUserNameLabel: UILabel!
    
    // DataViewControllerクラス用
    @IBOutlet weak var dataImageView: UIImageView!
    @IBOutlet weak var dataLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // 画像のアスペクト比維持
        if myDataImageView != nil {
            myDataImageView.contentMode = UIViewContentMode.ScaleAspectFit
        }
        if dataImageView != nil {
            dataImageView.contentMode = UIViewContentMode.ScaleAspectFit
        }
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
