//
//  AccountVC.swift
//  DoubleCoin
//
//  Created by 姜權芳 on 2023/7/6.
//

import UIKit

class AccountVC: UIViewController {
  @IBOutlet var headerView: UIView! {
    didSet {
      headerView.backgroundColor = AppColor.primary
    }
  }

  @IBAction func showHistoryPage(_ sender: Any) {
    print("tapped")
  }

  @IBAction func toggleEyeBtn(_ sender: UIButton) {
    isEyeBtnHidden = !isEyeBtnHidden

    if isEyeBtnHidden {
      sender.setBackgroundImage(UIImage(systemName: "eye.slash"), for: .normal)
      tempNumberLabel = amountsLabel.text!
      amountsLabel.text = "✲✲✲✲✲✲"

    } else {
      sender.setBackgroundImage(UIImage(systemName: "eye"), for: .normal)
      amountsLabel.text = tempNumberLabel
    }
  }

  @IBOutlet var eyeBtn: UIButton! {
    didSet {
      eyeBtn.tintColor = UIColor.darkGray
    }
  }

  @IBOutlet var amountsLabel: UILabel!
  @IBOutlet var tableView: UITableView! {
    didSet {
      tableView.dataSource = self
      tableView.delegate = self
      tableView.sectionHeaderTopPadding = 0
      tableView.registerCellWithNib(identifier: "AccountTableCell", bundle: nil)
    }
  }

  @IBOutlet var tableHeaderView: UIView!

  private var isEyeBtnHidden = false
  private var tempNumberLabel = ""
  private var accounts: [AccountNT] = []
  private var totalAmount: Double = 0.0
  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.navigationBar.isHidden = true
    getData()
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.navigationBar.isHidden = false
  }

  private func getData() {
    let dispatchGroup = DispatchGroup()
    ApiManager.shared.getAccounts { [weak self] accounts in
      for account in accounts {
        let timestamp = String(Date().timeIntervalSince1970)
        dispatchGroup.enter()
        ApiManager.shared.getExchangeDollars(
          dollars: account.currency, dateTime: timestamp, completion: { exchangeRates in
            let accountBalance = Double(account.balance)!

            guard let exchangeRate = exchangeRates?.data.rates["USD"],
                  let rate = Double(exchangeRate)
            else { dispatchGroup.leave()
              return
            }

            let amounts = accountBalance * rate
            let currencyAccount = AccountNT(twd: String(amounts), currency: account.currency, balance: account.balance)
            self?.accounts.append(currencyAccount)
            self?.totalAmount += amounts
            dispatchGroup.leave()
          })
      }

      dispatchGroup.notify(queue: .main) {
        guard let totalAmount = self?.totalAmount else { return }
        DispatchQueue.main.async {
          self?.amountsLabel.text = totalAmount.formatNumber(totalAmount, max: 0, min: 0, isAddSep: true)
          self?.tempNumberLabel = (self?.amountsLabel.text)!
          self?.tableView.reloadData()
        }
      }
    }
  }
}

extension AccountVC: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    accounts.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "AccountTableCell", for: indexPath)
    guard let productCell = cell as? AccountTableCell else { return cell }
    let index = indexPath.row
    productCell.configureCell(data: accounts[index])
    return productCell
  }

  func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    return tableHeaderView
  }

  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 48
  }
}
