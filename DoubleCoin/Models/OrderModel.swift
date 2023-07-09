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
  let id, size, productID, profileID: String
  let side, type: String
  let createdAt, doneAt, doneReason, fillFees: String
  let filledSize, executedValue, marketType, status: String
  let fundingCurrency: String
  let settled, postOnly: Bool
  let funds: String?

  enum CodingKeys: String, CodingKey {
    case id, size
    case productID = "product_id"
    case profileID = "profile_id"
    case side, funds, type
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

// MARK: - OrderPost

struct OrderPost: Codable {
  let id, size, productID, side: String
  let stp, type: String
  let createdAt, fillFees, filledSize, executedValue: String
  let status: String
  let settled, postOnly: Bool
  let funds: String?

  enum CodingKeys: String, CodingKey {
    case id, size
    case productID = "product_id"
    case side, stp, funds, type
    case postOnly = "post_only"
    case createdAt = "created_at"
    case fillFees = "fill_fees"
    case filledSize = "filled_size"
    case executedValue = "executed_value"
    case status, settled
  }
}
