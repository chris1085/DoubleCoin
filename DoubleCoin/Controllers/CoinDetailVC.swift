//
//  CoinDetailVC.swift
//  DoubleCoin
//
//  Created by 姜權芳 on 2023/6/30.
//

import UIKit

class CoinDetailVC: UIViewController {
  var coinbaseWebSocketClient: CoinbaseWebSocketClient?
  @IBOutlet var sellBtn: UIButton! {
    didSet {
      sellBtn.applyPrimaryStyle()
    }
  }

  @IBOutlet var buyBtn: UIButton! {
    didSet {
      buyBtn.applyPrimaryStyle()
    }
  }

  @IBAction func buyCoinTapped(_ sender: Any) {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    if let buySellVC = storyboard.instantiateViewController(withIdentifier: "BuySellVC") as? BuySellVC {
      coinbaseWebSocketClient?.socket.disconnect()
      let navController = UINavigationController(rootViewController: buySellVC)
      navController.modalPresentationStyle = .fullScreen
      buySellVC.side = "buy"
      buySellVC.productID = productID
      present(navController, animated: true)
    }
  }

  @IBAction func sellCoinTapped(_ sender: Any) {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    if let buySellVC = storyboard.instantiateViewController(withIdentifier: "BuySellVC") as? BuySellVC {
      let navController = UINavigationController(rootViewController: buySellVC)
      navController.modalPresentationStyle = .fullScreen
      buySellVC.side = "sell"
      buySellVC.productID = productID
      present(navController, animated: true)
    }
  }

  @IBOutlet var tableView: UITableView! {
    didSet {
      tableView.dataSource = self
      tableView.delegate = self
      tableView.registerCellWithNib(identifier: "LineChartMainCell", bundle: nil)
      tableView.registerCellWithNib(identifier: "BuySellPriceCell", bundle: nil)
      tableView.registerCellWithNib(identifier: "TradeRecordCell", bundle: nil)
      tableView.sectionHeaderTopPadding = 0
    }
  }

  var productID = ""
  var navTitle = ""
  var orders: [Order] = []
  var candlesTicks: [Candlestick] = []
  var timelineBtnTag = 0
  private var buyPrice = "-"
  private var sellPrice = "-"

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    coinbaseWebSocketClient = CoinbaseWebSocketClient(productID: productID)
    coinbaseWebSocketClient?.delegate = self
    setDefaultView()
    setNavigationBar(true)
    tabBarController?.tabBar.isHidden = true
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    coinbaseWebSocketClient?.socket.disconnect()
    setNavigationBar(false)
  }

  private func setDefaultView() {
    if let timelineType = TimelineType(rawValue: "1D") {
      let tickType = timelineType.tickType
      let calendar = Calendar.current
      let today = Date()
      let dateFormatter = DateFormatter()
      dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
      dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
      let oneDayAgo = calendar.date(byAdding: .day, value: -1, to: today)!
      let start = dateFormatter.string(from: oneDayAgo)
      let end = dateFormatter.string(from: today)
      HUDManager.shared.showHUD(in: view, text: "Loading")
      fetchCandlesTicks(from: start, to: end, granularity: tickType) { _ in
        ApiManager.shared.getOrders(productId: self.productID, limits: 5) { [weak self] orders in
          guard let orders = orders else {
            HUDManager.shared.dismissHUD()
            return
          }
          self?.orders = orders

          DispatchQueue.main.async {
            self?.tableView.reloadData()
          }
          HUDManager.shared.dismissHUD()
        }
      }
    }
  }

  private func setNavigationBar(_ isNeededRest: Bool) {
    let navigationBarAppearance = UINavigationBarAppearance()

    if isNeededRest {
      navigationBarAppearance.configureWithOpaqueBackground()
      navigationBarAppearance.backgroundColor = AppColor.primary
      navigationBarAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
      navigationController?.navigationBar.tintColor = UIColor.white
      navigationItem.title = navTitle
    } else {
      navigationBarAppearance.configureWithTransparentBackground()
      navigationController?.navigationBar.tintColor = nil
    }

    navigationController?.navigationBar.standardAppearance = navigationBarAppearance
    navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
    navigationController?.navigationBar.tintColor = UIColor.white
    let backBtn = UIBarButtonItem(image: UIImage(systemName: "chevron.left"),
                                  style: .plain,
                                  target: self,
                                  action: #selector(closeVC))
    navigationItem.leftBarButtonItem = backBtn
//    navigationController?.navigationBar.layoutIfNeeded()
  }

  @objc func closeVC() {
    navigationController?.popViewController(animated: true)
  }
}

extension CoinDetailVC: UITableViewDelegate, UITableViewDataSource {
  func numberOfSections(in tableView: UITableView) -> Int {
    2
  }

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 1 {
      return orders.count
    }
    return 1
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.section == 0 {
      let cell = tableView.dequeueReusableCell(withIdentifier: "LineChartMainCell", for: indexPath)
      guard let lineChartCell = cell as? LineChartMainCell else { return cell }
      lineChartCell.selectionStyle = .none
      lineChartCell.delegate = self
      lineChartCell.candlesTicks = candlesTicks
      lineChartCell.setTicksData()
      lineChartCell.selectDefaultButton(tag: timelineBtnTag)
      lineChartCell.buyPriceLabel.text = buyPrice
      lineChartCell.sellPriceLabel.text = sellPrice

      return lineChartCell
    } else {
      let cell = tableView.dequeueReusableCell(withIdentifier: "TradeRecordCell", for: indexPath)
      guard let tradeRecordCell = cell as? TradeRecordCell else { return cell }
      tradeRecordCell.selectionStyle = .none

      tradeRecordCell.configureCell(order: orders[indexPath.row])

      return tradeRecordCell
    }
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if indexPath.section == 0 {
      return UIScreen.main.bounds.height * 0.6
    }
    return UITableView.automaticDimension
  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    if section == 1 {
      let headerView = TradeRecordHeaderView()
      headerView.didTappedShowRecords = { [weak self] in
        guard let historyVC = self?.storyboard?.instantiateViewController(withIdentifier: "HistoryVC")
          as? HistoryVC else { return }

        historyVC.filterProdcutId = self?.productID ?? "BTC-USD"
        guard let productInfo = ProductInfo.fromTableStatName(self?.productID ?? "BTC-USD") else { return }
        historyVC.selectedDollars = productInfo.name
        self?.coinbaseWebSocketClient?.socket.disconnect()
        self?.navigationController?.pushViewController(historyVC, animated: true)
      }
      return headerView
    }

    return nil
  }

  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    if section == 1 {
      return 48
    }
    return CGFloat.leastNormalMagnitude
  }

  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return CGFloat.leastNormalMagnitude
  }
}

extension CoinDetailVC: WebSocketReceiveDelegate {
  func didReceiveTickerData(buyPrice: String, sellPrice: String) {
    guard let formattedBuyPrice = Double(buyPrice)?.formatNumber(Double(buyPrice)!, max: 6, min: 0, isAddSep: true),
          let formattedSellPrice = Double(sellPrice)?.formatNumber(Double(sellPrice)!, max: 6, min: 0, isAddSep: true)
    else {
      return
    }

    let visibleCells = tableView.visibleCells
    for cell in visibleCells {
      if let cellIdentifier = cell.reuseIdentifier,
         cellIdentifier == "LineChartMainCell",
         let mainCell = cell as? LineChartMainCell
      {
        mainCell.sellPriceLabel.text = formattedBuyPrice
        mainCell.buyPriceLabel.text = formattedSellPrice
        self.sellPrice = formattedBuyPrice
        self.buyPrice = formattedSellPrice
      }
    }
  }
}

extension CoinDetailVC: LineChartMainCellDelegate {
  func didTimeBtnTapped(timeline: String, tag: Int) {
    candlesTicks = []
    if let timelineType = TimelineType(rawValue: timeline) {
      timelineBtnTag = tag
      let tickType = timelineType.tickType
      var start = ""
      var end = ""
      let calendar = Calendar.current
      let today = Date()
      let dateFormatter = DateFormatter()
      dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

      switch timelineType {
      case .day, .week:
        var startDate: Date
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"

        if timelineType == .day {
          startDate = calendar.date(byAdding: .day, value: -1, to: today)!
        } else {
          startDate = calendar.date(byAdding: .day, value: -7, to: today)!
        }

        start = dateFormatter.string(from: startDate)
        end = dateFormatter.string(from: today)
        fetchCandlesTicks(from: start, to: end, granularity: tickType) { _ in }
      case .month, .season:
        var startDate: Date
        dateFormatter.dateFormat = "yyyy-MM-dd"

        if timelineType == .month {
          startDate = calendar.date(byAdding: .month, value: -1, to: today)!
        } else {
          startDate = calendar.date(byAdding: .month, value: -3, to: today)!
        }

        start = dateFormatter.string(from: startDate)
        end = dateFormatter.string(from: today)
        fetchCandlesTicks(from: start, to: end, granularity: tickType) { _ in }
      case .year:
        let lastYearDate = calendar.date(byAdding: .year, value: -1, to: today)!
        let components = calendar.dateComponents([.day], from: lastYearDate, to: today)
        let totalDays = components.day!
        var remainDays = totalDays
        var date = Date()
        var array: [Candlestick] = []
        var candlesTemp: [Candlestick] = []
        var index = 0
        let semaphore = DispatchSemaphore(value: 0)

        repeat {
          let start = remainDays >= 300
            ? calendar.date(byAdding: .day, value: -300, to: date)!
            : calendar.date(byAdding: .day, value: -remainDays, to: date)!
//          print("---------------------")
//          print("Start = \(start)")
//          print("End = \(date)")
          let startDate = DateUtils.string(from: start, format: "yyyy-MM-dd") ?? ""
          let endDate = DateUtils.string(from: date, format: "yyyy-MM-dd") ?? ""

          fetchCandlesTicks(from: startDate, to: endDate, granularity: tickType) { candles in
            candlesTemp = candles
            array += candlesTemp
            date = start - Double(tickType)!
            index += 1

            semaphore.signal()
            print("第\(index)趟完成")
          }
          semaphore.wait()
//          print("---------------------")
          remainDays -= 300
        } while remainDays > 0

        print(array.count)
      case .all:
        let calendar = Calendar.current
        var date = Date()

        var array: [Candlestick] = []
        var candlesTemp: [Candlestick] = []
        var index = 0

        let semaphore = DispatchSemaphore(value: 0)
        repeat {
          let threeHundredDaysAgo = calendar.date(byAdding: .day, value: -300, to: date)!
          let startDate = DateUtils.string(from: threeHundredDaysAgo, format: "yyyy-MM-dd") ?? ""
          let endDate = DateUtils.string(from: date, format: "yyyy-MM-dd") ?? ""

//          print("---------------------")
//          print("Start = \(threeHundredDaysAgo)")
//          print("End = \(date)")

          fetchCandlesTicks(from: startDate, to: endDate, granularity: tickType) { candles in
            candlesTemp = candles
            array += candlesTemp
            date = threeHundredDaysAgo
            index += 1

            semaphore.signal()
            print("第\(index)趟完成")
          }
          semaphore.wait()

          print(array.count)
          print(candlesTemp.count)
//          print("---------------------")
        } while candlesTemp.count != 0

        print(array.count)
      }
    } else {
      print("Invalid timeline")
    }
  }

  private func fetchCandlesTicks(from startDate: String, to endDate: String, granularity: String,
                                 completion: @escaping ([Candlestick]) -> Void)
  {
    HUDManager.shared.showHUD(in: view, text: "Loading")
    ApiManager.shared.getProductCandles(productId: productID, from: startDate, to: endDate,
                                        granularity: granularity)
    { [weak self] candlesTicks in
      guard let candlesTicks = candlesTicks else {
        HUDManager.shared.dismissHUD()
        return
      }
      self?.handleCandlesTicks(candlesTicks)
      DispatchQueue.main.async {
        HUDManager.shared.dismissHUD()
      }
      completion(candlesTicks)
    }
  }

  private func handleCandlesTicks(_ candlesTicks: [Candlestick]) {
    self.candlesTicks += candlesTicks
    let sortedData = self.candlesTicks.sorted(by: { $0.time < $1.time })
    self.candlesTicks = sortedData
    print(self.candlesTicks.count)

    DispatchQueue.main.async {
      let indexPath = IndexPath(row: 0, section: 0)
      self.tableView.reloadRows(at: [indexPath], with: .automatic)
    }
  }
}
