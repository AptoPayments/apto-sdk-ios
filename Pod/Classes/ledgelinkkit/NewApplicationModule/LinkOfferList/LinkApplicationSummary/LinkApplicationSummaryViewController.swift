//
//  ApplicationSummaryViewController.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 23/08/16.
//
//

import UIKit

class LinkApplicationSummaryViewController: ShiftViewController, LinkApplicationSummaryViewProtocol {

  var presenter: LinkApplicationSummaryPresenterProtocol! {
    didSet {
      guard let presenter = self.presenter else {
        return
      }
      let _ = presenter.viewModel.rows.observeNext { [weak self] formRows in
        guard let rows = formRows else {
          self?.formView.show(rows: [])
          return
        }
        self?.formView.show(rows: rows)
      }
    }
  }
  fileprivate let formView = MultiStepForm()

  override func viewDidLoad() {

    self.title = "application-summary.title".podLocalized()
    self.view.backgroundColor = self.uiConfiguration.uiBackgroundPrimaryColor
    self.edgesForExtendedLayout = UIRectEdge()

    self.showNavPreviousButton(uiConfiguration.iconTertiaryColor)

    self.setupTopView()
    self.setupNavigationView()

    formView.delegate = self
    self.view.addSubview(self.formView)
    self.formView.snp.makeConstraints { make in
      make.left.top.right.equalTo(self.view)
      make.bottom.equalTo(navigationView.snp.top)
    }

    self.presenter.viewLoaded()

  }

  // MARK: - ApplicationSummaryViewProtocol

  let topView = UIView()

  func set(lenderIconUrl:URL?, lenderName:String) {
    guard let url = lenderIconUrl else {
      lenderNameLabel.text = lenderName
      lenderNameLabel.isHidden = false
      lenderIcon.isHidden = true
      return
    }
    topDetailLabel.text = "application-summary.loans-provided-by".podLocalized().replace(["(%lenderName%)":lenderName])
    lenderIcon.setImageUrl(url) { [weak self] result in
      switch result {
      case .failure:
          self?.lenderNameLabel.text = lenderName
          self?.lenderNameLabel.isHidden = false
          self?.lenderIcon.isHidden = true
      case .success:
        self?.lenderNameLabel.isHidden = true
        self?.lenderIcon.isHidden = false
      }
    }
  }

  func agreeTapped() {
    presenter.agreeTermsTapped()
  }

  func scrollDownTapped() {
    let bottomOffset = CGPoint(x: 0, y: formView.contentSize.height - formView.bounds.size.height);
    formView.setContentOffset(bottomOffset, animated: true)
  }

  override func previousTapped() {
    presenter.previousTapped()
  }

  // MARK: Private

  fileprivate let lenderNameLabel = UILabel()
  fileprivate let lenderIcon = UIImageView()
  fileprivate let navigationView = UIView()
  fileprivate let topDetailLabel = UILabel()
  fileprivate var scrollDownButton: UIButton!
  fileprivate var agreeButton: UIButton!
  fileprivate var scrollViewIsAtBottom = false

  fileprivate func setupTopView() {

    topView.backgroundColor = UIColor.white

    lenderNameLabel.isHidden = true
    lenderNameLabel.font = UIFont(name: "HelveticaNeue-Light", size: 24)!
    lenderNameLabel.backgroundColor = UIColor.white
    topView.addSubview(lenderNameLabel)
    lenderNameLabel.snp.makeConstraints { make in
      make.left.equalTo(topView)
      make.top.bottom.equalTo(topView).inset(15)
      make.height.equalTo(60)
    }

    lenderIcon.isHidden = true
    lenderIcon.contentMode = .scaleAspectFit
    topView.addSubview(lenderIcon)
    lenderIcon.snp.makeConstraints { make in
      make.left.equalTo(topView)
      make.top.bottom.equalTo(topView).inset(15)
      make.height.equalTo(60)
      make.width.equalTo(120)
    }

    topView.addSubview(topDetailLabel)
    topDetailLabel.numberOfLines = 0
    topDetailLabel.font = uiConfiguration.fonth6
    topDetailLabel.textColor = uiConfiguration.noteTextColor
    topDetailLabel.textAlignment = .center
    topDetailLabel.snp.makeConstraints { make in
      make.centerY.equalTo(topView)
      make.right.equalTo(topView)
      make.left.equalTo(lenderIcon.snp.right).offset(20)
    }

  }

  fileprivate func setupNavigationView() {

    self.view.addSubview(navigationView)
    navigationView.snp.makeConstraints { make in
      make.height.equalTo(44)
      make.left.right.bottom.equalTo(self.view)
    }
    let topBorderView = UIView()
    topBorderView.backgroundColor = uiConfiguration.applicationListNavigationBorderColor
    navigationView.addSubview(topBorderView)
    topBorderView.snp.makeConstraints { make in
      make.height.equalTo(1 / UIScreen.main.scale)
      make.left.right.top.equalTo(navigationView)
    }

    scrollDownButton = UIButton.roundedButtonWith("application-summary.button.scroll-down-to-confirm".podLocalized(), backgroundColor: UIColor.white, accessibilityLabel: "Scroll Down Button", tapHandler: { [weak self] in
      self?.scrollDownTapped()
      })
    scrollDownButton.layer.borderWidth = 1 / UIScreen.main.scale
    scrollDownButton.layer.borderColor = uiConfiguration.tintColor.cgColor
    scrollDownButton.setTitleColor(uiConfiguration.tintColor, for: UIControlState())
    scrollDownButton.alpha = 1

    navigationView.addSubview(scrollDownButton)
    scrollDownButton.snp.makeConstraints { make in
      make.top.left.right.bottom.equalTo(navigationView).inset(5)
    }

    agreeButton = UIButton.roundedButtonWith("application-summary.button.i-agree".podLocalized(), backgroundColor: uiConfiguration.tintColor, accessibilityLabel: "Agree Button", tapHandler: { [weak self] in
      self?.agreeTapped()
      })

    navigationView.addSubview(agreeButton)
    agreeButton.snp.makeConstraints { make in
      make.top.left.right.bottom.equalTo(navigationView).inset(5)
    }
    agreeButton.alpha = 0

  }

}

extension LinkApplicationSummaryViewController: UIScrollViewDelegate {

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let remainingHeight = (scrollView.contentSize.height - scrollView.frame.size.height) - scrollView.contentOffset.y
    if remainingHeight <= 10 && scrollViewIsAtBottom == false {
      scrollViewIsAtBottom = true
      self.showConfirmLoanButton()
    }
    else if remainingHeight > 10 && scrollViewIsAtBottom {
      scrollViewIsAtBottom = false
      self.showScrollDownButton()
    }
  }

  func showConfirmLoanButton() {
    UIView.animate(withDuration: 0.25, animations: {
      self.agreeButton.alpha = 1
      self.scrollDownButton.alpha = 0
    })
  }

  func showScrollDownButton() {
    UIView.animate(withDuration: 0.25, animations: {
      self.agreeButton.alpha = 0
      self.scrollDownButton.alpha = 1
    })
  }

}
