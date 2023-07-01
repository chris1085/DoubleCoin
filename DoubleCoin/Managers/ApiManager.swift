//
//  ApiManager.swift
//  DoubleCoin
//
//  Created by 姜權芳 on 2023/6/28.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

enum ApiUrls {
  static let baseUrl = "https://api-public.sandbox.pro.coinbase.com"

  case getProducts
  case getAccounts
  case getUserProfile
  case getProductStats(productId: String)
  case getCurrencies
  case getProductCandles(productId: String)
  case getOrders(limits: Int)

  var urlString: String {
    switch self {
    case .getProducts:
      return ApiUrls.baseUrl + "/products"
    case .getAccounts:
      return ApiUrls.baseUrl + "/accounts"
    case .getUserProfile:
      return ApiUrls.baseUrl + "/profiles?active"
    case .getProductStats(let productId):
      return ApiUrls.baseUrl + "/products/\(productId)/stats"
    case .getCurrencies:
      return ApiUrls.baseUrl + "/currencies"
    case .getProductCandles(let productId):
      return ApiUrls.baseUrl + "/products/\(productId)/candles"
    case .getOrders(let limits):
      return ApiUrls.baseUrl + "/orders?limit=\(limits)&status=done"
    }
  }

  var requestUrlString: String {
    switch self {
    case .getProducts:
      return "/products"
    case .getAccounts:
      return "/accounts"
    case .getUserProfile:
      return "/profiles?active"
    case .getProductStats(let productId):
      return "/products/\(productId)/stats"
    case .getCurrencies:
      return "/currencies"
    case .getProductCandles(let productId):
      return "/products/\(productId)/candles"
    case .getOrders(let limits):
      return "/orders?limit=\(limits)&status=done"
    }
  }
}

enum HttpMethod: String {
  case get = "GET"
  case post = "POST"
}

class ApiManager {
  static let shared = ApiManager()
//  var semaphore = DispatchSemaphore(value: 0)

  func fetchData<T: Decodable>(httpMethod: String, urlString: String, responseType: T.Type, headers: [String: String]?, completion: @escaping (Result<T, Error>) -> Void) {
    let method = httpMethod

    guard let url = URL(string: urlString) else {
      let error = NSError(domain: "Invalid URL", code: 0, userInfo: nil)
      completion(.failure(error))
//      semaphore.signal()
      return
    }

    var request = URLRequest(url: url, timeoutInterval: Double.infinity)
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpMethod = method

    if let headers = headers {
      for (field, value) in headers {
        request.addValue(value, forHTTPHeaderField: field)
      }
    }

    let task = URLSession.shared.dataTask(with: request) { data, _, error in
      if let error = error {
        completion(.failure(error))
//        self.semaphore.signal()
        return
      }

      guard let data = data else {
        let error = NSError(domain: "Empty Response Data", code: 0, userInfo: nil)
        completion(.failure(error))
//        self.semaphore.signal()
        return
      }

      do {
        let decoder = JSONDecoder()
        let responseData = try decoder.decode(responseType, from: data)
//        self.semaphore.signal()
        completion(.success(responseData))
      } catch {
        completion(.failure(error))
      }
    }

    task.resume()
//    semaphore.wait()
  }

  func getProducts(completion: @escaping ([String]) -> Void) {
    let accountsUrl = ApiUrls.getProducts.urlString
    var coinArray: [String] = []

    fetchData(httpMethod: "GET", urlString: accountsUrl, responseType: [Product].self, headers: nil) { result in
      switch result {
      case .success(let allProducts):
        coinArray = allProducts.filter { $0.quoteCurrency == "USD" && $0.auctionMode == false }.map { $0.id }
        completion(coinArray)
//        print(allProducts)
      case .failure(let error):
        print("Error: \(error)")
      }
    }
  }

  func getAccounts(completion: @escaping ([Account]) -> Void) {
    let accountsUrl = ApiUrls.getAccounts.urlString
    let headers = CoinbaseService.shared.createHeaders(requestPath: ApiUrls.getAccounts.requestUrlString)

    fetchData(httpMethod: "GET", urlString: accountsUrl, responseType: [Account].self, headers: headers) { result in
      switch result {
      case .success(let allAccounts):
//        print(allAccounts)
        completion(allAccounts)
      case .failure(let error):
        print("Error: \(error)")
      }
    }
  }

  func getUserProfile() {
    let userProfileUrl = ApiUrls.getUserProfile.urlString
    let headers = CoinbaseService.shared.createHeaders(requestPath: ApiUrls.getUserProfile.requestUrlString)

    fetchData(httpMethod: "GET", urlString: userProfileUrl, responseType: [Profile].self, headers: headers) { result in
      switch result {
      case .success(let profile):
        print(profile)
      case .failure(let error):
        print("Error: \(error)")
      }
    }
  }

  func getProductsStats(productId: String, completion: @escaping (ProductStat?) -> Void) {
    let productUrl = ApiUrls.getProductStats(productId: productId).urlString
//    var semaphore = DispatchSemaphore(value: 0)

    fetchData(httpMethod: "GET", urlString: productUrl, responseType: ProductStat.self, headers: nil) { result in
      switch result {
      case .success(let productStat):
        completion(productStat)
//        print(productStat)
      case .failure(let error):
        print("Error: \(error)")
        completion(nil)
      }
//      semaphore.signal()
    }
//    semaphore.wait()
  }

  func getCurrencies() {
    let currenciesUrl = ApiUrls.getCurrencies.urlString

    fetchData(httpMethod: "GET", urlString: currenciesUrl, responseType: [Currencies].self, headers: nil) { result in
      switch result {
      case .success(let currencies):
        print(currencies)
      case .failure(let error):
        print("Error: \(error)")
      }
    }
  }

  func getProductCandles(productId: String) {
    let productCandlesUrl = ApiUrls.getProductCandles(productId: productId).urlString

    fetchData(httpMethod: "GET", urlString: productCandlesUrl, responseType: [CandlesJSON].self, headers: nil)
      { result in
        switch result {
        case .success(let productCandles):
          print(productCandles)
        case .failure(let error):
          print("Error: \(error)")
        }
      }
  }

  func getOrders() {
    let orderUrl = ApiUrls.getOrders(limits: 5).urlString
    let headers = CoinbaseService.shared.createHeaders(requestPath: ApiUrls.getOrders(limits: 5).requestUrlString)

    fetchData(httpMethod: "GET", urlString: orderUrl, responseType: [Order].self, headers: headers) { result in
      switch result {
      case .success(let allOrders):
        print(allOrders)
      case .failure(let error):
        print("Error: \(error)")
      }
    }
  }
}
