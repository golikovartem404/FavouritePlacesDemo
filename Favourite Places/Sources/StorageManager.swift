//
//  StorageManager.swift
//  Favourite Places
//
//  Created by User on 25.09.2022.
//

import RealmSwift

let realm = try! Realm()

class StorageManager {
    static func saveObject(place: Place) {
        try! realm.write {
            realm.add(place)
        }
    }
}
