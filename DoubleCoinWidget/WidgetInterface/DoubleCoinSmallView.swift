//
//  DoubleCoinSmallView.swift
//  DoubleCoinWidgetExtension
//
//  Created by 姜權芳 on 2023/7/12.
//

import Charts
import SwiftUI
import WidgetKit

struct DoubleCoinSmallView: View {
  var candlesTicks: [CandlesTick]
  var account: Account
  var productStat: ProductStat

  var lastUpdatedTime: String {
    if let timestamp = candlesTicks.first?.time {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "HH:mm:ss"
      let date = Date(timeIntervalSince1970: timestamp)
      return dateFormatter.string(from: date)
    }
    return ""
  }

  var startTime: Double {
    return Date().timeIntervalSince1970 + 10800
  }

  var endTime: Double {
    return startTime - 75600
  }

  var candleValueMax: Double {
    return candlesTicks.reduce(Double.leastNormalMagnitude) { max($0, $1.close) }
  }

  var candleValueMin: Double {
    return candlesTicks.reduce(Double.greatestFiniteMagnitude) { min($0, $1.close) }
  }

  var lineColor: Color {
    if let lastPrice = Double(productStat.last),
       let openPrice = Double(productStat.open)
    {
      let priceDifference = lastPrice - openPrice

      if priceDifference < 0 {
        return .red
      } else if priceDifference > 0 {
        return .green
      }
    }
    return .white
  }

  var differenceText: String {
    if let lastPrice = Double(productStat.last),
       let openPrice = Double(productStat.open)
    {
      let priceDifference = lastPrice - openPrice
      let priceQuoteChange = (lastPrice - openPrice)/openPrice * 100
      var formattedPrice = priceDifference.formatNumber(priceDifference, max: 2, min: 2, isAddSep: false)
      var formattedPriceQuoteChange = priceQuoteChange.formatNumber(priceQuoteChange, max: 2, min: 2, isAddSep: false)
      if priceDifference < 0 {
        return "▼\(formattedPrice!) (\(formattedPriceQuoteChange!)%)"
      } else if priceDifference > 0 {
        return "▲\(formattedPrice!) (\(formattedPriceQuoteChange!)%)"
      } else {
        return "\(formattedPrice!) (\(formattedPriceQuoteChange!)%)"
      }
    }
    return ""
  }

  var body: some View {
    ZStack(alignment: .topLeading) {
      Color(red: 30/255, green: 30/255, blue: 30/255) //

      VStack(alignment: .leading, spacing: 4) {
        HStack {
          Image("btc")
            .resizable()
            .frame(width: 16, height: 16)

          Text("比特幣 \(account.currency)")
            .font(.system(size: 14))
            .foregroundColor(.white)

          Spacer()
        }
        .padding(.top, 12)
        .padding(.leading, 12)

        VStack(alignment: .leading, spacing: 2) {
          if let lastPrice = Double(productStat.last),
             let openPrice = Double(productStat.open)
          {
            let priceDifference = lastPrice - openPrice
            let priceQuoteChange = (lastPrice - openPrice)/openPrice * 100
            var formattedPrice = priceDifference.formatNumber(priceDifference, max: 2, min: 2, isAddSep: false)
            var formattedPriceQuoteChange = priceQuoteChange.formatNumber(priceQuoteChange, max: 2, min: 2, isAddSep: false)

            Text("\(productStat.last)")
              .font(.system(size: 18))
              .fontWeight(.bold)
              .padding(.leading, 12)
              .foregroundColor(lineColor)

            Text(differenceText)
              .font(.system(size: 12))
              .padding(.leading, 12)
              .foregroundColor(lineColor)
            //            .frame(maxWidth: .infinity, alignment: .leading)
          }
        }

        Spacer()

        Chart {
          ForEach(candlesTicks) {
            LineMark(
              x: .value("Time", $0.time),
              y: .value("Close", $0.close)
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(lineColor)
          }
        }.chartXScale(domain: endTime...startTime)
          .chartYScale(domain: candleValueMin...candleValueMax)
          .chartXAxis(.hidden)
          .chartYAxis(.hidden)

        HStack {
          Spacer()

          Text("更新時間：\(lastUpdatedTime)")
            .font(.system(size: 10))
            .foregroundColor(.gray)
            .padding(.bottom, 8)

          Spacer()
        }
      }
    }
  }
}

struct DoubleCoinSmallView_Previews: PreviewProvider {
  static var previews: some View {
    let mockEntry = DoubleCoinEntry.mockTravelEntry()

    DoubleCoinSmallView(
      candlesTicks: mockEntry.candlesTicks,
      account: mockEntry.account,
      productStat: mockEntry.productStat
    ).previewContext(WidgetPreviewContext(family: .systemSmall))
  }
}
