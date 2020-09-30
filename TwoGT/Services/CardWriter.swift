//
//  CardWriter.swift
//  TwoGT
//
//  Created by Jyrki Hoisko on 9/30/20.
//  Copyright © 2020 Arthur Mayes. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class CardsDbWriter: CardsBase {
    func addCard(_ card: FiBCardItem, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()

        do {
            try db.collection("cards").document(card.id ?? "").setData(from: card)
        } catch {
            print(error.localizedDescription  + " in CardWriter -> addCard")
            completion(error)
        }
        completion(nil)
    }
}
