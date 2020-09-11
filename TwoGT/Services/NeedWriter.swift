//
//  NeedWriter.swift
//  TwoGT
//
//  Created by Jyrki Hoisko on 9/7/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

//import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class FirebaseGeneric {

    struct AddressInfo: Codable {
        var streetAddress1: String
        var streetAddress2: String
        var zipCode: String
        var city: String
        var state: String?
        var country: String
    }

    struct GeographicCoordinates: Codable {
        var latitude: Double
        var longitude: Double
    }

    struct LocationInfo: Codable {
        var city: String
        var state: String
        var country: String
        var address: AddressInfo?
        var geoLocation: GeographicCoordinates?
    }
}

class NeedsBase: FirebaseGeneric {

    struct NeedItem: Identifiable, Codable {
        @DocumentID var id: String? = UUID().uuidString
        var category: String
        var description: String?
        var validUntil: Int
        var owner: String
        var createdBy: String
        @ServerTimestamp var createdAt: Timestamp?
        var locationInfo: LocationInfo
    }
    
}

class NeedsDbWriter: NeedsBase {
    func addNeed(_ need: NeedItem, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()

        do {
            try db.collection("needs").document().setData(from: need)
        } catch {
            // handle the error here
            print(error)
            completion(error)
        }
        completion(nil)
    }
}
