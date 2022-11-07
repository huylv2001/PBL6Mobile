//
//  Address.swift
//  H3MShop
//
//  Created by Lê Văn Huy on 01/11/2022.
//

import Foundation

class Address: Codable {
    var id_province: String
    var id_district: String
    var id_commune: String
    var street: String
    
    init(id_province:String = "" ,id_district:String = "", id_commune: String = "" , street: String = ""){
        
        self.id_province = id_province
        self.id_district = id_district
        self.id_commune = id_commune
        self.street = street
    }
    
}

class AddressResponse: Codable{
    
    let address: Address
    
    init(address: Address) {
        self.address = address
    }
}
