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
    var ascendingSorting = true

    private lazy var sortedControl: UISegmentedControl = {
        let items = ["Date", "Name"]
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.selectedSegmentTintColor = .systemBlue
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.backgroundColor = .white
        segmentedControl.layer.borderColor = UIColor.systemBlue.cgColor
        segmentedControl.layer.borderWidth = 1
        segmentedControl.addTarget(self, action: #selector(sortingSelection), for: .valueChanged)
        return segmentedControl
    }()

    lazy var placesTable: UITableView = {
        let table = UITableView(frame: .zero, style: .plain)
        table.register(MainViewTableViewCell.self, forCellReuseIdentifier: MainViewTableViewCell.identifier)
        table.dataSource = self
        table.delegate = self
        return table
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupHierarchy()
        setupLayout()
        setupNavigationBar()
        places = realm.objects(Place.self)
    }

    private func setupHierarchy() {
        view.addSubview(sortedControl)
        view.addSubview(placesTable)
    }

    private func setupLayout() {
        sortedControl.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.right.equalTo(view)
        }
        placesTable.snp.makeConstraints { make in
            make.top.equalTo(sortedControl.snp.bottom).offset(1)
            make.left.right.bottom.equalTo(view)
        }
    }

    private func setupNavigationBar() {
        title = "Favorite Places"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(goToNewPlaceView))
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.up.arrow.down"),
                                                           style: .done,
                                                           target: self,
                                                           action: #selector(sortedPlaceByAscending))
    }

    @objc func goToNewPlaceView() {
        let nextVC = NewPlaceViewController()
        nextVC.delegate = self
        navigationController?.pushViewController(nextVC, animated: true)
    }

    @objc func sortedPlaceByAscending() {
        ascendingSorting.toggle()
        sorting()
    }

    @objc func sortingSelection() {
        sorting()
    }

    private func sorting() {
        if sortedControl.selectedSegmentIndex == 0 {
            places = places.sorted(byKeyPath: "date", ascending: ascendingSorting)
        } else {
            places = places.sorted(byKeyPath: "name", ascending: ascendingSorting)
        }
        placesTable.reloadData()
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
