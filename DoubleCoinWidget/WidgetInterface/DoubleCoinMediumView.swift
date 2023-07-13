//
//  DoubleCoinMediumView.swift
//  DoubleCoinWidgetExtension
//
//  Created by 姜權芳 on 2023/7/12.
//

import Charts
import SwiftUI
import WidgetKit

struct DoubleCoinMediumView: View {
  var candlesTicks: [CandlesTick]
  var account: Account
  var productStat: ProductStat
  var amounts: String

  var lastUpdatedTime: String {
    if let timestamp = candlesTicks.first?.time {
      let dateFormatter = DateFormatter()
      dateFormatter.dateFormat = "HH:mm:ss"
      let date = Date(timeIntervalSince1970: timestamp)
      return dateFormatter.string(from: date)
    }
    return ""
  }

  var balanceText: String {
    guard let formattedNumber = Double(account.balance)?.formatNumber(Double(account.balance)!,
                                                                      max: 4, min: 4, isAddSep: false)
    else {
      return ""
    }

    return formattedNumber
  }

  var startTime: Double {
    return Date().timeIntervalSince1970
  }

  var endTime: Double {
    return startTime - 60000
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
    let curGradient = LinearGradient(gradient: Gradient(
      colors: [
        lineColor.opacity(0.5),
        lineColor.opacity(0.2),
        lineColor.opacity(0.05),
      ]
    ), startPoint: .top, endPoint: .bottom)

    GeometryReader { geometry in
      ZStack(alignment: .topLeading) {
        Color(red: 30/255, green: 30/255, blue: 30/255)

        HStack {
          VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
              Image("btc")
                .resizable()
                .frame(width: 28, height: 28)
                .foregroundColor(.red)

              Text("Wallet")
                .font(.system(size: 16))
                .foregroundColor(.white)
                .bold()
            }
            .padding(.trailing, 14)
            .background(Color(red: 30/255, green: 30/255, blue: 30/255))
            .cornerRadius(geometry.size.height/2)

            Spacer()

            HStack {
              VStack(alignment: .leading, spacing: 4) {
                Text("\(balanceText) \(account.currency)")
                  .font(.system(size: 14))
                  .foregroundColor(.gray)
                  .multilineTextAlignment(.leading)
                  .fixedSize(horizontal: false, vertical: true)

                Text("$ \(amounts)")
                  .font(.system(size: 16))
                  .bold()
                  .foregroundColor(.white)
                  .multilineTextAlignment(.leading)
                  .fixedSize(horizontal: false, vertical: true)
              }

              Spacer()
            }

            .frame(maxWidth: .infinity)
          }
          .padding(.leading, 12)
          .padding(.top, 12)
          .padding(.trailing, 12)
          .padding(.bottom, 12)
          .background(Color(red: 60/255, green: 60/255, blue: 60/255))
          .cornerRadius(24)
          .frame(width: geometry.size.width * 0.5)

          VStack(alignment: .leading, spacing: 0) {
            Text("\(productStat.last)")
              .font(.system(size: 18))
              .fontWeight(.bold)
              .padding(.top, 4)
              .padding(.leading, 12)
              .foregroundColor(lineColor)

            Text(differenceText)
              .font(.system(size: 12))
              .padding(.leading, 12)
              .foregroundColor(lineColor)

            Chart {
              ForEach(candlesTicks) {
                LineMark(
                  x: .value("Time", $0.time),
                  y: .value("Close", $0.close)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(lineColor)

                AreaMark(
                  x: .value("Time", $0.time),
                  y: .value("Close", $0.close)
                ).interpolationMethod(.catmullRom)
                  .foregroundStyle(curGradient)
              }
            }.chartXScale(domain: endTime...startTime)
              .chartYScale(domain: candleValueMin...candleValueMax)
              .chartXAxis(.hidden)
              .chartYAxis(.hidden)
              .padding(.top, 8)
              .padding(.bottom, 6)

            HStack {
              Spacer()

              Text("更新時間：\(lastUpdatedTime)")
                .font(.system(size: 10))
                .foregroundColor(.gray)
                .padding(.bottom, 0)

              Spacer()
            }
          }
        }
        .padding(.leading, 10)
        .padding(.top, 10)
        .padding(.bottom, 10)
      }
    }
  }
}

struct DoubleCoinMediumView_Previews: PreviewProvider {
  static var previews: some View {
    let mockEntry = DoubleCoinEntry.mockTravelEntry()

    DoubleCoinMediumView(
      candlesTicks: mockEntry.candlesTicks,
      account: mockEntry.account,
      productStat: mockEntry.productStat,
      amounts: mockEntry.amounts
    ).previewContext(WidgetPreviewContext(family: .systemMedium))
  }
}
