//
//  NeedWriter.swift
//  TwoGT
//
//  Created by Jyrki Hoisko on 9/7/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

//import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

public class FirebaseGeneric {

    enum GenericFirebaseError: Error {
        case noAuthUser, alreadyTaken, alreadyOwned, unauthorized, undefined
        var errorDescription: String? {
            switch self {
            case .noAuthUser: return "No authenticated user"
            case .alreadyTaken: return "Name is already reserved by someone else"
            case .alreadyOwned: return "Name is already owned by the caller"
            case .unauthorized: return "User is not the creator of this document"
            case .undefined: return "Unspecified error"
            }
        }
    }

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

        init(latitude: Double, longitude: Double) {
            self.latitude = latitude
            self.longitude = longitude
        }
    }

    public struct LocationInfo: Codable {
        var city: String
        var state: String
        var country: String
        var address: AddressInfo?
        var geoLocation: GeographicCoordinates?
        
        init(locationInfo: LocationInfo) {
            self.city = locationInfo.city
            self.state = locationInfo.state
            self.country = locationInfo.country
            self.address = nil
            self.geoLocation = nil //GeographicCoordinates(latitude: coords.latitude!, longitude: coords.longitude!)
        }

        init(appLocationInfo: AppLocationInfo) {
            self.city = appLocationInfo.city!
            self.state = appLocationInfo.state!
            self.country = appLocationInfo.country!
            self.address = nil
            self.geoLocation = nil //GeographicCoordinates(latitude: coords.latitude!, longitude: coords.longitude!)
        }

        init(city: String, state: String, country: String = "USA", address: AddressInfo?, geoLocation: GeographicCoordinates?) {
            self.city = city
            self.state = state
            self.country = country
            self.address = address
            self.geoLocation = geoLocation
        }
    }
}

public class NeedsBase: FirebaseGeneric {

    public struct NeedItem: Identifiable, Codable {
        @DocumentID public var id: String? = UUID().uuidString
        var category: String // Inherited
        var headline: String?
        var description: String?
        var validUntil: Timestamp
        var owner: String
        var createdBy: String
        @ServerTimestamp var createdAt: Timestamp?
        @ServerTimestamp var modifiedAt: Timestamp?
        var status: String? = "Active"
        var locationInfo: LocationInfo
    }

}

public class NeedsDbWriter: NeedsBase {
    func addNeed(_ need: NeedItem, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()

        do {
            try db.collection("needs").document(need.id ?? "").setData(from: need)
        } catch {
            // handle the error here
            print(error)
            completion(error)
        }
        completion(nil)
    }

    func createNeedAndJoinHave(_ have: HavesBase.HaveItem, usingHandle userHandle: String, completion: @escaping (Error?, NeedItem?) -> Void) {

        let defaultValidUntilDate = Timestamp(date: Date(timeIntervalSinceNow: 30*24*60*60))
        if let userId = Auth.auth().currentUser?.uid {
            // TODO: This needsItem needs to derive data from MarketPlaceVC, as user may have entered description/header etc.
            let description = have.description
            let needItem = NeedsBase.NeedItem(category: have.category, headline: have.headline, description: description, validUntil: defaultValidUntilDate, owner: userHandle, createdBy: userId, locationInfo: have.locationInfo)

            addNeed(needItem) { error in
                if error == nil, let _ = needItem.id, let haveId = have.id {
                    HavesDbWriter().associateAuthUserHavingNeed(needItem, toHaveId: haveId) { error in
                        // call completion
                        completion(error, needItem)
                    }
                }
            }
        } else {
            completion(GenericFirebaseError.noAuthUser, nil)
        }
    }

    func deleteNeed(id: String, userHandle: String, associatedHaveId: String? = nil, completion: @escaping (Error?) -> Void) {
        // TODO: because of the way associated need is stored to a Have, we need
        // to provide uid, needId and Handle to remove the association. This shall be
        // refactored later.
        guard let _ = Auth.auth().currentUser?.uid else {
            completion(GenericFirebaseError.noAuthUser)
            return
        }

        let db = Firestore.firestore()
        db.collection("needs").document(id).delete { err in
            if let haveId = associatedHaveId {
                HavesDbWriter().disassociateAuthUserHavingNeedId(id, handle: userHandle, fromHaveId: haveId) { error in
                    // Error about modifying Have. Have may have been deleted, so updating it may fail.
                    if error?._code == 5 {
                        // Have been deleted, we can omit this error
                        completion(nil)
                    } else {
                        completion(error)
                    }
                }
            } else {
                // Error about deleting the Need
                completion(err)
            }
        }
    }
}