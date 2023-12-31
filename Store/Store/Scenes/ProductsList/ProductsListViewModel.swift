//
//  ProductsListViewModel.swift
//  Store
//
//  Created by Baramidze on 25.11.23.
//

import Foundation

protocol ProductsListViewModelDelegate: AnyObject {
    func productsFetched()
    func productsAmountChanged()
}

class ProductsListViewModel {
    
    weak var delegate: ProductsListViewModelDelegate?
    
    var products: [ProductModel]?
    var totalPrice: Double? { products?.reduce(0) { $0 + $1.price * Double(($1.selectedAmount ?? 0))} }
    
    func viewDidLoad() {
        fetchProducts()
    }
    
    private func fetchProducts() {
        NetworkManager.shared.fetchProducts { [weak self] response in
            switch response {
            case .success(let products):
                self?.products = products
                self?.delegate?.productsFetched()
            case .failure(let error):
                //TODO: handle Error
                self?.handleFetchError(error)
                break
            }
        }
    }
    
    private func handleFetchError(_ error: Error) {
        print("Error fetching products: \(error.localizedDescription)")
    }
    
    func addProduct(at index: Int) {
        guard var product = products?[index] else {
            return
        }

        //TODO: handle if products are out of stock
        if product.stock > 0 {
            products?[index] = product
            product.selectedAmount = (product.selectedAmount ?? 0) + 1
            product.stock -= 1
            delegate?.productsAmountChanged()
        } else {
            print("Out of stock")
        }
    }
    
    
    func removeProduct(at index: Int) {
        
        guard var product = products?[index], let selectedAmount = product.selectedAmount else {
            return
        }
        
        //TODO: handle if selected quantity of product is already 0
        if selectedAmount > 0 {
            products?[index] = product
            product.selectedAmount = selectedAmount - 1
            product.stock += 1
            delegate?.productsAmountChanged()
        }
    }
}
