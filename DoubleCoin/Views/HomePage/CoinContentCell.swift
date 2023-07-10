//
//  CoinContentCell.swift
//  DoubleCoin
//
//  Created by 姜權芳 on 2023/6/28.
//

import Charts
import UIKit

class CoinContentCell: UITableViewCell {
  @IBOutlet var coinImageView: UIImageView! {
    didSet {
      coinImageView.layer.cornerRadius = coinImageView.frame.width / 2
    }
  }

  @IBOutlet var coinNameLabel: UILabel!
  @IBOutlet var coinNameZhLabel: UILabel!
  @IBOutlet var runChartView: LineChartView!
  @IBOutlet var priceLabel: UILabel!
  @IBOutlet var quoteChangeLabel: UILabel!

  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    // Configure the view for the selected state
  }

  func configureContentCell(data: ProductTableStat) {
    if let productInfo = ProductInfo.fromTableStatName(data.name) {
      guard let image = productInfo.image else { return }
      coinNameLabel.text = productInfo.name
      coinNameZhLabel.text = productInfo.chtName
      coinImageView.image = image

      guard let lastPrice = Double(data.productStat.last),
            let openPrice = Double(data.productStat.open) else { return }

      let priceAvg = ((Double(data.productStat.high) ?? 0) + (Double(data.productStat.low) ?? 0)) / 2
      let priceAvgFormatted = priceAvg.formatNumber(priceAvg, max: 6, min: 0, isAddSep: true)
      priceLabel.text = String(priceAvgFormatted ?? "")

      let quoteChange = (lastPrice - openPrice) / lastPrice * 100
      if let formattedQuoteChange = quoteChange.formatNumber(quoteChange, max: 2, min: 0, isAddSep: true) {
        if quoteChange > 0 {
          quoteChangeLabel.text = "+\(formattedQuoteChange)%"
          quoteChangeLabel.textColor = AppColor.success
          setChartView(color: AppColor.success)
        } else if quoteChange < 0 {
          quoteChangeLabel.text = "\(formattedQuoteChange)%"
          quoteChangeLabel.textColor = AppColor.primary
          setChartView(color: AppColor.primary)
        } else if quoteChange == 0 {
          quoteChangeLabel.text = "\(formattedQuoteChange)%"
          quoteChangeLabel.textColor = UIColor.black
          setChartView(color: UIColor.black)
        } else {
          quoteChangeLabel.text = "0.00%"
          quoteChangeLabel.textColor = UIColor.black
          setChartView(color: UIColor.black)
        }
      }
    }
  }

  func setChartView(color: UIColor) {
    runChartView.chartDescription.enabled = false
    runChartView.legend.enabled = false
    runChartView.xAxis.enabled = false
    runChartView.leftAxis.enabled = false
    runChartView.rightAxis.enabled = false
//    runChartView.dragEnabled = false
//    runChartView.highlightPerDragEnabled = false
//    runChartView.drawMarkers = false
//    runChartView.highlightPerTapEnabled = false
    runChartView.isUserInteractionEnabled = false

    var values: [Double] = []
    var valueArray: [Double] = []

    for _ in 1...30 {
      let randomValue = Double.random(in: 10...25)
      valueArray.append(randomValue)
    }

    var dataEntries: [ChartDataEntry] = []
    if valueArray.count >= 10 {
      while values.count < 10 {
        let randomIndex = Int.random(in: 0..<valueArray.count)
        let randomValue = valueArray[randomIndex]
        values.append(randomValue)
      }
    }

    for index in 0..<values.count {
      let dataEntry = ChartDataEntry(x: Double(index), y: values[index])
      dataEntries.append(dataEntry)
    }

    if dataEntries.isEmpty {
      return
    }

    let dataSet = LineChartDataSet(entries: dataEntries, label: "Line Data Set")
    dataSet.mode = .cubicBezier
    dataSet.cubicIntensity = 0.15
    dataSet.drawCirclesEnabled = false
    dataSet.drawValuesEnabled = false
    dataSet.lineWidth = 2.0
    dataSet.colors = [color]

    let data = LineChartData(dataSets: [dataSet])
    runChartView.data = data
  }
}
