//
//  ChartsUtils.swift
//  DoubleCoin
//
//  Created by 姜權芳 on 2023/7/3.
//

import Charts
import Foundation

class XAxisValueFormatter: IndexAxisValueFormatter {
  var labels: [String] = []
  init(monthlyTotalAmounts: [String: Int]) {
    let sortedItems = monthlyTotalAmounts.sorted { $0.key < $1.key }
    self.labels = sortedItems.map { $0.key }

    super.init()
  }

  override func stringForValue(_ value: Double, axis: AxisBase?) -> String {
    guard let index = labels.indices.last(where: { value >= Double($0) }) else {
      return ""
    }
    return labels[index]
  }
}

class ImageMarkerView: MarkerView {
  private var circleImageView: UIImageView?
  private var circleImage: UIImage?
  private var imageSize: CGSize

  init(color: UIColor, font: UIFont, textColor: UIColor, insets: UIEdgeInsets, image: UIImage?) {
    self.circleImage = image
    self.imageSize = image?.size ?? CGSize.zero

    super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))

    self.backgroundColor = .clear

    self.circleImageView = UIImageView(image: circleImage)
    circleImageView?.frame.size = imageSize
    addSubview(circleImageView!)

    circleImageView?.center = CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2)
  }

  @available(*, unavailable)
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func offsetForDrawing(atPoint point: CGPoint) -> CGPoint {
    let offset = super.offsetForDrawing(atPoint: point)
    return offset
  }
}
