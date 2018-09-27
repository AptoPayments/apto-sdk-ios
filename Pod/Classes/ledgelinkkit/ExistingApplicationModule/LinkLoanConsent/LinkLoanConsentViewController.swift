//
//  LoanConsentViewController.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 04/04/16.
//
//

import Bond

protocol LinkLoanConsentEventHandlerProtocol {
  var viewModel: LinkLoanConsentViewModel { get }
  func viewLoaded()
  func previousTapped()
  func agreeTermsTapped()
}

class LinkLoanConsentViewController: ShiftViewController, LinkLoanConsentViewControllerProtocol {

  var eventHandler: LinkLoanConsentEventHandlerProtocol! {
    didSet {
      guard let presenter = self.eventHandler else {
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
  fileprivate let formView: MultiStepForm

  init(uiConfig: ShiftUIConfig) {
    self.formView = MultiStepForm()
    super.init(uiConfiguration: uiConfig)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.setupUI()
    self.eventHandler.viewLoaded()
  }

  // MARK: - Private methods

  fileprivate let navigationView = UIView()
  fileprivate var scrollDownButton: UIButton!
  fileprivate var agreeButton: UIButton!
  fileprivate var scrollViewIsAtBottom = false

  fileprivate func setupUI() {

    self.view.backgroundColor = uiConfiguration.backgroundColor
    self.navigationController?.navigationBar.backgroundColor = uiConfiguration.uiPrimaryColor
    self.title = "loan-consent.title".podLocalized()
    self.edgesForExtendedLayout = UIRectEdge()
    self.showNavPreviousButton(uiConfiguration.iconTertiaryColor)

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

    scrollDownButton = UIButton.roundedButtonWith("loan-consent.button.scroll-down-to-confirm".podLocalized(), backgroundColor: UIColor.white, tapHandler: { [weak self] in
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

    agreeButton = UIButton.roundedButtonWith("loan-consent.button.agree-and-fund-loan".podLocalized(), backgroundColor: uiConfiguration.tintColor, tapHandler: { [weak self] in
      self?.agreeTapped()
      })

    navigationView.addSubview(agreeButton)
    agreeButton.snp.makeConstraints { make in
      make.top.left.right.bottom.equalTo(navigationView).inset(5)
    }
    agreeButton.alpha = 0

    self.view.addSubview(self.formView)
    self.formView.snp.makeConstraints { make in
      make.top.left.right.equalTo(self.view)
      make.bottom.equalTo(navigationView.snp.top)
    }

    formView.delegate = self

  }

  func agreeTapped() {
    eventHandler.agreeTermsTapped()
  }

  func scrollDownTapped() {
    let bottomOffset = CGPoint(x: 0, y: formView.contentSize.height - formView.bounds.size.height);
    formView.setContentOffset(bottomOffset, animated: true)
  }

  override func previousTapped() {
    eventHandler.previousTapped()
  }

}

extension LinkLoanConsentViewController: UIScrollViewDelegate {

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
