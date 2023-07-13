//
//  DoubleCoinLargeView.swift
//  DoubleCoinWidgetExtension
//
//  Created by 姜權芳 on 2023/7/12.
//

import SwiftUI

struct DoubleCoinLargeView: View {
  var candlesTicks: [CandlesTick]
  var account: Account
  var productStat: ProductStat
  var body: some View {
    Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
  }
}

struct DoubleCoinLargeView_Previews: PreviewProvider {
  static var previews: some View {
    let mockEntry = DoubleCoinEntry.mockTravelEntry()

    return DoubleCoinLargeView(
      candlesTicks: mockEntry.candlesTicks,
      account: mockEntry.account,
      productStat: mockEntry.productStat
    )
  }
}
