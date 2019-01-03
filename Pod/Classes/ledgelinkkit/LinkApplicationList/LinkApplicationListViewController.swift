//
//  ApplicationListViewController.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 04/03/16.
//
//

import Foundation

protocol LinkApplicationListEventHandler {
  func viewLoaded()
  func backTapped()
  func closeTapped()
  func applicationSelectedWith(index:Int)
  func newApplicationTapped()
}

class LinkApplicationListViewController : CarouselViewcontroller, LinkApplicationListViewProtocol {

  let eventHandler: LinkApplicationListEventHandler
  fileprivate let formView: MultiStepForm
  fileprivate var label: FormRowLabelView?

  init(uiConfiguration: ShiftUIConfig, eventHandler: LinkApplicationListEventHandler) {
    self.eventHandler = eventHandler
    self.formView = MultiStepForm()
    super.init(uiConfiguration: uiConfiguration)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    self.title = "link-application-list.title".podLocalized()
    self.view.backgroundColor = self.uiConfiguration.uiBackgroundPrimaryColor
    self.navigationController?.navigationBar.backgroundColor = self.uiConfiguration.uiPrimaryColor
    self.edgesForExtendedLayout = .top
    self.extendedLayoutIncludesOpaqueBars = true
    self.view.addSubview(self.formView)
    self.formView.snp.makeConstraints { make in
      make.top.left.right.bottom.equalTo(self.view)
    }
    self.formView.backgroundColor = UIColor.clear
    self.label = self.subtitleRowWith(text: "", height: 88)
    self.eventHandler.viewLoaded()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func set(subtitle:String) {
    guard let label = label else {
      return
    }
    label.label.text = subtitle
  }

  func showNewContents(_ newContents:[LoanApplicationSummary]) {
    let labels = newContents.map { application -> String in
      return application.quickDescription()
    }
    DispatchQueue.main.async {
      self.formView.show(rows: self.setupRows(labels))
    }

  }

  func setupRows(_ labels:[String]) -> [FormRowView] {
    var values: [Int] = []
    if labels.count > 0 {
      values = Array(0...labels.count - 1)
    }
    let applicationSelector = FormBuilder.radioRowWith(labels: labels, values:values, leftIcons:[], uiConfig: uiConfiguration)
    let newApplicationButton = FormBuilder.buttonRowWith(title: "link-application-list.button.new-application".podLocalized(), tapHandler: { [weak self] in
      self?.eventHandler.newApplicationTapped()
      }, uiConfig: uiConfiguration)
    let _ = applicationSelector.bndValue.observeNext { [weak self] selectedIdx in
      guard let applicationIndex = selectedIdx else {
        return
      }
      self?.eventHandler.applicationSelectedWith(index: applicationIndex)
    }
    guard let label = label else {
      return [applicationSelector, newApplicationButton]
    }
    return [label, applicationSelector, newApplicationButton]
  }

  func subtitleRowWith(text:String, height:CGFloat = 44) -> FormRowLabelView {
    let label = FormRowLabelView(label: UILabel(), showSplitter: false, height: height)
    label.label.text = text
    label.label.textColor = uiConfiguration.formSubtitleColor
    label.label.font = uiConfiguration.fonth4
    label.label.textAlignment = .center
    label.backgroundColor = uiConfiguration.formSubtitleBackgroundColor
    label.label.backgroundColor = uiConfiguration.formSubtitleBackgroundColor
    label.label.numberOfLines = 0
    return label
  }

  override func previousTapped() {
    eventHandler.backTapped()
  }

  override func closeTapped() {
    eventHandler.closeTapped()
  }
}
