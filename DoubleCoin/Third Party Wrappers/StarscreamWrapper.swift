//
//  StarscreamWrapper.swift
//  DoubleCoin
//
//  Created by 姜權芳 on 2023/6/30.
//

import Foundation
import Starscream

class CoinbaseWebSocketClient: WebSocketDelegate {
  var socket: WebSocket
  var productID: String?

  init(productID: String) {
    self.productID = productID
    let url = URL(string: "wss://ws-feed-public.sandbox.exchange.coinbase.com")!
//    let url = URL(string: "wss://ws-feed.exchange.coinbase.com")!
    var request = URLRequest(url: url)
    request.timeoutInterval = 5
    socket = WebSocket(request: request)
    socket.delegate = self
    socket.connect()
  }

  func didReceive(event: WebSocketEvent, client: WebSocket) {
    switch event {
    case .connected:

      guard let productID = productID else { return }

      let subscribeMessage = """
      {
          "type": "subscribe",
          "product_ids": ["\(productID)"],
          "channels": ["ticker_batch"]
      }
      """
      socket.write(string: subscribeMessage)
      print("connected")

    case let .disconnected(error, code):
      print("WebSocket disconnect error message：\(error)，error code：\(code)")

      DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
        self.socket.connect()
      }

    case let .text(text):
      print("test")
      if let data = text.data(using: .utf8) {
        if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
          if let type = json["type"] as? String, type == "ticker" {
            if let productId = json["product_id"] as? String,
               let price = json["price"] as? String,
               let side = json["side"] as? String
            {
              print("Product ID: \(productId), Side: \(side), Price: \(price)")
            }
          }
        }
      }

    default:
      break
    }
  }
}
