//
//  MainViewTableViewCell.swift
//  Favourite Places
//
//  Created by User on 25.09.2022.
//

import UIKit

class MainViewTableViewCell: UITableViewCell {

    static let identifier = "MainViewTableViewCell"

    lazy var imageOfPlace: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 32.5
        imageView.clipsToBounds = true
        return imageView
    }()

    private lazy var nameOfPlace: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        return label
    }()

    private lazy var locationOfPlace: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15, weight: .light)
        return label
    }()

    private lazy var typeOfPlace: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        return label
    }()

    private lazy var labelStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 3
        stack.distribution = .fillEqually
        return stack
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupHierarchy()
        setuplayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupHierarchy() {
        addSubview(imageOfPlace)
        labelStack.addArrangedSubview(nameOfPlace)
        labelStack.addArrangedSubview(locationOfPlace)
        labelStack.addArrangedSubview(typeOfPlace)
        addSubview(labelStack)
    }

    private func setuplayout() {
        imageOfPlace.snp.makeConstraints { make in
            make.width.height.equalTo(65)
            make.centerY.equalTo(contentView.snp.centerY)
            make.left.equalTo(self.snp.left).offset(20)
        }

        labelStack.snp.makeConstraints { make in
            make.centerY.equalTo(contentView.snp.centerY)
            make.left.equalTo(imageOfPlace.snp.right).offset(20)
        }
    }

    func configureCell(with model: Place) {
        nameOfPlace.text = model.name
        locationOfPlace.text = model.location
        typeOfPlace.text = model.type
        imageOfPlace.image = UIImage(data: model.imageData!)
    }

}
