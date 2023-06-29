//
//  BannerCell.swift
//  DoubleCoin
//
//  Created by 姜權芳 on 2023/6/28.
//

import UIKit

struct BannerImage {
  var image: String
  var url: String
}

class BannerCell: UITableViewCell {
  @IBOutlet var collectionView: UICollectionView! {
    didSet {
      collectionView.dataSource = self
      collectionView.delegate = self
    }
  }

  @IBOutlet var pageControl: UIPageControl! {
    didSet {
      pageControl.numberOfPages = images.count - 1
    }
  }

  @IBOutlet var amountView: UIView! {
    didSet {
      amountView.layer.cornerRadius = 6
      amountView.backgroundColor = AppColor.secondary
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
      numberLabel.text = "35,878"
    } else {
      sender.setBackgroundImage(UIImage(systemName: "eye.slash"), for: .normal)
      numberLabel.text = "******"
    }
  }

  @IBOutlet var amountLabel: UILabel!

  let images = [
    BannerImage(image: "banner1", url: "https://zh.wikipedia.org/zh-tw/%E4%BB%A5%E5%A4%AA%E5%9D%8A"),
    BannerImage(image: "banner2", url: "https://zh.wikipedia.org/zh-tw/%E6%AF%94%E7%89%B9%E5%B8%81"),
    BannerImage(image: "banner3", url: "https://coinmarketcap.com/zh-tw/currencies/solana/"),
    BannerImage(image: "banner4", url: "https://ethereum.org/zh-tw/"),
    BannerImage(image: "banner1", url: "https://zh.wikipedia.org/zh-tw/%E4%BB%A5%E5%A4%AA%E5%9D%8A")
  ]
  let viewWidth = UIScreen.main.bounds.width
  var imageIndex = 0
  var isEyeBtnHidden = false

  override func awakeFromNib() {
    super.awakeFromNib()

    setupCollectionView()
  }

  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }

  func setupCollectionView() {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    layout.sectionInset = UIEdgeInsets.zero
    layout.itemSize = CGSize(width: viewWidth, height: 240)
    layout.minimumLineSpacing = CGFloat(integerLiteral: Int(0))
    layout.scrollDirection = UICollectionView.ScrollDirection.horizontal

    collectionView.collectionViewLayout = layout
    collectionView.registerCellWithNib(identifier: String(describing: BannerCollectionViewCell.self), bundle: nil)
    collectionView.isPagingEnabled = true
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.showsVerticalScrollIndicator = false

    Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(changeBanner), userInfo: nil, repeats: true)
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleImageTap(_:)))
    collectionView.addGestureRecognizer(tapGesture)
  }

  @objc func changeBanner() {
    imageIndex += 1
    let indexPath = IndexPath(item: imageIndex, section: 0)
    if imageIndex == images.count {
      imageIndex = 0
      collectionView.scrollToItem(at: IndexPath(item: imageIndex, section: 0),
                                  at: .centeredHorizontally, animated: false)
      changeBanner()
    } else if imageIndex < images.count {
      collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
      pageControl.currentPage = imageIndex == 4 ? 0 : imageIndex
    }
  }

  @objc func handleImageTap(_ gesture: UITapGestureRecognizer) {
    guard let collectionView = gesture.view as? UICollectionView else { return }
    let location = gesture.location(in: collectionView)
    if let indexPath = collectionView.indexPathForItem(at: location) {
      let websiteURL = URL(string: images[indexPath.row].url)
      if let url = websiteURL {
        if UIApplication.shared.canOpenURL(url) {
          UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
          print("無法打開URL: \(url)")
        }
      }
    }
  }
}

extension BannerCell: UICollectionViewDataSource, UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    images.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BannerCollectionViewCell", for: indexPath)

    guard let bannerCollectionCell = cell as? BannerCollectionViewCell else { return cell }
    let image = UIImage(named: images[indexPath.row].image)
    bannerCollectionCell.bannerImageView.image = image
    return bannerCollectionCell
  }

  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    let visibleIndexPaths = collectionView.indexPathsForVisibleItems
    guard let firstVisibleIndexPath = visibleIndexPaths.first else { return }

    let lastIndex = collectionView.numberOfItems(inSection: 0) - 1
    if firstVisibleIndexPath.item == lastIndex && scrollView.contentOffset.x > 0 {
      collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .centeredHorizontally, animated: false)
    }
  }

  func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    let visibleIndexPaths = collectionView.indexPathsForVisibleItems
    if let currentIndexPath = visibleIndexPaths.first {
      pageControl.currentPage = currentIndexPath.item == 4 ? 0 : currentIndexPath.item
    }
  }
}
