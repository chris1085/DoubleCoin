//
//  ProfileVC.swift
//  DoubleCoin
//
//  Created by 姜權芳 on 2023/7/7.
//

import UIKit

class ProfileVC: UIViewController {
  @IBOutlet var usernameLabel: UILabel! {
    didSet {
      usernameLabel.text = "使用者"
    }
  }

  @IBOutlet var uidLabel: UILabel!
  @IBOutlet var idCheckView: UIView! {
    didSet {
      idCheckView.layer.cornerRadius = 8
      idCheckView.layer.shadowColor = UIColor.black.cgColor
      idCheckView.layer.shadowOffset = CGSize(width: 0, height: 1.0)
      idCheckView.layer.shadowOpacity = 0.15
      idCheckView.layer.shadowRadius = 4.0
    }
  }

  @IBOutlet var idCheckLabel: UILabel! {
    didSet {
      idCheckLabel.textColor = UIColor.black
    }
  }

  @IBOutlet var listView: UIView! {
    didSet {
      listView.backgroundColor = AppColor.secondary
    }
  }

  @IBOutlet var logoutView: UIView! {
    didSet {
      logoutView.backgroundColor = AppColor.secondary
    }
  }

  private var profile = Profile(id: "", userId: "", name: "default", active: true, isDefault: true, createdAt: "")
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = AppColor.secondary
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    setNavigationBar(true)

    HUDManager.shared.showHUD(in: view, text: "Loading")

    let defaults = UserDefaults.standard
    if let userName = defaults.string(forKey: "UserName"),
       let id = defaults.string(forKey: "UserID")
    {
      let active = defaults.bool(forKey: "Active")
      usernameLabel.text = userName
      uidLabel.text = "UID: \(id)"
      idCheckLabel.textColor = active == true ? AppColor.checkOk : AppColor.checkDisabled
      idCheckLabel.text = active == true ? "身份驗證成功" : "尚未身份驗證"
      HUDManager.shared.dismissHUD()
    } else {
      ApiManager.shared.getUserProfile { profile in
        guard let profile = profile else {
          HUDManager.shared.dismissHUD()
          return
        }
        self.profile = profile

        defaults.set(profile.name, forKey: "UserName")
        defaults.set(profile.userId, forKey: "UserID")
        defaults.set(profile.active, forKey: "Active")

        print(profile)

        DispatchQueue.main.async {
          self.usernameLabel.text = profile.name
          self.uidLabel.text = "UID: \(profile.userId)"
          self.idCheckLabel.textColor = profile.active == true ? AppColor.checkOk : AppColor.checkDisabled
          self.idCheckLabel.text = profile.active == true ? "身份驗證成功" : "尚未身份驗證"
          HUDManager.shared.dismissHUD()
        }
      }
    }
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    setNavigationBar(false)
  }

  private func setNavigationBar(_ isNeededRest: Bool) {
    let navigationBarAppearance = UINavigationBarAppearance()

    if isNeededRest {
      navigationBarAppearance.configureWithOpaqueBackground()
      navigationBarAppearance.backgroundColor = AppColor.primary
      navigationBarAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
      navigationController?.navigationBar.tintColor = UIColor.white
      navigationItem.title = "我的"
    } else {
      navigationBarAppearance.configureWithTransparentBackground()
      navigationController?.navigationBar.tintColor = nil
    }

    navigationController?.navigationBar.standardAppearance = navigationBarAppearance
    navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
    navigationController?.navigationBar.tintColor = UIColor.white
  }
}
