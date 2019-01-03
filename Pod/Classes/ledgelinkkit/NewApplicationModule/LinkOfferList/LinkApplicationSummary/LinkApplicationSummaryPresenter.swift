//
//  ApplicationSummaryPresenter.swift
//  Pods
//
//  Created by Ivan Oliver Martínez on 23/08/16.
//
//

import Bond

protocol LinkApplicationSummaryRouterProtocol: URLHandlerProtocol {
  func backFromAppSummary(_ animated: Bool)
  func appSummaryAgreed(offer:LoanOffer)
}

protocol LinkApplicationSummaryInteractorProtocol {
  func loadData()
  func finalizeApplication()
}

protocol LinkApplicationSummaryViewProtocol: ViewControllerProtocol {
  func set(lenderIconUrl:URL?, lenderName:String)
  var topView: UIView { get }
}

protocol LinkApplicationSummaryPresenterProtocol {
  var viewModel: LinkApplicationSummaryViewModel { get }
  func viewLoaded()
  func previousTapped()
  func agreeTermsTapped()
}

class LinkApplicationSummaryViewModel {
  let rows: Observable<[FormRowView]?> = Observable(nil)
}

class LinkApplicationSummaryPresenter: LinkApplicationSummaryDataReceiver, LinkApplicationSummaryPresenterProtocol {

  var interactor: LinkApplicationSummaryInteractorProtocol!
  var router: LinkApplicationSummaryRouterProtocol!
  let viewModel = LinkApplicationSummaryViewModel()
  var view: LinkApplicationSummaryViewProtocol!
  let uiConfig: ShiftUIConfig
  let config: LinkConfiguration
  fileprivate var linkHandler: LinkHandler?

  init(config: LinkConfiguration, uiConfig: ShiftUIConfig) {
    self.config = config
    self.uiConfig = uiConfig
  }

  func viewLoaded() {
    interactor.loadData()
  }

  func addNewData(_ linkSession: LinkSession,
                  userData: DataPointList,
                  loanData: AppLoanData,
                  offer: LoanOffer) {
    view.set(lenderIconUrl: offer.lender.bigIconUrl, lenderName: offer.lender.name)
    setupDefaultRows(viewModel: viewModel,
                     uiConfig: uiConfig ,
                     linkSession: linkSession,
                     userData: userData,
                     loanData: loanData,
                     offer: offer)
  }

  func previousTapped() {
    router.backFromAppSummary(true)
  }

  func agreeTermsTapped() {
    interactor.finalizeApplication()
  }

  func continueApplicationWith(_ offer:LoanOffer) {
    router.appSummaryAgreed(offer:offer)
  }

  // MARK: - Private methods

  func setupDefaultRows(viewModel: LinkApplicationSummaryViewModel,
                        uiConfig: ShiftUIConfig,
                        linkSession: LinkSession,
                        userData: DataPointList,
                        loanData: AppLoanData,
                        offer: LoanOffer) {
    let offerDetailsForm = OfferDetailsForm(offer: offer, uiConfig: uiConfig)
    let applicationDetailsForm = ApplicationDetailsForm(linkSession: linkSession,
                                                        userData: userData,
                                                        loanData: loanData,
                                                        uiConfig: uiConfig)

    var rows: [FormRowView] = []

    let topViewCustomRow = FormRowCustomView(view: view.topView)
    topViewCustomRow.backgroundColor = UIColor.white
    rows.append(topViewCustomRow)

    rows.append(FormBuilder.topSeparatorRow())
    rows.append(FormBuilder.sectionTitleRowWith(text: "application-summary.section.loan-terms".podLocalized(),
                                                uiConfig: uiConfig))
    rows.append(FormBuilder.bottomSeparatorRow())
    rows.append(contentsOf: offerDetailsForm.setupRows())
    rows.append(FormBuilder.topSeparatorRow())
    rows.append(FormBuilder.sectionTitleRowWith(text: "application-summary.section.application-info".podLocalized(),
                                                uiConfig: uiConfig))
    rows.append(FormBuilder.bottomSeparatorRow())
    rows.append(contentsOf: applicationDetailsForm.setupRows())
    rows.append(FormBuilder.topSeparatorRow())

    let loanProduct = self.config.loanProducts.filter { $0.loanProductId == offer.loanProductId }.first

    if loanProduct != nil {

      let richText = loanProduct?.applicationDisclaimer?.attributedString(font: uiConfig.fonth6,
                                                                          color: uiConfig.noteTextColor,
                                                                          linkColor: uiConfig.tintColor)

      if let richText = richText {
        linkHandler = LinkHandler(urlHandler:router)
        rows.append(FormBuilder.sectionTitleRowWith(text: "application-summary.section.disclosures".podLocalized(),
                                                    uiConfig: uiConfig))
        rows.append(FormBuilder.bottomSeparatorRow())
        let disclosureLabel = FormBuilder.richTextNoteRowWith(text: richText,
                                                              textAlignment: .justified,
                                                              position: .top,
                                                              multiline: true,
                                                              uiConfig: uiConfig,
                                                              linkHandler: linkHandler)
        rows.append(disclosureLabel)
      }

    }

    viewModel.rows.next(rows)
  }

  func lenderNameLabel (_ uiConfig: ShiftUIConfig, label: String) -> UILabel {
    let retVal = UILabel()
    retVal.text = label
    retVal.font = uiConfig.fonth1
    retVal.textColor = uiConfig.defaultTextColor
    retVal.textAlignment = .center
    return retVal
  }

}
