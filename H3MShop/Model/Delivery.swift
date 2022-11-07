//
//  Delivery.swift
//  H3MShop
//
//  Created by Lê Văn Huy on 06/11/2022.
//

import Foundation

class Delivery: Codable,Identifiable{
    let _id: String
    let name: String
    let price: Int
    let status: Bool
    let note: String
}

class DeliveryResponse: Codable{
    let message:String
    let delivery: [Delivery]
    let status: Bool
}
