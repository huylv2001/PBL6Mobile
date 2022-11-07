//
//  Authentication.swift
//  H3MShop
//
//  Created by Lê Văn Huy on 31/10/2022.
//

import Foundation
import SwiftUI

class Authentincation: ObservableObject {
    
    @AppStorage("token") var token: String = ""
    @Published var currenUser : User? = User()
    
    
    @Published var fullname: String = ""
    @Published var phone: String = ""
    @Published var gender: Bool = true
    
    
    @Published var province = Province()
    @Published var district = District()
    @Published var commune  =  Commune()
    @Published var address = Address()
    
    @Published var provinces: [Province] = []
    @Published var districts = [District]()
    @Published var communes =  [Commune]()
    @Published var carts: CartResponse = CartResponse()
    
    
    var delivery: [Delivery] = []
    var info: Infor = Infor()
    
    init() {
        
        Task{
            do{
                try await self.fetchDelivery()
                try await self.getInfor()
            }
            catch{
                
            }
        }
        self.getUser()
        self.getAddress()
        self.getCart()
        
    }
    
    
    func fetchUser() async throws -> User?{
        let urlString = Constants.baseURL + Endpoints.user
        
        guard let url = URL(string: urlString) else {
            throw httpError.badURL
        }
        
        let userResponse: GetUserResponse = try await HttpClient.shared.fetchDatawithToken(url: url, httpMethod: httpMethod.GET.rawValue, with: token)
        
        if userResponse.user == nil {
            return nil
        }
        else {
            return userResponse.user
        }
        
    }
    
    func editProfile() async throws {
        
        let urlString = Constants.baseURL + Endpoints.user
        guard let url = URL(string: urlString) else {
            throw httpError.badURL
        }
        
        let userToUpdate = UserRequest(fullname: fullname, phone: phone, gender: gender)
        
        try await HttpClient.shared.sendDatawithToken(to: url, object: userToUpdate, httpMethod: httpMethod.PUT.rawValue, with: token)
        
    }
    
    
    func fetchProvinces() async throws  -> [Province] {
        
        let urlString = Constants.baseURL + Endpoints.provinces
        
        guard let url = URL(string: urlString) else {
            throw httpError.badURL
        }
        
        let provincesResponse: [Province] = try await HttpClient.shared.fetchDatawithToken(url: url, httpMethod: httpMethod.GET.rawValue, with: token)
        
        
        return provincesResponse
        
    }
    
    
    func fetchDistricts() async throws -> [District] {
        
        let urlString = Constants.baseURL + Endpoints.districs + "/\(address.id_province)"
        
        guard let url = URL(string: urlString) else {
            throw httpError.badURL
        }
        
        let districsResponse: [District] = try await HttpClient.shared.fetchDatawithToken(url: url, httpMethod: httpMethod.GET.rawValue, with: token)
        
        return districsResponse
        
        
    }
    
    func fetchCommunes() async throws -> [Commune]{
        
        let urlString = Constants.baseURL + Endpoints.communes + "/\(address.id_district)"
        
        guard let url = URL(string: urlString) else {
            throw httpError.badURL
        }
        
        let communesResponse: [Commune] = try await HttpClient.shared.fetchDatawithToken(url: url, httpMethod: httpMethod.GET.rawValue, with: token)
        
        return communesResponse
        
    }
    
    func getUser(){
        Task{
            do{
                let existedUser = try await self.fetchUser()
                DispatchQueue.main.async{
                    self.currenUser = existedUser
                    if self.currenUser != nil {
                        self.fullname = self.currenUser!.fullname
                        self.phone = self.currenUser!.phone
                        self.gender = self.currenUser!.gender
                        self.address = self.currenUser!.address
                    }
                }
            }
            catch{
                
            }
        }
        
    }
    
    func getAddress()  {
        Task{
            do{
                
                let existedProvinces: [Province] = try await self.fetchProvinces()
                let existedDistricts: [District] = try await self.fetchDistricts()
                let existedCommune: [Commune] = try await self.fetchCommunes()
                
                DispatchQueue.main.async{
                    self.provinces = existedProvinces
                    self.districts = existedDistricts
                    self.communes = existedCommune
                    
                    self.province = self.provinces.filter{$0._id == self.address.id_province}.first!
                    self.district = self.districts.filter{$0._id == self.address.id_district}.first!
                    self.commune = self.communes.filter{$0._id == self.address.id_commune}.first!
                }
                
            }
            catch{
                
            }
        }
        
    }
    
    func getProvince(){
        Task {
            do{
                let existedProvinces: [Province] = try await self.fetchProvinces()
                
                DispatchQueue.main.async {
                    self.provinces = existedProvinces
                }
            }
        }
    }
    
    
    func getDistrict() async throws{
        
        let existedDistricts: [District] = try await self.fetchDistricts()
        DispatchQueue.main.async{
            self.districts = existedDistricts
            self.district = self.districts.first!
        }
    }
    
    func getCommune() async throws {
        let existedCommune: [Commune] = try await self.fetchCommunes()
        DispatchQueue.main.async{
            self.communes = existedCommune
            self.commune = self.communes.first!
            
        }
        
    }
    
    func editAddress() async throws {
        let urlString = Constants.baseURL + Endpoints.user
        guard let url = URL(string: urlString) else {
            throw httpError.badURL
        }
        
        
        let addressRequest = AddressResponse(address: Address(id_province: address.id_province, id_district: address.id_district, id_commune: address.id_commune, street: address.street))
        
        
        try await HttpClient.shared.sendDatawithToken(to: url, object: addressRequest, httpMethod: httpMethod.PUT.rawValue, with: token)
    }
    
    func fetchCart() async throws  -> CartResponse{
        let urlString = Constants.baseURL + Endpoints.cart
        guard let url = URL(string: urlString) else {
            throw httpError.badURL
        }
        let cartResponse: CartResponse = try await HttpClient.shared.fetchDatawithToken(url: url, httpMethod: httpMethod.GET.rawValue, with: token)
        
        return cartResponse
    }
    
    func getCart()  {
        
        Task{
            do{
                if self.currenUser !=  nil {
                    let existedCart: CartResponse = try await self.fetchCart()
                    
                    DispatchQueue.main.async {
                        self.carts = existedCart
                    }
                }
            }
            catch{
                
            }
        }
        
    }
    
    func deleteRowCart(id_product: String) async throws {
        
        
        let urlString = Constants.baseURL + Endpoints.deleteRowCart + "/\(id_product)"
        
        guard let url = URL(string: urlString) else {
            throw httpError.badURL
        }
        
        try await HttpClient.shared.deleteData(url: url, httpMethod: httpMethod.DELETE.rawValue, with: token)
        
        self.getCart()
        
        
    }
    
    func addtoCart(id_product: String, size: String,color: String, number: Int) async throws {
        
        let urlString = Constants.baseURL + Endpoints.insertCart
        guard let url = URL(string: urlString) else {
            throw httpError.badURL
        }
        
        let cartRequest = CartRequest(id_product: id_product, size: size, color: color, number: number)
        
        try await HttpClient.shared.sendDatawithToken(to: url, object: cartRequest, httpMethod: httpMethod.POST.rawValue, with: token)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.25){
//            self.getCart()
            self.carts = CartResponse()
        }
//        self.getCart()
        
    }
    
    func editCart(id_product: String,number: Int) async throws {
        let urlString = Constants.baseURL + Endpoints.updateRowCart
        guard let url = URL(string: urlString) else {
            throw httpError.badURL
        }
        let cartUpdate = CartUpdateRequest(id: id_product, number: number)
        
        try await HttpClient.shared.sendDatawithToken(to: url, object: cartUpdate, httpMethod: httpMethod.PUT.rawValue, with: token)
        
        self.getCart()
    }
    
    func fetchDelivery() async throws {
        let urlString = Constants.baseURL + Endpoints.deliveries
        
        guard let url = URL(string: urlString) else {
            throw httpError.badURL
        }
        
        let deliveriesResponse: DeliveryResponse = try await HttpClient.shared.fetchDatawithToken(url: url, httpMethod: httpMethod.GET.rawValue, with: token)
        
        self.delivery = deliveriesResponse.delivery
    }
    
    func getInfor() async throws {
        
        let urlString = Constants.baseURL + Endpoints.info
        guard let url = URL(string: urlString) else {
            throw httpError.badURL
        }
        
        let infoResponse: InforResponse = try await HttpClient.shared.fetchDatawithToken(url: url, httpMethod: httpMethod.GET.rawValue, with: token)
        
        self.info = infoResponse.infor
        
    }
    
}

