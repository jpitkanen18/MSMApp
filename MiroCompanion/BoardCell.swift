//
//  BoardViewCell.swift
//  MiroCompanion
//
//  Created by Jese on 20.11.2021.
//

import UIKit

class BoardCell: UITableViewCell {
    var gradientLayer: CAGradientLayer!
    let colours = [UIColor(red: 0.98, green: 0.82, blue: 0.76, alpha: 1.00), UIColor(red: 0.77, green: 0.87, blue: 0.96, alpha: 1.00), UIColor(red: 0.76, green: 0.88, blue: 0.77, alpha: 1.00), UIColor(red: 0.83, green: 0.77, blue: 0.98, alpha: 1.00), UIColor(red: 0.92, green: 0.59, blue: 0.58, alpha: 1.00)]
    
    @IBOutlet weak var boardLabel: UILabel!
    let gradients = [[UIColor(red: 0.29, green: 0.28, blue: 0.98, alpha: 1.00).cgColor, UIColor(red: 1.00, green: 0.67, blue: 0.41, alpha: 1.00).cgColor], [UIColor(red: 0.50, green: 1.00, blue: 0.41, alpha: 1.00).cgColor, UIColor(red: 0.51, green: 0.51, blue: 0.95, alpha: 1.00).cgColor]]
    override func awakeFromNib() {
       super.awakeFromNib()
        //createGradientLayer()
        
        if self.traitCollection.userInterfaceStyle == .light{
            self.contentView.backgroundColor = UIColor.white
        } else {
            self.contentView.backgroundColor = UIColor.black
        }
        
   }

   override func setSelected(_ selected: Bool, animated: Bool) {
       super.setSelected(selected, animated: animated)
   }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
      // Do sonthing
        super.traitCollectionDidChange(previousTraitCollection)
        DispatchQueue.main.async {
            if self.traitCollection.userInterfaceStyle == .light{
                //self.gradientLayer.backgroundColor = UIColor.white.cgColor
                self.backgroundColor = UIColor.white
            } else {
                //self.gradientLayer.backgroundColor = UIColor.black.cgColor
                self.backgroundColor = UIColor.black
            }
        }
    }
   func createGradientLayer() {
       gradientLayer = CAGradientLayer()
       if self.traitCollection.userInterfaceStyle == .light{
           self.gradientLayer.backgroundColor = UIColor.white.cgColor
       } else {
           self.gradientLayer.backgroundColor = UIColor.black.cgColor
       }
    
       gradientLayer.frame = CGRect(x: 0.0, y: 0.0, width: self.frame.size.width, height: self.frame.size.height)
       gradientLayer.colors = gradients[Int.random(in: 0..<2)]
       gradientLayer.masksToBounds = false
       //gradientLayer.cornerRadius = 10.0
       gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
       gradientLayer.endPoint = CGPoint(x: 1.0, y: -0.5)
       contentView.layer.insertSublayer(gradientLayer, at: 0)
   }

}
