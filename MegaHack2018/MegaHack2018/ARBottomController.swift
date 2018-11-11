//
//  ARBottomController.swift
//  MegaHack2018
//
//  Created by Vlad Bonta on 10/11/2018.
//  Copyright © 2018 Vlad Bonta. All rights reserved.
//

import Foundation
import UIKit


let actionCellHeight: CGFloat = 62.0
let smallActionCellHeight: CGFloat = 52.0

enum MHAREditProductAction: Int {
    case buy = 0
    case compare
    case changeColor
    case changePhone
}

enum MHActionButtonsType {
    case buy
    case changeColor
    case display(size1: Float, size2: Float)
}

enum PhoneColor: Int {
    case silver = 0
    case spaceGray = 1
    case gold = 2
}

protocol MPAREditProductDelegate: NSObjectProtocol {
    func editProductActionTapped(_ action: MHAREditProductAction)
    func phoneColorChanged(_ phoneColor: PhoneColor)
}

class ARBottomController: UIViewController {
    @IBOutlet weak var editActionsCollectionView: UICollectionView!
    var actionsImages: [UIImage] = []
    var actionsTitles: [String] = []
    var cellsWidth: [CGFloat] = []
    

    var colorsArray: [UIColor] = []
    
    weak var delegate: MPAREditProductDelegate?
    var buttonsActionType: MHActionButtonsType = .buy
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        colorsArray = [UIColor.silverColor, UIColor.spaceGrayColor, UIColor.goldColor]
        self.changeBottomActions(type: .buy)
    }
    
    func setupCollectionView() {
        editActionsCollectionView.register(UINib(nibName: "MHAREditProductCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MHAREditProductCollectionViewCell")
    }
    
    func resetActionsImages() {
        self.changeBottomActions(type: .buy)
    }
    
    func changeBottomActions(type: MHActionButtonsType) {
        buttonsActionType = type
        switch type {
        case .buy:
            actionsImages = [UIImage(named: "ProductDetailsAddToCartIcon")!, UIImage(named: "ARProductInfoIcon")!, UIImage(named: "FilterColorSelected")!, UIImage(named: "replace")!]
            
            actionsTitles = ["Buy", "Compare", "Change Color", "Change"]
            let actionWidth: CGFloat = self.view.frame.size.width / CGFloat(actionsImages.count) - 10.0
            cellsWidth = [actionWidth, actionWidth, actionWidth, actionWidth]
            
        case .changeColor:
            let silverImage = UIImage.imageWithColor(color: UIColor.silverColor)
            let spaceGrayImage = UIImage.imageWithColor(color: UIColor.spaceGrayColor)
            let goldImage = UIImage.imageWithColor(color: UIColor.goldColor)

            actionsImages = [silverImage, spaceGrayImage,goldImage]
            
            actionsTitles = ["Silver", "Space Gray", "Gold"]
            
            let actionWidth: CGFloat = self.view.frame.size.width / CGFloat(actionsImages.count) - 10.0
            cellsWidth = [actionWidth, actionWidth, actionWidth]
        case .display(let size1, let size2):
            let sizeImage = UIImage(named: "FilterSizeSelected")!

            actionsImages = [sizeImage, sizeImage]
            
            actionsTitles = ["\(size1) cm", "\(size2) cm"]
            
            let actionWidth: CGFloat = self.view.frame.size.width / CGFloat(actionsImages.count) - 10.0
            cellsWidth = [actionWidth, actionWidth, actionWidth]
            
        default:  break
            
        }
        editActionsCollectionView.reloadData()
    }
}

extension ARBottomController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return actionsTitles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MHAREditProductCollectionViewCell", for: indexPath) as? MHAREditProductCollectionViewCell
        cell?.setupCell(with: actionsImages[indexPath.row], title: actionsTitles[indexPath.row], type: buttonsActionType)
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: CGFloat(cellsWidth[indexPath.row]), height:  actionCellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        switch indexPath.row {
        case 1:
          
            collectionView.reloadData()
        default:
            break
        }
        
        if let delegate = delegate {
            switch buttonsActionType {
            case .buy:
                let productAction = MHAREditProductAction.init(rawValue: indexPath.row)
                delegate.editProductActionTapped(productAction ?? MHAREditProductAction(rawValue: 0)!)
            case .changeColor:
                guard let color = PhoneColor.init(rawValue: indexPath.row) else {return}
                delegate.phoneColorChanged(color)
            default: break
            }
        }
    }
}
