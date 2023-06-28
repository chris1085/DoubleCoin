//
//  UIImage+Extension.swift
//  DoubleCoin
//
//  Created by 姜權芳 on 2023/6/28.
//

import Foundation
import UIKit

func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
  let renderer = UIGraphicsImageRenderer(size: targetSize)
  let resizedImage = renderer.image { _ in
    image.draw(in: CGRect(origin: .zero, size: targetSize))
  }
  return resizedImage
}
