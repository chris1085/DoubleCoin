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
//      tableView.clipsToBounds = true
      tableView.sectionHeaderTopPadding = 0
      tableView.registerCellWithNib(identifier: "BannerCell", bundle: nil)
      tableView.registerCellWithNib(identifier: "CoinContentCell", bundle: nil)
      tableView.registerCellWithNib(identifier: "TradeRecordCell", bundle: nil)
      tableView.contentInsetAdjustmentBehavior = .never
      tableView.addRefreshHeader(refreshingBlock: { [weak self] in
        self?.headerLoader()
      })
    }
  }

  @IBOutlet var headerView: UIView!
  var amountsText: String? = ""
  var coinArray: [String] = []
  var productTableStats: [ProductTableStat] = []
  let dispatchGroup = DispatchGroup()
  var semaphore = DispatchSemaphore(value: 0)

  override func viewDidLoad() {
    super.viewDidLoad()
//    ApiManager.shared.creatOrder(size: "0.00454352", side: "buy", productId: "BTC-USD") { _ in
//    }

//    ApiManager.shared.getSingleOrder(orderId: "724a23c9-acca-44a7-a0a9-d9fbf4f266dc") { _ in
//    }

//    ApiManager.shared.getExchangeDollars(dollars: "USD", dateTime: "2023-07-06T11:32:16.973454Z", completion: { _ in
//    })
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    getData()
  }

  private func getData() {
    coinArray = []
    productTableStats = []

    ApiManager.shared.getAccounts { [weak self] accounts in
      if let usdAccount = accounts.filter({ $0.currency == "USD" }).first {
        guard let usdBalance = Double(usdAccount.balance) else { return }
        self?.amountsText = usdBalance.formatNumber(usdBalance, max: 6, min: 0, isAddSep: true)
        print("USD Balance: \(usdBalance)")
        DispatchQueue.main.async {
          self?.tableView.reloadData()
        }
      } else {
        print("No USD account found")
      }
    }

    ApiManager.shared.getProducts { [weak self] coins in
      self?.coinArray = coins
      guard let coinArray = self?.coinArray else { return }

      for coinName in coinArray {
        self?.dispatchGroup.enter()
        ApiManager.shared.getProductsStats(productId: coinName) { [weak self] coinStat in
          guard let coinStat = coinStat else { return }
          self?.productTableStats.append(ProductTableStat(name: coinName, productStat: coinStat))
          self?.dispatchGroup.leave()
        }
      }

      self?.dispatchGroup.notify(queue: .main) {
        DispatchQueue.main.async {
          guard let productTableStats = self?.productTableStats else { return }
          let sortedData = productTableStats.sorted(by: { $0.name < $1.name })
          self?.productTableStats = sortedData
//          print(self?.productTableStats)
          self?.tableView.reloadData()
        }
      }
    }
  }

  private func headerLoader() {
    tableView.endHeaderRefreshing()
  }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
  func numberOfSections(in tableView: UITableView) -> Int {
    2
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
      return 1
    } else {
      return productTableStats.count
    }
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
      let cell = tableView.dequeueReusableCell(withIdentifier: "CoinContentCell", for: indexPath)
      guard let contentCell = cell as? CoinContentCell else { return cell }
      contentCell.selectionStyle = .none
      contentCell.configureContentCell(data: productTableStats[indexPath.row])
      return contentCell
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

  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return CGFloat.leastNormalMagnitude
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if indexPath.section == 1 {
      guard let coinDetailVC = storyboard?.instantiateViewController(withIdentifier: "CoinDetailVC")
        as? CoinDetailVC else { return }
      coinDetailVC.productID = productTableStats[indexPath.row].name

      guard let productInfo = ProductInfo.fromTableStatName(productTableStats[indexPath.row].name) else {
        navigationController?.pushViewController(coinDetailVC, animated: true)
        return
      }
      coinDetailVC.navTitle = "\(productInfo.chtName)(\(productInfo.name))"
      navigationController?.pushViewController(coinDetailVC, animated: true)
    }
  }

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let yOffset = scrollView.contentOffset.y

    if yOffset > 20 {
      let navigationBarAppearance = UINavigationBarAppearance()
      navigationBarAppearance.configureWithOpaqueBackground()
      navigationBarAppearance.backgroundColor = AppColor.primary
      navigationController?.navigationBar.standardAppearance = navigationBarAppearance
      navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
    } else {
      let navigationBarAppearance = UINavigationBarAppearance()
      navigationBarAppearance.configureWithTransparentBackground()
      navigationController?.navigationBar.standardAppearance = navigationBarAppearance
      navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
    }
  }
}
