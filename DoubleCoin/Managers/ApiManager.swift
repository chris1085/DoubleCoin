//
//  ApiManager.swift
//  DoubleCoin
//
//  Created by 姜權芳 on 2023/6/28.
//

import Alamofire
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

enum ApiUrls {
  static let baseUrl = "https://api-public.sandbox.pro.coinbase.com"

  case getProducts

  var urlString: String {
    switch self {
    case .getProducts:
      return ApiUrls.baseUrl + "/products"
    }
  }
}

enum HttpMethod: String {
  case get = "GET"
  case post = "POST"
}

class ApiManager {
  static let shared = ApiManager()

  func getData() {
    var semaphore = DispatchSemaphore(value: 0)
    let productsUrl = ApiUrls.getProducts.urlString
    let method = HttpMethod.get.rawValue

    var request = URLRequest(url: URL(string: productsUrl)!, timeoutInterval: Double.infinity)
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpMethod = method

    let task = URLSession.shared.dataTask(with: request) { data, _, error in
      guard let data = data else {
        print(String(describing: error))
        semaphore.signal()
        return
      }

      do {
        let decoder = JSONDecoder()
        let allProducts = try decoder.decode([Product].self, from: data)

        print(allProducts)
      } catch {
        print("Error decoding data: \(error)")
      }

      semaphore.signal()
    }

    task.resume()
    semaphore.wait()
  }
}
