//
//  ViewController.swift
//  Favourite Places
//
//  Created by User on 25.09.2022.
//

import UIKit
import SnapKit
import RealmSwift

class MainViewController: UIViewController {

    var places: Results<Place>!

    lazy var placesTable: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.register(MainViewTableViewCell.self, forCellReuseIdentifier: MainViewTableViewCell.identifier)
        table.dataSource = self
        table.delegate = self
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupHierarchy()
        setupLayout()
        setupNavigationBar()
        places = realm.objects(Place.self)
    }

    private func setupHierarchy() {
        view.addSubview(placesTable)
    }

    private func setupLayout() {
        placesTable.snp.makeConstraints { make in
            make.top.left.right.bottom.equalTo(view)
        }
    }

    private func setupNavigationBar() {
        title = "Favorite Places"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(goToNewPlaceView))
    }

    @objc func goToNewPlaceView() {
        let nextVC = NewPlaceViewController()
        nextVC.delegate = self
        navigationController?.pushViewController(nextVC, animated: true)
    }
}

extension MainViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.isEmpty ? 0 : places.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MainViewTableViewCell.identifier, for: indexPath) as? MainViewTableViewCell else { return UITableViewCell() }
        cell.configureCell(with: places[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let nextVC = NewPlaceViewController()
        let place = places[indexPath.row]
        nextVC.currentPlace = place
        nextVC.delegate = self
        navigationController?.pushViewController(nextVC, animated: true)
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let place = places[indexPath.row]
        if editingStyle == .delete {
            tableView.beginUpdates()
            StorageManager.deleteObject(place: place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
    }
}

extension MainViewController: AddNewDataDelegateProtocol {

    func updateTableView() {
        placesTable.reloadData()
    }
}
