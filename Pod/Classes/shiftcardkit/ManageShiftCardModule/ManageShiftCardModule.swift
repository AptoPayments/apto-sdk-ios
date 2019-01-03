//
//  ManageShiftCardModule.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 08/03/2018.
//

import UIKit
import MapKit

class ManageShiftCardModule: UIModule {
  private var card: Card
  private let mode: ShiftCardModuleMode
  private var shiftCardSettingsModule: ShiftCardSettingsModuleProtocol?
  private var accountSettingsModule: UIModuleProtocol?
  private var projectConfiguration: ProjectConfiguration! // swiftlint:disable:this implicitly_unwrapped_optional
  private var mailSender: MailSender?
  private var shiftCardConfiguration: ShiftCardConfiguration?
  private var presenter: ManageShiftCardPresenterProtocol?
  private var kycPresenter: KYCPresenterProtocol?
  private var transactionDetailsPresenter: ShiftCardTransactionDetailsPresenterProtocol?
  private var physicalCardActivationSucceedModule: PhysicalCardActivationSucceedModuleProtocol?
  private var physicalCardActivationModule: PhysicalCardActivationModuleProtocol?
  private var fundingSourceSelectorModule: FundingSourceSelectorModuleProtocol?

  public init(serviceLocator: ServiceLocatorProtocol, card: Card, mode: ShiftCardModuleMode) {
    self.card = card
    self.mode = mode
    super.init(serviceLocator: serviceLocator)
  }

  override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
    shiftSession.contextConfiguration { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .failure(let error):
        completion(.failure(error))
      case .success(let contextConfiguration):
        self.projectConfiguration = contextConfiguration.projectConfiguration
        self.shiftSession.shiftCardSession.shiftCardConfiguration { [weak self] result in
          guard let self = self else { return }
          switch result {
          case .failure(let error):
            completion(.failure(error))
          case .success(let shiftCardConfiguration):
            self.shiftCardConfiguration = shiftCardConfiguration
            // Refresh the card data
            self.shiftSession.getFinancialAccount(accountId: self.card.accountId,
                                                  forceRefresh: false,
                                                  retrieveBalances: false) { [weak self] result in
              guard let self = self else { return }
              switch result {
              case .failure(let error):
                completion(.failure(error))
              case .success(let financialAccount):
                guard let shiftCard = financialAccount as? Card else {
                  return
                }
                self.card = shiftCard
                if let kyc = self.card.kyc {
                  switch kyc {
                  case .passed:
                    self.showManageCard(addChild: true,
                                        shiftCardConfiguration: shiftCardConfiguration,
                                        completion: completion)
                  default:
                    self.showKYCViewController(addChild: true, card: self.card, completion: completion)
                  }
                }
                else {
                  self.showManageCard(addChild: true,
                                      shiftCardConfiguration: shiftCardConfiguration,
                                      completion: completion)
                }
              }
            }
          }
        }
      }
    }
  }

  // MARK: - Manage Card View Controller

  private func showManageCard(addChild: Bool,
                              shiftCardConfiguration: ShiftCardConfiguration,
                              completion: @escaping Result<UIViewController, NSError>.Callback) {
    if card.state == .created && card.orderedStatus == .ordered {
      showPhysicalCardActivationModule(addChild: addChild,
                                       shiftCardConfiguration: shiftCardConfiguration,
                                       completion: completion)
    }
    else {
      showManageCardViewController(addChild: addChild,
                                   shiftCardConfiguration: shiftCardConfiguration,
                                   completion: completion)
    }
  }

  private func showPhysicalCardActivationModule(addChild: Bool,
                                                shiftCardConfiguration: ShiftCardConfiguration,
                                                completion: @escaping Result<UIViewController, NSError>.Callback) {
    let module = serviceLocator.moduleLocator.physicalCardActivationModule(card: card)
    self.physicalCardActivationModule = module
    if addChild {
      module.onFinish = { [weak self] _ in
        self?.reloadCardAndShowManageCardIfPossible(shiftCardConfiguration: shiftCardConfiguration) {_ in }
      }
      self.addChild(module: module, completion: completion)
    }
    else {
      module.onFinish = { [weak self] _ in
        self?.reloadCardAndShowManageCardIfPossible(shiftCardConfiguration: shiftCardConfiguration) {_ in }
      }
      push(module: module, completion: completion)
    }
  }

  private func reloadCardAndShowManageCardIfPossible(shiftCardConfiguration: ShiftCardConfiguration,
                                                     completion: @escaping Result<UIViewController, NSError>.Callback) {
    showLoadingView()
    shiftSession.getFinancialAccount(accountId: self.card.accountId,
                                     forceRefresh: true,
                                     retrieveBalances: false) { [weak self] result in
      guard let self = self else { return }
      self.hideLoadingView()
      switch result {
      case .failure(let error):
        completion(.failure(error))
      case .success(let financialAccount):
        guard let shiftCard = financialAccount as? Card else {
          return
        }
        self.card = shiftCard
        if !(shiftCard.state == .created && shiftCard.orderedStatus == .ordered) {
          self.showManageCardViewController(addChild: false,
                                            shiftCardConfiguration: shiftCardConfiguration,
                                            completion: completion)
        }
        else {
          let userInfo = [
            NSLocalizedDescriptionKey: "manage_card.activate_physical_card.card_not_activated".podLocalized()
          ]
          let error = NSError(domain: "com.shiftpayments.error", code: 90000, userInfo: userInfo)
          self.show(error: error)
        }
      }
    }
  }

  fileprivate func showManageCardViewController(addChild: Bool = false,
                                                shiftCardConfiguration: ShiftCardConfiguration,
                                                completion: @escaping Result<UIViewController, NSError>.Callback) {
    // swiftlint:disable:next force_unwrapping
    let viewController = self.buildManageShiftCardViewController(uiConfig,
                                                                 shiftCardConfiguration: shiftCardConfiguration,
                                                                 card: card)
    if addChild {
      self.addChild(viewController: viewController, completion: completion)
    }
    else {
      self.push(viewController: viewController) {
        completion(.success(viewController))
      }
    }
  }

  fileprivate func buildManageShiftCardViewController(_ uiConfig: ShiftUIConfig,
                                                      shiftCardConfiguration: ShiftCardConfiguration,
                                                      card: Card) -> ManageShiftCardViewControllerProtocol {
    let showActivateCardButton = shiftCardConfiguration.isFeatureEnabled(.showActivateCardButton)
    let config = ManageShiftCardPresenterConfig(name: projectConfiguration.name,
                                                imageUrl: projectConfiguration.branding.logoUrl,
                                                showActivateCardButton: showActivateCardButton)
    let presenter = serviceLocator.presenterLocator.manageCardPresenter(config: config)
    let interactor = serviceLocator.interactorLocator.manageCardInteractor(card: card)
    let viewController = serviceLocator.viewLocator.manageCardView(mode: mode, presenter: presenter)
    presenter.router = self
    presenter.interactor = interactor
    presenter.view = viewController
    self.presenter = presenter
    return viewController
  }

  // MARK: - KYCView Controller

  fileprivate func showKYCViewController(addChild: Bool = false,
                                         card: Card,
                                         completion: @escaping Result<UIViewController, NSError>.Callback) {
    // swiftlint:disable:next force_unwrapping
    let viewController = self.buildKYCViewController(uiConfig, card: card)
    if addChild {
      let leftButtonMode: UIViewControllerLeftButtonMode = self.mode == .standalone ? .none : .close
      self.addChild(viewController: viewController, leftButtonMode: leftButtonMode, completion: completion)
    }
    else {
      self.push(viewController: viewController) {
        completion(.success(viewController))
      }
    }
  }

  fileprivate func buildKYCViewController(_ uiConfig: ShiftUIConfig, card: Card) -> KYCViewControllerProtocol {
    let presenter = serviceLocator.presenterLocator.kycPresenter()
    let interactor = serviceLocator.interactorLocator.kycInteractor(card: card)
    let viewController = serviceLocator.viewLocator.kycView(presenter: presenter)
    presenter.router = self
    presenter.interactor = interactor
    presenter.view = viewController
    self.kycPresenter = presenter
    return viewController
  }
}

extension ManageShiftCardModule: ManageShiftCardRouterProtocol {
  func update(card newCard: Card) {
    if newCard.state != .cancelled {
      self.card = newCard
    }
    else {
      // Card has been cancelled, look for other user cards that are not closed, if any. If there are no non-closed
      // cards, close the SDK
      self.showLoadingView()
      shiftSession.shiftCardSession.getCards(0, rows: 100) { [unowned self] result in
        self.hideLoadingView()
        switch result {
        case .failure(let error):
          // Close the SDK
          self.show(error: error)
          self.close()
        case .success(let cards):
          let nonClosedCards = cards.filter { $0.state != .cancelled }
          if let card = nonClosedCards.first, let shiftCardConfiguration = self.shiftCardConfiguration {
            self.card = card
            self.showManageCard(addChild: false,
                                shiftCardConfiguration: shiftCardConfiguration) { _ in }
          }
          else {
            // Close the SDK
            self.close()
          }
        }
      }
    }
  }

  func backFromManageShiftCardViewer() {
    self.back()
  }

  func closeFromManageShiftCardViewer() {
    self.close()
  }

  func accountSettingsTappedInManageShiftCardViewer() {
    let module = serviceLocator.moduleLocator.accountSettingsModule()
    module.onClose = { [weak self] module in
      self?.dismissModule {
        self?.accountSettingsModule = nil
      }
    }
    self.accountSettingsModule = module
    present(module: module) { _ in }
  }

  func cardSettingsTappedInManageShiftCardViewer() {
    let module = serviceLocator.moduleLocator.cardSettingsModule(card: card)
    module.onClose = { [weak self] module in
      self?.dismissModule {
        self?.shiftCardSettingsModule = nil
      }
    }
    self.shiftCardSettingsModule = module
    module.delegate = self
    present(module: module) { _ in }
  }

  func balanceTappedInManageShiftCardViewer() {
    guard card.features?.allowedBalanceTypes?.isEmpty == false else { return }
    let module = serviceLocator.moduleLocator.fundingSourceSelector(card: card)
    module.onClose = { [weak self] _ in
      self?.dismissModule {
        self?.fundingSourceSelectorModule = nil
      }
    }
    module.onFinish = { [weak self] _ in
      self?.dismissModule {
        self?.fundingSourceSelectorModule = nil
        self?.presenter?.refreshCard()
      }
    }
    self.fundingSourceSelectorModule = module
    present(module: module, embedInNavigationController: false) { _ in }
  }

  func showTransactionDetails(transaction: Transaction) {
    let viewController = buildTransactionDetailsViewControllerFor(uiConfig, transaction: transaction)
    self.push(viewController: viewController) {}
  }

  func physicalActivationSucceed() {
    let physicalCardModule = serviceLocator.moduleLocator.physicalCardActivationSucceedModule(card: card)
    physicalCardModule.onClose = { [unowned self] _ in
      self.dismissModule { [unowned self] in
        self.physicalCardActivationSucceedModule = nil
        self.presenter?.refreshCard()
      }
    }
    physicalCardModule.onFinish = { [unowned self] _ in
      self.dismissModule { [unowned self] in
        self.physicalCardActivationSucceedModule = nil
        self.presenter?.refreshCard()
      }
    }
    present(module: physicalCardModule) { _ in }
    self.physicalCardActivationSucceedModule = physicalCardModule
  }

  fileprivate func buildTransactionDetailsViewControllerFor(
    _ uiConfig: ShiftUIConfig,
    transaction: Transaction) -> UIViewController {
    let presenter = serviceLocator.presenterLocator.transactionDetailsPresenter()
    let interactor = serviceLocator.interactorLocator.transactionDetailsInteractor(transaction: transaction)
    let viewController = serviceLocator.viewLocator.transactionDetailsView(presenter: presenter)
    presenter.interactor = interactor
    presenter.router = self
    presenter.view = viewController
    self.transactionDetailsPresenter = presenter
    return viewController
  }
}

extension ManageShiftCardModule: ShiftCardTransactionDetailsRouterProtocol {
  func backFromTransactionDetails() {
    self.popViewController {}
  }

  func openMapsCenteredIn(latitude: Double, longitude: Double) {
    let regionDistance: CLLocationDistance = 10000
    let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
    let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
    let options = [
      MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
      MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
    ]
    let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
    let mapItem = MKMapItem(placemark: placemark)
    mapItem.name = ""
    mapItem.openInMaps(launchOptions: options)
  }
}

extension ManageShiftCardModule: KYCRouterProtocol {
  func backFromKYC() {
    self.back()
  }

  func closeFromKYC() {
    self.close()
  }

  func kycPassed() {
    if let shiftCardConfiguration = self.shiftCardConfiguration {
      shiftSession.getFinancialAccount(accountId: self.card.accountId,
                                       forceRefresh: true,
                                       retrieveBalances: false) { [weak self] result in
        guard let self = self else { return }
        switch result {
        case .failure(let error):
          self.show(error: error)
        case .success(let financialAccount):
          guard let shiftCard = financialAccount as? Card else {
            return
          }
          self.card = shiftCard
          self.popViewController(animated: false) {
            self.showManageCard(addChild: false,
                                shiftCardConfiguration: shiftCardConfiguration) { _ in }
          }
        }
      }
    }
  }

  func show(url: URL) {
    showExternal(url: url, useSafari: true)
  }
}

extension ManageShiftCardModule: ShiftCardSettingsModuleDelegate {
  func showCardInfo() {
    presenter?.showCardInfo()
  }

  func hideCardInfo() {
    presenter?.hideCardInfo()
  }

  func isCardInfoVisible() -> Bool {
    return presenter?.viewModel.cardInfoVisible.value ?? false
  }

  func cardStateChanged() {
    presenter?.refreshCard()
  }
}
