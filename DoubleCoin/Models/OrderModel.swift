//
//  OrderModel.swift
//  DoubleCoin
//
//  Created by 姜權芳 on 2023/6/30.
//

import Foundation
import UIKit

// MARK: - Order

struct Order: Codable {
  let id, price, size, productID: String
  let profileID, side, type, timeInForce: String
  let createdAt, doneAt, doneReason: String
  let fillFees, filledSize, executedValue, marketType: String
  let status: String
  let fundingCurrency: String?
  let postOnly, settled: Bool

  enum CodingKeys: String, CodingKey {
    case id, price, size
    case productID = "product_id"
    case profileID = "profile_id"
    case side, type
    case timeInForce = "time_in_force"
    case postOnly = "post_only"
    case createdAt = "created_at"
    case doneAt = "done_at"
    case doneReason = "done_reason"
    case fillFees = "fill_fees"
    case filledSize = "filled_size"
    case executedValue = "executed_value"
    case marketType = "market_type"
    case status, settled
    case fundingCurrency = "funding_currency"
  }
}

enum SideInfo: String {
  case buy
  case sell

  var color: UIColor {
    switch self {
    case .buy:
      return AppColor.success
    case .sell:
      return AppColor.primary
    }
  }

  var description: String {
    switch self {
    case .buy:
      return "購入 "
    case .sell:
      return "賣出 "
    }
  }
}

enum StatusInfo: String {
  case success
  case cancel

  var color: UIColor {
    switch self {
    case .success:
      return AppColor.success
    case .cancel:
      return AppColor.primary
    }
  }

  var description: String {
    switch self {
    case .success:
      return "成功"
    case .cancel:
      return "已取消"
    }
  }
}
