//
//  NewPlaceViewController.swift
//  Favourite Places
//
//  Created by User on 25.09.2022.
//

import UIKit
import CoreLocation

protocol AddNewDataDelegateProtocol {
    func updateTableView()
}

class NewPlaceViewController: UIViewController {

    var delegate: AddNewDataDelegateProtocol?
    var isImageChanged = false
    var currentPlace: Place?

    // MARK: - Outlets

    private lazy var mainImageOfPlace: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .systemGray3
        imageView.image = UIImage(named: "defaultImage")
        imageView.contentMode = .center
        return imageView
    }()

    private lazy var photoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "camera"), for: .normal)
        button.addTarget(self, action: #selector(openPhoto), for: .touchUpInside)
        button.tintColor = .white
        button.backgroundColor = .black
        button.layer.cornerRadius = 20
        return button
    }()

    private lazy var mapButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "map"), for: .normal)
        button.addTarget(self, action: #selector(openMap), for: .touchUpInside)
        button.tintColor = .white
        button.backgroundColor = .black
        button.layer.cornerRadius = 20
        return button
    }()

    lazy var nameOfNewPlace: UILabel = {
        let label = UILabel()
        label.text = "Name"
        label.font = UIFont.systemFont(ofSize: 20, weight: .ultraLight)
        return label
    }()

    lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Name of place"
        textField.returnKeyType = .done
        textField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        textField.delegate = self
        return textField
    }()

    private lazy var nameStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 6
        return stack
    }()

    lazy var locationOfNewPlace: UILabel = {
        let label = UILabel()
        label.text = "Location"
        label.font = UIFont.systemFont(ofSize: 20, weight: .ultraLight)
        return label
    }()

    lazy var locationTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Location of place"
        textField.returnKeyType = .done
        textField.delegate = self
        return textField
    }()

    private lazy var locationStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 6
        return stack
    }()

    private lazy var placeLocationButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .black
        button.setImage(UIImage(named: "placeLocation"), for: .normal)
        button.addTarget(self, action: #selector(getAddress), for: .touchUpInside)
        return button
    }()

    lazy var typeOfNewPlace: UILabel = {
        let label = UILabel()
        label.text = "Type"
        label.font = UIFont.systemFont(ofSize: 20, weight: .ultraLight)
        return label
    }()

    lazy var typeTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Type of place"
        textField.returnKeyType = .done
        textField.delegate = self
        return textField
    }()

    private lazy var typeStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 6
        return stack
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        configureViewWithPlace()
        setupView()
        setupHierarchy()
        setupLayout()
    }

    // MARK: - Setups

    private func setupNavigationBar() {
        title = "New place"
        let leftButton = UIBarButtonItem(barButtonSystemItem: .cancel,
                                         target: self,
                                         action: #selector(goToBack))
        navigationItem.leftBarButtonItem = leftButton
        let rightButton = UIBarButtonItem(barButtonSystemItem: .save,
                                          target: self,
                                          action: #selector(saveData))
        navigationItem.rightBarButtonItem = rightButton
        rightButton.isEnabled = false
    }

    private func setupHierarchy() {
        view.addSubview(mainImageOfPlace)
        view.addSubview(photoButton)
        view.addSubview(mapButton)
        nameStack.addArrangedSubview(nameOfNewPlace)
        nameStack.addArrangedSubview(nameTextField)
        view.addSubview(nameStack)
        locationStack.addArrangedSubview(locationOfNewPlace)
        locationStack.addArrangedSubview(locationTextField)
        view.addSubview(locationStack)
        view.addSubview(placeLocationButton)
        typeStack.addArrangedSubview(typeOfNewPlace)
        typeStack.addArrangedSubview(typeTextField)
        view.addSubview(typeStack)
    }

    private func setupLayout() {
        mainImageOfPlace.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.right.equalTo(view)
            make.bottom.equalTo(view.snp.centerY).multipliedBy(0.8)
        }

        photoButton.snp.makeConstraints { make in
            make.bottom.equalTo(mainImageOfPlace.snp.bottom).offset(-20)
            make.right.equalTo(mainImageOfPlace.snp.right).offset(-20)
            make.width.height.equalTo(40)
        }

        mapButton.snp.makeConstraints { make in
            make.bottom.equalTo(photoButton.snp.top).offset(-15)
            make.right.equalTo(mainImageOfPlace.snp.right).offset(-20)
            make.width.height.equalTo(40)
        }

        nameStack.snp.makeConstraints { make in
            make.top.equalTo(mainImageOfPlace.snp.bottom).offset(15)
            make.left.equalTo(view.snp.left).offset(20)
            make.width.equalTo(view.snp.width).multipliedBy(0.9)
        }

        locationStack.snp.makeConstraints { make in
            make.top.equalTo(nameStack.snp.bottom).offset(20)
            make.left.equalTo(view.snp.left).offset(20)
            make.width.equalTo(view.snp.width).multipliedBy(0.7)
        }

        placeLocationButton.snp.makeConstraints { make in
            make.centerY.equalTo(locationStack.snp.centerY)
            make.right.equalTo(view.snp.right).offset(-20)
            make.width.height.equalTo(35)
        }

        typeStack.snp.makeConstraints { make in
            make.top.equalTo(locationStack.snp.bottom).offset(20)
            make.left.equalTo(view.snp.left).offset(20)
            make.width.equalTo(view.snp.width).multipliedBy(0.9)
        }

    }

    private func setupView() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGesture)
    }

    // MARK: - Selectors

    @objc func goToBack() {
        navigationController?.popViewController(animated: true)
    }

    @objc func saveData() {
        let image = isImageChanged ? mainImageOfPlace.image : UIImage(named: "defaultPlaceImage")
        let imageData = image?.pngData()
        let newPlace = Place(name: nameTextField.text!,
                             location: locationTextField.text,
                             type: typeTextField.text,
                             imageData: imageData)
        if currentPlace != nil {
            try! realm.write {
                currentPlace?.name = newPlace.name
                currentPlace?.location = newPlace.location
                currentPlace?.type = newPlace.type
                currentPlace?.imageData = newPlace.imageData
            }
        } else {
            StorageManager.saveObject(place: newPlace)
        }

        delegate?.updateTableView()
        navigationController?.popViewController(animated: true)
    }

    @objc func textFieldChanged() {
        if nameTextField.text?.isEmpty == false {
            navigationItem.rightBarButtonItem?.isEnabled = true
        } else {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }

    @objc func openPhoto() {
        let actionSheet = UIAlertController(title: nil,
                                            message: nil,
                                            preferredStyle: .actionSheet)
        let camera = UIAlertAction(title: "Camera", style: .default) { _ in
            self.chooseImagePicker(source: .camera)
        }
        let photo = UIAlertAction(title: "Photo", style: .default) { _ in
            self.chooseImagePicker(source: .photoLibrary)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        actionSheet.addAction(camera)
        actionSheet.addAction(photo)
        actionSheet.addAction(cancel)
        present(actionSheet, animated: true)
    }

    @objc func openMap() {
        let nextVC = MapViewController()
        nextVC.userPin.isHidden = true
        nextVC.placeLocationAddress.isHidden = true
        nextVC.userAddressSetButton.isHidden = true
        nextVC.place.name = nameTextField.text!
        nextVC.place.location = locationTextField.text
        nextVC.place.type = typeTextField.text
        nextVC.place.imageData = mainImageOfPlace.image?.pngData()
        nextVC.setupPlaceMark()
        navigationController?.pushViewController(nextVC, animated: true)
    }

    @objc private func hideKeyboard() {
        self.view.endEditing(true)
    }

    @objc func getAddress() {
        let nextVC = MapViewController()
        nextVC.locationManager.startUpdatingLocation()
        nextVC.routeButton.isHidden = true
        nextVC.mapViewDelegate = self
        navigationController?.pushViewController(nextVC, animated: true)
    }

    func configureViewWithPlace() {
        if currentPlace != nil {
            setupEditScreenNavigationBar()
            isImageChanged = true
            guard let data = currentPlace?.imageData, let image = UIImage(data: data) else { return }
            mainImageOfPlace.image = image
            mainImageOfPlace.contentMode = .scaleAspectFill
            mainImageOfPlace.clipsToBounds = true
            nameTextField.text = currentPlace?.name
            locationTextField.text = currentPlace?.location
            typeTextField.text = currentPlace?.type
        }
    }

    private func setupEditScreenNavigationBar() {
        title = currentPlace?.name
        navigationItem.largeTitleDisplayMode = .always
        let leftButton = UIBarButtonItem(barButtonSystemItem: .cancel,
                                         target: self,
                                         action: #selector(goToBack))
        navigationItem.leftBarButtonItem = leftButton
        let rightButton = UIBarButtonItem(barButtonSystemItem: .save,
                                          target: self,
                                          action: #selector(saveData))
        navigationItem.rightBarButtonItem = rightButton
        rightButton.isEnabled = true
    }
}

// MARK: - Extensions

extension NewPlaceViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension NewPlaceViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func chooseImagePicker(source: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(source) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = source
            present(imagePicker, animated: true)
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        mainImageOfPlace.image = info[.editedImage] as? UIImage
        mainImageOfPlace.contentMode = .scaleAspectFill
        mainImageOfPlace.clipsToBounds = true
        isImageChanged = true
        dismiss(animated: true)
    }
}

extension NewPlaceViewController: MapViewDelegate {

    func getAddressOfPlace(_ address: String?) {
        locationTextField.text = address
    }
}
