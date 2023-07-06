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
  static let productionUrl = "https://api.exchange.coinbase.com"
  static let exchangeRateUrl = "https://api.coinbase.com/v2"

  case getProducts
  case getAccounts
  case getUserProfile
  case getProductStats(productId: String)
  case getCurrencies
  case getProductCandles(productId: String, start: String, end: String, granularity: String)
  case getOrders(limits: Int, productId: String)
  case createOrder
  case getExchangeDollars(dollars: String, date: String)
  case getSingleOrder(orderId: String)

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
    case .getProductCandles(let productId, let start, let end, let granularity):
      return ApiUrls.baseUrl + "/products/\(productId)/candles?start=\(start)&end=\(end)&granularity=\(granularity)"
    case .getOrders(let limits, let productId):
      return ApiUrls.baseUrl + "/orders?limit=\(limits)&status=done&product_id=\(productId)"
    case .createOrder:
      return ApiUrls.baseUrl + "/orders"
    case .getExchangeDollars(let dollars, let date):
      return ApiUrls.exchangeRateUrl + "/exchange-rates?currency=\(dollars)&date=\(date)"
    case .getSingleOrder(let orderId):
      return ApiUrls.baseUrl + "/orders/\(orderId)"
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
    case .getProductCandles(let productId, let start, let end, let granularity):
      return "/products/\(productId)/candles?start=\(start)&end=\(end)&granularity=\(granularity)"
    case .getOrders(let limits, let productId):
      return "/orders?limit=\(limits)&status=done&product_id=\(productId)"
    case .createOrder:
      return "/orders"
    case .getExchangeDollars(let dollars, let date):
      return "/exchange-rates?currency=\(dollars)&date=\(date)"
    case .getSingleOrder(let orderId):
      return "/orders/\(orderId)"
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

  func fetchData<T: Decodable>(httpMethod: String, urlString: String, responseType: T.Type,
                               headers: [String: String]?, body: String,
                               completion: @escaping (Result<T, Error>) -> Void)
  {
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
    request.httpBody = body.data(using: .utf8)

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
//        print(String(data: data, encoding: .utf8))
        completion(.failure(error))
      }
    }

    task.resume()
//    semaphore.wait()
  }

  func getProducts(completion: @escaping ([String]) -> Void) {
    let accountsUrl = ApiUrls.getProducts.urlString
    var coinArray: [String] = []

    fetchData(httpMethod: "GET", urlString: accountsUrl, responseType: [Product].self, headers: nil, body: "")
      { result in
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
    let headers = CoinbaseService.shared.createHeaders(requestPath: ApiUrls.getAccounts.requestUrlString,
                                                       body: "", method: HttpMethod.get.rawValue)

    fetchData(httpMethod: "GET", urlString: accountsUrl, responseType: [Account].self, headers: headers, body: "")
      { result in
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
    let headers = CoinbaseService.shared.createHeaders(requestPath: ApiUrls.getUserProfile.requestUrlString,
                                                       body: "", method: HttpMethod.get.rawValue)

    fetchData(httpMethod: "GET", urlString: userProfileUrl, responseType: [Profile].self, headers: headers, body: "")
      { result in
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

    fetchData(httpMethod: "GET", urlString: productUrl, responseType: ProductStat.self, headers: nil, body: "")
      { result in
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

    fetchData(httpMethod: "GET", urlString: currenciesUrl, responseType: [Currencies].self, headers: nil, body: "")
      { result in
        switch result {
        case .success(let currencies):
          print(currencies)
        case .failure(let error):
          print("Error: \(error)")
        }
      }
  }

  func getProductCandles(productId: String, from start: String, to end: String, granularity: String,
                         completion: @escaping ([Candlestick]?) -> Void)
  {
    let productCandlesUrl = ApiUrls.getProductCandles(productId: productId, start: start, end: end,
                                                      granularity: granularity).urlString
    print(productCandlesUrl)

    fetchData(httpMethod: "GET", urlString: productCandlesUrl, responseType: [CandlesJSON].self, headers: nil, body: "")
      { result in
        switch result {
        case .success(let productCandles):
          let candlesticks = self.candlesToCandlestick(candles: productCandles)
//          print(candlesticks)
          completion(candlesticks)
        case .failure(let error):
          print("Error: \(error)")
          completion(nil)
        }
      }
  }

  func getOrders(productId: String, completion: @escaping ([Order]?) -> Void) {
    let orderUrl = ApiUrls.getOrders(limits: 5, productId: productId).urlString
    let headers = CoinbaseService.shared.createHeaders(
      requestPath: ApiUrls.getOrders(limits: 5, productId: productId).requestUrlString,
      body: "", method: HttpMethod.get.rawValue)

    fetchData(httpMethod: "GET", urlString: orderUrl, responseType: [Order].self, headers: headers, body: "")
      { result in
        switch result {
        case .success(let allOrders):
          print(allOrders)
          completion(allOrders)
        case .failure(let error):
          print("Error: \(error)")
          completion(nil)
        }
      }
  }

  func getSingleOrder(orderId: String, completion: @escaping (Order?) -> Void) {
    let singleOrderUrl = ApiUrls.getSingleOrder(orderId: orderId).urlString
    let headers = CoinbaseService.shared.createHeaders(
      requestPath: ApiUrls.getSingleOrder(orderId: orderId).requestUrlString,
      body: "", method: HttpMethod.get.rawValue)

    fetchData(httpMethod: "GET", urlString: singleOrderUrl, responseType: Order.self, headers: headers, body: "")
      { result in
        switch result {
        case .success(let singleOrder):
          print(singleOrder)
          completion(singleOrder)
        case .failure(let error):
          print("Error: \(error)")
          completion(nil)
        }
      }
  }

  func creatOrder(size: String, side: String, productId: String, completion: @escaping (OrderPost?) -> Void) {
//    let body = "{\"price\": \"\(price)\", \"size\": \"\(size)\", \"side\": \"\(side)\", \"product_id\": \"\(productId)\", \"time_in_force\": \"FOK\"}"
    let body = "{\"type\": \"market\", \"size\": \"\(size)\", \"side\": \"\(side)\", \"product_id\": \"\(productId)\", \"time_in_force\": \"FOK\"}"
    let orderUrl = ApiUrls.createOrder.urlString
    let headers = CoinbaseService.shared.createHeaders(
      requestPath: ApiUrls.createOrder.requestUrlString, body: body, method: HttpMethod.post.rawValue)

    fetchData(httpMethod: "POST", urlString: orderUrl, responseType: OrderPost.self, headers: headers, body: body)
      { result in
        switch result {
        case .success(let orderInfo):
          print(orderInfo)
          completion(orderInfo)
        case .failure(let error):
          print("Error: \(error)")
          completion(nil)
        }
      }
  }

  func getExchangeDollars(dollars: String, dateTime: String, completion: @escaping (ExchangeRate?) -> Void) {
    let exchangeUrl = ApiUrls.getExchangeDollars(dollars: dollars, date: dateTime).urlString

    fetchData(httpMethod: "GET", urlString: exchangeUrl, responseType: ExchangeRate.self, headers: nil, body: "")
      { result in
        switch result {
        case .success(let exchange):
//          print(exchange)
          completion(exchange)
        case .failure(let error):
          print("Error: \(error)")
          completion(nil)
        }
      }
  }

  private func candlesToCandlestick(candles: [CandlesJSON]) -> [Candlestick] {
    var candlesticks: [Candlestick] = []
    for candle in candles where candle.count == 6 {
      let candlestick = Candlestick(time: candle[0], low: candle[1], high: candle[2],
                                    open: candle[3], close: candle[4], volume: candle[5])
      candlesticks.append(candlestick)
    }

    return candlesticks
  }
}
