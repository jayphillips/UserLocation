//
//  AddressLabelView.swift
//  User Location
//
//  Created by Jay Phillips on 2/18/21.
//

import UIKit

class AddressLabelView: UILabel {

    override func awakeFromNib() {
        self.layer.cornerRadius = 10
        self.layer.backgroundColor = UIColor.white.cgColor
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.opacity = 0.75
    }

}
