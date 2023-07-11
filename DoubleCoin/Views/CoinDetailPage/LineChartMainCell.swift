//
//  LineChartMainCell.swift
//  DoubleCoin
//
//  Created by 姜權芳 on 2023/6/30.
//

import Charts
import UIKit

protocol LineChartMainCellDelegate: AnyObject {
  func didTimeBtnTapped(timeline: String, tag: Int)
}

class LineChartMainCell: UITableViewCell, ChartViewDelegate {
  @IBOutlet var buySellPriceView: UIView!
  @IBOutlet var buyPriceLabel: UILabel!
  @IBOutlet var sellPriceLabel: UILabel!
  @IBOutlet var timeSeriesStackView: UIStackView!
  @IBOutlet var chartView: LineChartView! {
    didSet {
      chartView.setViewPortOffsets(left: 0, top: 0, right: 0, bottom: 8)
    }
  }

  @IBOutlet var historyView: UIView! {
    didSet {
      historyView.isHidden = true
    }
  }

  @IBOutlet var historyPriceLabel: UILabel!
  @IBOutlet var historyTimeLabel: UILabel!

  var delegate: LineChartMainCellDelegate?
  let timelines: [String] = ["1D", "1W", "1M", "3M", "1Y", "All"]
  var selectedButton: UIButton?
  var data: LineChartData!
  var minXIndex: Double!
  var maxXIndex: Double!
  var dataSet: LineChartDataSet!
  var dataEntries: [ChartDataEntry] = []
  var ticksData: [Double] = []
  var candlesTicks: [CandlesTick] = []

  override func awakeFromNib() {
    super.awakeFromNib()
    createTimelineButtons()
//    selectDefaultButton()
//    setChartView(dataArray: ticksData)
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    // Configure the view for the selected state
  }

  private func createTimelineButtons() {
    var index = 0

    for timeline in timelines {
      let button = UIButton()
      button.tag = index
      button.accessibilityIdentifier = timeline
      button.setTitle(timeline, for: .normal)
      button.titleLabel?.font = UIFont(name: "PingFang-TC", size: 14)
      button.setTitleColor(UIColor.secondaryLabel, for: .normal)
      button.setTitleColor(AppColor.primary, for: .selected)

      button.contentHorizontalAlignment = .center
      button.contentVerticalAlignment = .center
      button.addTarget(self, action: #selector(timelineButtonTapped(_:)), for: .touchUpInside)
      timeSeriesStackView.addArrangedSubview(button)
      index += 1
    }

    timeSeriesStackView.distribution = .fillEqually
    timeSeriesStackView.spacing = 2
  }

  @objc private func timelineButtonTapped(_ sender: UIButton) {
    guard let timeline = sender.accessibilityIdentifier else { return }
    delegate?.didTimeBtnTapped(timeline: timeline, tag: sender.tag)

//    guard let index = timelines.firstIndex(of: sender.accessibilityIdentifier ?? "") else {
//      return
//    }
  }

  func selectDefaultButton(tag: Int) {
    // 移除未選中按鈕的底線 CALayer
    for case let button as UIButton in timeSeriesStackView.arrangedSubviews {
      button.titleLabel?.font = UIFont.systemFont(ofSize: 17) // 恢復按鈕的字型

      button.layer.sublayers?.forEach { layer in
        if layer.backgroundColor == AppColor.primary.cgColor {
          layer.removeFromSuperlayer() // 移除未選中按鈕的紅線底線
          button.setTitleColor(UIColor.secondaryLabel, for: .normal)
        }
      }
    }

    DispatchQueue.main.async {
      if let defaultButton = self.timeSeriesStackView.arrangedSubviews[tag] as? UIButton {
        defaultButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17) // 設置預設按鈕的粗體字型
        defaultButton.setTitleColor(AppColor.primary, for: .normal)
        // 新增選中預設按鈕的底線 CALayer
        let bottomLineLayer = CALayer()
        bottomLineLayer.backgroundColor = AppColor.primary.cgColor
        bottomLineLayer.frame = CGRect(x: 8, y: defaultButton.bounds.height - 4,
                                       width: defaultButton.bounds.width - 16, height: 4)
        defaultButton.layer.addSublayer(bottomLineLayer)
      }
    }
  }

  func setChartView(dataArray: [Double]) {
    chartView.delegate = self
    chartView.chartDescription.enabled = false
    chartView.legend.enabled = false
    chartView.xAxis.enabled = false
    chartView.leftAxis.enabled = false
    chartView.rightAxis.enabled = false
    chartView.scaleXEnabled = false
    chartView.scaleYEnabled = false
    chartView.doubleTapToZoomEnabled = false
//        lineChartView.xAxis.valueFormatter = XAxisValueFormatter(monthlyTotalAmounts: monthlyTotalAmounts)
    // 設定折線圖的數據

    changeChartViewData(dataArray: ticksData)
  }

  func changeChartViewData(dataArray: [Double]) {
    chartView.data = nil
    chartView.xAxis.valueFormatter = nil
    chartView.marker = nil
    chartView.notifyDataSetChanged()
    minXIndex = Double(dataArray.firstIndex(of: dataArray.min()!)!) + 1
    maxXIndex = Double(dataArray.firstIndex(of: dataArray.max()!)!) + 1
    dataEntries = []
    dataSet = nil
    for index in 0 ..< dataArray.count {
      let formattedValue = String(format: "%.2f", dataArray[index])
      let dataEntry = ChartDataEntry(x: Double(index + 1), y: Double(formattedValue) ?? 0)
      dataEntries.append(dataEntry)
    }

    dataSet = LineChartDataSet(entries: dataEntries)
    dataSet.mode = .linear
    dataSet.drawCirclesEnabled = false
    dataSet.valueFormatter = self
    dataSet.highlightLineWidth = 1.5
    dataSet.highlightColor = .red
    dataSet.highlightEnabled = true
    dataSet.drawHorizontalHighlightIndicatorEnabled = false
    dataSet.lineWidth = 1.5
    dataSet.colors = [UIColor.red]
    dataSet.valueColors = [UIColor.red]
    dataSet.valueFont = .systemFont(ofSize: 12)
    data = LineChartData(dataSet: dataSet)
    chartView.data = data

    if let data = chartView.data {
      if let lineDataSet = data.dataSets.first as? LineChartDataSet {
        let startColor = UIColor.red
        let endColor = UIColor.white
        let gradientColors = [startColor.cgColor, endColor.cgColor] as CFArray
        let colorLocations: [CGFloat] = [0.0, 1.0]
        if let gradient = CGGradient(colorsSpace: nil, colors: gradientColors, locations: colorLocations) {
          lineDataSet.fill = LinearGradientFill(gradient: gradient, angle: 270)
          lineDataSet.drawFilledEnabled = true
        }
      }
    }

    if let selectedEntry = dataEntries.first {
      let coinImage = UIImage(named: "fulldown")
      let coinMarker = ImageMarkerView(color: .clear, font: .systemFont(ofSize: 10), textColor: .white,
                                       insets: .zero, image: coinImage)
      coinMarker.refreshContent(entry: selectedEntry, highlight: Highlight(x: selectedEntry.x, y: selectedEntry.y,
                                                                           dataSetIndex: 0))
      chartView.marker = coinMarker
    }

    chartView.notifyDataSetChanged()
  }

  func chartViewDidEndPanning(_ chartView: ChartViewBase) {
    guard let lineChartView = chartView as? LineChartView else {
      return
    }
    historyView.isHidden = true
    lineChartView.data?.dataSets.forEach { dataSet in
      if dataSet is LineChartDataSet {
        lineChartView.highlightValues([])
      }
    }
  }

  func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
    print(entry)
    let tickIndex = Int(entry.x) - 1
    let timestamp = candlesTicks[tickIndex].time.formatDate(epoch: candlesTicks[tickIndex].time,
                                                            dateFormat: "yyyy-MM-dd HH:mm:ss")
    historyPriceLabel.text = "\(entry.y)"
    historyTimeLabel.text = timestamp
    historyView.isHidden = false
  }

  func setTicksData() {
    if candlesTicks.count == 0 { return }
    ticksData = candlesTicks.map { ($0.high + $0.low) / 2 }
    setChartView(dataArray: ticksData)
  }
}

extension LineChartMainCell: ValueFormatter {
  func stringForValue(_ value: Double, entry: Charts.ChartDataEntry, dataSetIndex: Int, viewPortHandler: Charts.ViewPortHandler?) -> String {
    if entry.x == minXIndex || entry.x == maxXIndex {
      entry.icon = UIImage(named: "down")

      return "\(value)"
    } else {
      return ""
    }
  }
}
