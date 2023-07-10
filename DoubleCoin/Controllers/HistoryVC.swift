//
//  HistoryVC.swift
//  DoubleCoin
//
//  Created by 姜權芳 on 2023/7/7.
//

import UIKit

class HistoryVC: UIViewController {
  @IBOutlet var tableView: UITableView! {
    didSet {
      tableView.dataSource = self
      tableView.delegate = self
      tableView.registerCellWithNib(identifier: "TradeRecordCell", bundle: nil)
      tableView.sectionHeaderTopPadding = 0
      tableView.addRefreshHeader(refreshingBlock: { [weak self] in
        self?.headerLoader()
      })
    }
  }

  @IBOutlet var switchingDollarsBtn: UIButton! {
    didSet {
      switchingDollarsBtn.setTitle("\(selectedDollars) ▼", for: .normal)
    }
  }

  @IBAction func switchDollars(_ sender: Any) {
    guard let dollarsSheetVC = storyboard?.instantiateViewController(withIdentifier: "DollarsSheetVC")
      as? DollarsSheetVC else { return }
    if let sheetPresentationController = dollarsSheetVC.sheetPresentationController {
      sheetPresentationController.detents = [.medium()]
      sheetPresentationController.preferredCornerRadius = 24
    }
    dollarsSheetVC.dollarsNames = dollarsNames
    dollarsSheetVC.dollarsNames.insert("所有幣種", at: 0)
    dollarsSheetVC.selectedDollars = selectedDollars
    dollarsSheetVC.delegate = self

    present(dollarsSheetVC, animated: true)
  }

  @IBOutlet var noRecordsView: UIView! {
    didSet {
      noRecordsView.isHidden = true
    }
  }

  @IBOutlet var historyHeaderView: HistoryHeaderView!
  private var allOrders: [Order] = []
  private var filteredOrders: [Order] = []
  var dollarsNames: [String] = []
  var selectedDollars = "所有幣種"
  var productID = ""
  var filterProdcutId = ""

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    getAccounts()
    getOrders {}

    setNavigationBar(true)
    tabBarController?.tabBar.isHidden = true
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    setNavigationBar(false)
  }

  private func getOrders(completion: @escaping () -> Void) {
    HUDManager.shared.showHUD(in: view, text: "Loading")
    ApiManager.shared.getOrders(productId: productID, limits: 100) { [weak self] orders in
      guard let orders = orders else {
        completion()
        HUDManager.shared.dismissHUD()
        return
      }

      self?.allOrders = orders
      self?.filteredOrders = self?.filterProdcutId == ""
        ? orders
        : orders.filter { $0.productID == self?.filterProdcutId }

      DispatchQueue.main.async {
        self?.noRecordsView.isHidden = self?.filteredOrders.count != 0 ? true : false
        self?.tableView.reloadData()
        HUDManager.shared.dismissHUD()
        completion()
      }
    }
  }

  private func getAccounts() {
    ApiManager.shared.getAccounts { [weak self] accounts in
      for account in accounts {
        self?.dollarsNames.append(account.currency)
      }
    }
  }

  private func setNavigationBar(_ isNeededRest: Bool) {
    navigationItem.title = "資產紀錄"
    navigationController?.navigationBar.tintColor = UIColor.black

    navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    navigationController?.navigationBar.shadowImage = UIImage()
//    navigationItem.backBarButtonItem = nil
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

  private func headerLoader() {
    getOrders {
      self.tableView.endHeaderRefreshing()
    }
  }
}

extension HistoryVC: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    filteredOrders.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "TradeRecordCell", for: indexPath)
    guard let tradeRecordCell = cell as? TradeRecordCell else { return cell }
    tradeRecordCell.selectionStyle = .none

    tradeRecordCell.configureCell(order: filteredOrders[indexPath.row])

    return tradeRecordCell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let orderId = filteredOrders[indexPath.row].id
    guard let tradeResultVC = storyboard?.instantiateViewController(withIdentifier: "TradeResultVC")
      as? TradeResultVC else { return }

    tradeResultVC.isButtonHidden = true
    tradeResultVC.orderId = orderId

    navigationController?.pushViewController(tradeResultVC, animated: true)
  }
}

extension HistoryVC: DollarsSheetVCDelegate {
  func didSelectDollar(dollarName: String) {
    if dollarName == "所有幣種" {
      filteredOrders = allOrders
    } else {
      filteredOrders = allOrders.filter { $0.productID == "\(dollarName)-USD" }
    }

    noRecordsView.isHidden = filteredOrders.count != 0 ? true : false

    selectedDollars = dollarName
    switchingDollarsBtn.setTitle("\(selectedDollars) ▼", for: .normal)
    tableView.reloadData()
  }
}
