//
//  MHAREditProductCollectionViewCell.swift
//  MegaHack2018
//
//  Created by Vlad Bonta on 10/11/2018.
//  Copyright © 2018 Vlad Bonta. All rights reserved.
//

import Foundation
import UIKit

class MHAREditProductCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak private var actionImageView: UIImageView!
    @IBOutlet weak private var actionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.actionImageView.layer.masksToBounds = true
    }
    
    func setupCell(with image: UIImage?, title: String?, type: MHActionButtonsType) {
        self.layoutIfNeeded()
        switch type {
        case .buy:
            actionImageView.layer.cornerRadius = 0.0
            actionImageView.layer.borderWidth = 0.0
        case .changeColor:
            actionImageView.layer.borderColor = UIColor.black.cgColor
            actionImageView.layer.borderWidth = 1.0
            actionImageView.layer.cornerRadius = actionImageView.frame.size.width / 2.0
        case .display(let _, let _):
            actionImageView.layer.cornerRadius = 0.0
            actionImageView.layer.borderWidth = 0.0
        }
        actionImageView.image = image
        actionLabel.text = title
    }

}
