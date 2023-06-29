//
//  ViewController.swift
//  DoubleCoin
//
//  Created by 姜權芳 on 2023/6/28.
//

import UIKit

class ViewController: UIViewController {
  @IBOutlet var tableView: UITableView! {
    didSet {
      tableView.dataSource = self
      tableView.delegate = self
      tableView.clipsToBounds = true
      tableView.sectionHeaderTopPadding = 0
      tableView.registerCellWithNib(identifier: "BannerCell", bundle: nil)
    }
  }

  @IBOutlet var headerView: UIView!
  var amountsText: String? = ""
  var coinArray: [String] = []
  var productStats: [ProductStat] = []
  let dispatchGroup = DispatchGroup()
  override func viewDidLoad() {
    super.viewDidLoad()

//    ApiManager.shared.getUserProfile()
    dispatchGroup.enter()
    ApiManager.shared.getAccounts { [weak self] accounts in
      self?.dispatchGroup.leave()
      if let usdAccount = accounts.filter({ $0.currency == "USD" }).first {
        guard let usdBalance = Double(usdAccount.balance) else { return }
        self?.amountsText = usdBalance.formatNumber(usdBalance)
        print("USD Balance: \(usdBalance)")
        DispatchQueue.main.async {
          self?.tableView.reloadData()
        }
      } else {
        print("No USD account found")
      }
    }

    dispatchGroup.enter()
    ApiManager.shared.getProducts { [weak self] coins in
      self?.dispatchGroup.leave()
      self?.coinArray = coins
      guard let coinArray = self?.coinArray else { return }
    }
//
//    for coinId in coinArray {
//      dispatchGroup.enter()
//      ApiManager.shared.getProductsStats(productId: coinId) { [weak self] productStat in
//        defer {
//          self?.dispatchGroup.leave()
//        }
//
//        print(coinId)
//        guard let productStat = productStat else { return }
//        print(productStat)
//        self?.productStats.append(productStat)
//      }
//    }

    dispatchGroup.notify(queue: .main) {
      print("All requests completed")
    }

//    ApiManager.shared.getUserProfile()
//    ApiManager.shared.getAccounts
//    ApiManager.shared.getProducts()
//    ApiManager.shared.getCurrencies()
//    ApiManager.shared.getProductCandles()
//    ApiManager.shared.getProductsStats()
  }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
  func numberOfSections(in tableView: UITableView) -> Int {
    2
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    1
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.section == 0 {
      let cell = tableView.dequeueReusableCell(withIdentifier: "BannerCell", for: indexPath)
      guard let bannerCell = cell as? BannerCell else { return cell }
      bannerCell.selectionStyle = .none
      bannerCell.numberLabel.text = amountsText
      bannerCell.tempNumberLabel = amountsText!
      return bannerCell
    } else {
      return UITableViewCell()
    }
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    let section = indexPath.section
//    let row = indexPath.row

    if section == 0 {
      return view.bounds.height * 0.33
    } else {
      return UITableView.automaticDimension
    }
  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    if section == 1 {
      return headerView
    } else {
      return UIView()
    }
  }

  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    if section == 1 {
      return 90
    } else { return 0.1 }
  }
}
