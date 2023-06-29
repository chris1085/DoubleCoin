//
//  BannerCell.swift
//  DoubleCoin
//
//  Created by 姜權芳 on 2023/6/28.
//

import iCarousel
import UIKit

struct BannerImage {
  var image: String
  var url: String
}

class BannerCell: UITableViewCell {
  @IBOutlet var carousel: iCarousel! {
    didSet {
      carousel.dataSource = self
      carousel.delegate = self
      carousel.type = .linear
      carousel.isPagingEnabled = true
    }
  }

  @IBOutlet var pageControl: UIPageControl! {
    didSet {
      pageControl.numberOfPages = carousel.numberOfItems
      pageControl.currentPage = 0
    }
  }

  @IBOutlet var amountView: UIView! {
    didSet {
      amountView.layer.cornerRadius = 4
      amountView.backgroundColor = AppColor.secondary

      amountView.layer.shadowColor = UIColor.black.cgColor
      amountView.layer.shadowOffset = CGSize(width: 0, height: 1.0)
      amountView.layer.shadowOpacity = 0.15
      amountView.layer.shadowRadius = 4.0
    }
  }

  @IBOutlet var totalAmountLabel: UILabel!
  @IBOutlet var numberLabel: UILabel!
  @IBOutlet var eyeBtn: UIButton! {
    didSet {
      eyeBtn.tintColor = UIColor.darkGray
    }
  }

  @IBAction func eyeBtnTapped(_ sender: UIButton) {
    isEyeBtnHidden = !isEyeBtnHidden

    if isEyeBtnHidden {
      sender.setBackgroundImage(UIImage(systemName: "eye"), for: .normal)
      numberLabel.text = tempNumberLabel
    } else {
      sender.setBackgroundImage(UIImage(systemName: "eye.slash"), for: .normal)
      tempNumberLabel = numberLabel.text!
      numberLabel.text = "✲✲✲✲✲✲"
    }
  }

  @IBOutlet var amountLabel: UILabel!

  var tempNumberLabel = ""
  let images = [
    BannerImage(image: "banner1", url: "https://zh.wikipedia.org/zh-tw/%E4%BB%A5%E5%A4%AA%E5%9D%8A"),
    BannerImage(image: "banner2", url: "https://zh.wikipedia.org/zh-tw/%E6%AF%94%E7%89%B9%E5%B8%81"),
    BannerImage(image: "banner3", url: "https://coinmarketcap.com/zh-tw/currencies/solana/"),
    BannerImage(image: "banner4", url: "https://ethereum.org/zh-tw/")
  ]
  let viewWidth = UIScreen.main.bounds.width
  var imageIndex = 0
  var isEyeBtnHidden = false

  override func awakeFromNib() {
    super.awakeFromNib()

    Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(changeBanner), userInfo: nil, repeats: true)
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }

  @objc func changeBanner() {
    carousel.scrollToItem(at: carousel.currentItemIndex + 1, animated: true)
  }
}

extension BannerCell: iCarouselDelegate, iCarouselDataSource {
  func numberOfItems(in carousel: iCarousel) -> Int {
    images.count
  }

  func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
    let itemImageView = UIImageView(frame: CGRect(x: 0,
                                                  y: 0,
                                                  width: UIScreen.main.bounds.width,
                                                  height: carousel.bounds.height))
    itemImageView.image = UIImage(named: "\(images[index].image)")
    return itemImageView
  }

  func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
    if option == .wrap {
      return 1
    }
    return value
  }

  func carouselCurrentItemIndexDidChange(_ carousel: iCarousel) {
    pageControl.currentPage = carousel.currentItemIndex
  }

  func carousel(_ carousel: iCarousel, didSelectItemAt index: Int) {
    let websiteURL = URL(string: images[index].url)
    if let url = websiteURL {
      if UIApplication.shared.canOpenURL(url) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
      } else {
        print("無法打開URL: \(url)")
      }
    }
  }
}
