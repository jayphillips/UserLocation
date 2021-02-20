//
//  RoundedButtonView.swift
//  User Location
//
//  Created by Jay Phillips on 2/20/21.
//

import UIKit

class RoundedButtonView: UIButton {

    override func awakeFromNib() {
        self.layer.cornerRadius = self.frame.height / 2
        self.layer.backgroundColor = UIColor.white.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowColor = UIColor.black.cgColor
    }

}
