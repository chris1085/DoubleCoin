//
//  TimeRangeCalculator.swift
//  DoubleCoin
//
//  Created by 姜權芳 on 2023/7/3.
//

import Foundation

enum DateUtils {
  static func date(from string: String, format: String) -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    return dateFormatter.date(from: string)
  }

  static func string(from date: Date?, format: String) -> String? {
    guard let date = date else { return nil }

    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    return dateFormatter.string(from: date)
  }
}
