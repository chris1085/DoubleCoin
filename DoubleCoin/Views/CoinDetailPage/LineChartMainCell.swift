//
//  LineChartMainCell.swift
//  DoubleCoin
//
//  Created by 姜權芳 on 2023/6/30.
//

import Charts
import UIKit

class LineChartMainCell: UITableViewCell {
  @IBOutlet var buyPriceLabel: UILabel!
  @IBOutlet var sellPriceLabel: UILabel!
  @IBOutlet var timeSeriesStackView: UIStackView!
  @IBOutlet var chartView: LineChartView!
  let timelines: [String] = ["1D", "1W", "1M", "3M", "1Y", "ALL"]
  var selectedButton: UIButton?
  override func awakeFromNib() {
    super.awakeFromNib()
    createTimelineButtons()
    selectDefaultButton()
    // Initialization code
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)

    // Configure the view for the selected state
    if selected {
      updateButtonStyle(selectedButton!)
    }
  }

  private func createTimelineButtons() {
    for timeline in timelines {
      let button = UIButton()
      button.setTitle(timeline, for: .normal)
      button.titleLabel?.font = UIFont(name: "PingFang-TC", size: 14)
      button.setTitleColor(UIColor.secondaryLabel, for: .normal)
      button.setTitleColor(AppColor.primary, for: .selected)

      button.contentHorizontalAlignment = .center
      button.contentVerticalAlignment = .center
      button.addTarget(self, action: #selector(timelineButtonTapped(_:)), for: .touchUpInside)
      timeSeriesStackView.addArrangedSubview(button)
    }

    timeSeriesStackView.distribution = .fillEqually
    timeSeriesStackView.spacing = 2 // 添加間距模擬分隔線
  }

  @objc private func timelineButtonTapped(_ sender: UIButton) {
    if sender.isSelected {
      return
    }

    // 反轉按鈕的選中狀態
    sender.isSelected.toggle()

    // 更新按鈕的樣式
    updateButtonStyle(sender)
  }

  private func updateButtonStyle(_ selectedButton: UIButton) {
    self.selectedButton?.isSelected = false // 取消之前選中按鈕的選中狀態
    self.selectedButton?.titleLabel?.font = UIFont(name: "PingFang-TC", size: 14)
    self.selectedButton?.subviews.first?.isHidden = true // 隱藏之前選中按鈕的底線

    selectedButton.isSelected = true // 設置新選中按鈕的選中狀態
    selectedButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
    selectedButton.subviews.first?.isHidden = false // 顯示新選中按鈕的底線

    self.selectedButton = selectedButton // 更新被選中的按鈕

    // 移除未選中按鈕的底線 CALayer
    for case let button as UIButton in timeSeriesStackView.arrangedSubviews {
      guard button != selectedButton else { continue } // 略過選中按鈕
      button.layer.sublayers?.forEach { layer in
        if layer.backgroundColor == AppColor.primary.cgColor {
          layer.removeFromSuperlayer() // 移除未選中按鈕的紅線底線
        }
      }
    }

    // 新增選中按鈕的底線 CALayer
    let bottomLineLayer = CALayer()
    bottomLineLayer.backgroundColor = AppColor.primary.cgColor
    bottomLineLayer.frame = CGRect(x: 8, y: selectedButton.bounds.height - 4,
                                   width: selectedButton.bounds.width - 16, height: 4)
    selectedButton.layer.addSublayer(bottomLineLayer)

    timeSeriesStackView.layoutIfNeeded()
  }

  private func selectDefaultButton() {
    DispatchQueue.main.async {
      if let defaultButton = self.timeSeriesStackView.arrangedSubviews[2] as? UIButton {
        defaultButton.isSelected = true // 設置預設按鈕為選中狀態
        defaultButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17) // 設置預設按鈕的粗體字型

        // 新增選中預設按鈕的底線 CALayer
        let bottomLineLayer = CALayer()
        bottomLineLayer.backgroundColor = AppColor.primary.cgColor
        bottomLineLayer.frame = CGRect(x: 8, y: defaultButton.bounds.height - 4,
                                       width: defaultButton.bounds.width - 16, height: 4)
        defaultButton.layer.addSublayer(bottomLineLayer)

        self.selectedButton = defaultButton // 更新被選中的按鈕
      }
    }
  }
}
