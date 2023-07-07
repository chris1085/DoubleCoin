//
//  DollarsSheetVC.swift
//  DoubleCoin
//
//  Created by 姜權芳 on 2023/7/7.
//

import UIKit

protocol DollarsSheetVCDelegate: AnyObject {
  func didSelectDollar(dollarName: String)
}

class DollarsSheetVC: UIViewController {
  weak var delegate: DollarsSheetVCDelegate?
  @IBOutlet var tableView: UITableView! {
    didSet {
      tableView.dataSource = self
      tableView.delegate = self
      tableView.sectionHeaderTopPadding = 0
      tableView.registerCellWithNib(identifier: "DollarsSheetCell", bundle: nil)
    }
  }

  @IBOutlet var dismissBtn: UIButton!

  @IBAction func tappedDismissBtn(_ sender: Any) {
    dismiss(animated: true)
  }

  var dollarsNames: [String] = []
  var selectedDollars = "所有幣種"

  override func viewDidLoad() {
    super.viewDidLoad()
    print(dollarsNames)
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    tableView.reloadData()
  }
}

extension DollarsSheetVC: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    dollarsNames.count
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "DollarsSheetCell", for: indexPath)
    guard let dollarsSheetCell = cell as? DollarsSheetCell else { return cell }
    dollarsSheetCell.configureCell(name: dollarsNames[indexPath.row], selectedDollars: selectedDollars)
    dollarsSheetCell.selectionStyle = .none

    return dollarsSheetCell
  }

  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return view.bounds.height * 0.12
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    delegate?.didSelectDollar(dollarName: dollarsNames[indexPath.row])
    dismiss(animated: true)
  }
}
