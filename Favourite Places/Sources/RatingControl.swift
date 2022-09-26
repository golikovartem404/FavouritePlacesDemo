//
//  RatingControl.swift
//  Favourite Places
//
//  Created by User on 26.09.2022.
//

import UIKit

class RatingControl: UIStackView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupButtons() {
        let button = UIButton()
        button.backgroundColor = .red
        button.snp.makeConstraints { make in
            make.height.width.equalTo(44)
        }
    }
}
