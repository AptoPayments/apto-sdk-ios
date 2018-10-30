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
  private var shiftCardSettingsModule: ShiftCardSettingsModule?
  private var accountSettingsModule: UIModuleProtocol?
  private var projectConfiguration: ProjectConfiguration! // swiftlint:disable:this implicitly_unwrapped_optional
  private var mailSender: MailSender?
  private var shiftCardConfiguration: ShiftCardConfiguration?
  private var presenter: ManageShiftCardPresenter?
  private var kycPresenter: KYCPresenter?
  private var physicalCardModule: PhysicalCardActivationSucceedModuleProtocol?
  private var externalOAuthModule: ExternalOAuthModuleProtocol?

  public init(serviceLocator: ServiceLocatorProtocol, card: Card, mode: ShiftCardModuleMode) {
    self.card = card
    self.mode = mode
    super.init(serviceLocator: serviceLocator)
  }

  override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
    shiftSession.contextConfiguration { result in
      switch result {
      case .failure(let error):
        completion(.failure(error))
      case .success(let contextConfiguration):
        self.projectConfiguration = contextConfiguration.projectConfiguration
        self.shiftSession.shiftCardSession.shiftCardConfiguration { result in
          switch result {
          case .failure(let error):
            completion(.failure(error))
          case .success(let shiftCardConfiguration):
            self.shiftCardConfiguration = shiftCardConfiguration
            // Refresh the card data
            self.shiftSession.getFinancialAccount(accountId: self.card.accountId, retrieveBalance: false) { result in
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
                    self.loadBalanceAndShowManageCard(addChild: true,
                                                      shiftCardConfiguration: shiftCardConfiguration,
                                                      completion: completion)
                  default:
                    self.showKYCViewController(addChild: true, card: self.card, completion: completion)
                  }
                }
                else {
                  self.loadBalanceAndShowManageCard(addChild: true,
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

  private func loadBalanceAndShowManageCard(addChild: Bool,
                                            shiftCardConfiguration: ShiftCardConfiguration,
                                            completion: @escaping Result<UIViewController, NSError>.Callback) {
    shiftSession.shiftCardSession.getCardFundingSource(card: card) { result in
      switch result {
      case .failure(let error):
        completion(.failure(error))
      case .success(_):
        self.showManageCardViewController(addChild: addChild,
                                          shiftCardConfiguration: shiftCardConfiguration,
                                          completion: completion)
      }
    }
  }

  // MARK: - Manage Card View Controller

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
                                                      card: Card) -> ManageShiftCardViewController {
    let showActivateCardButton = shiftCardConfiguration.isFeatureEnabled(.showActivateCardButton)
    let config = ManageShiftCardPresenterConfig(name: projectConfiguration.name,
                                                imageUrl: projectConfiguration.branding.logoUrl,
                                                showActivateCardButton: showActivateCardButton)
    let presenter = ManageShiftCardPresenter(config: config)
    let interactor = ManageShiftCardInteractor(shiftSession: shiftSession,
                                               accountId: card.accountId,
                                               uiConfig: uiConfig)
    let viewController = ManageShiftCardViewController(mode: mode, uiConfiguration: uiConfig, eventHandler: presenter)
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

  fileprivate func buildKYCViewController(_ uiConfig: ShiftUIConfig, card: Card) -> KYCViewController {
    let presenter = KYCPresenter()
    let interactor = KYCInteractor(shiftSession: shiftSession, card: card)
    let viewController = KYCViewController(uiConfiguration: uiConfig, eventHandler: presenter)
    presenter.router = self
    presenter.interactor = interactor
    presenter.view = viewController
    self.kycPresenter = presenter
    return viewController
  }
}

extension ManageShiftCardModule: ManageShiftCardRouterProtocol {
  func update(card newCard: Card) {
    self.card = newCard
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
    let module = ShiftCardSettingsModule(serviceLocator: serviceLocator, card: card, phoneCaller: PhoneCaller())
    module.onClose = { [weak self] module in
      self?.dismissModule {
        self?.shiftCardSettingsModule = nil
      }
    }
    self.shiftCardSettingsModule = module
    module.delegate = self
    present(module: module) { _ in }
  }

  func showTransactionDetails(transaction: Transaction) {
    // swiftlint:disable:next force_unwrapping
    let viewController = buildTransactionDetailsViewControllerFor(uiConfig, transaction: transaction)
    self.push(viewController: viewController) {}
  }

  func physicalActivationSucceed() {
    let physicalCardModule = serviceLocator.moduleLocator.physicalCardActivationSucceedModule(card: card)
    physicalCardModule.onClose = { [unowned self] _ in
      self.dismissModule { [unowned self] in
        self.physicalCardModule = nil
        self.presenter?.refreshCard()
      }
    }
    physicalCardModule.onFinish = { [unowned self] _ in
      self.dismissModule { [unowned self] in
        self.physicalCardModule = nil
        self.presenter?.refreshCard()
      }
    }
    present(module: physicalCardModule) { _ in }
    self.physicalCardModule = physicalCardModule
  }

  func addFundingSource(completion: @escaping (FundingSource) -> Void) {
    // TODO: Remove as soon as this feature is deployed in the backend
    let allowedBalanceTypes = card.features?.allowedBalanceTypes ?? []
    let oauthModuleConfig = ExternalOAuthModuleConfig(title: "Coinbase", allowedBalanceTypes: allowedBalanceTypes)
    let externalOAuthModule = serviceLocator.moduleLocator.externalOAuthModule(config: oauthModuleConfig,
                                                                               uiConfig: uiConfig)
    externalOAuthModule.onOAuthSucceeded = { [unowned self] _, custodian in
      self.showLoadingSpinner()
      self.shiftSession.addFinancialAccountFundingSource(accountId: self.card.accountId,
                                                         custodian: custodian) { result in
        self.hideLoadingSpinner()
        switch result {
        case .failure(let error):
          self.show(error: error)
        case .success(let fundingSource):
          self.dismissModule {
            self.externalOAuthModule = nil
            completion(fundingSource)
          }
        }
      }
    }
    externalOAuthModule.onClose = { [unowned self] _ in
      self.dismissModule {
        self.externalOAuthModule = nil
      }
    }
    self.externalOAuthModule = externalOAuthModule
    present(module: externalOAuthModule) { _ in }
  }

  fileprivate func buildTransactionDetailsViewControllerFor(_ uiConfig: ShiftUIConfig,
                                                            transaction: Transaction) -> UIViewController {
    let presenter = ShiftCardTransactionDetailsPresenter()
    let interactor = ShiftCardTransactionDetailsInteractor(shiftSession: shiftSession, transaction: transaction)
    let viewController = ShiftCardTransactionDetailsViewController(uiConfiguration: uiConfig, presenter: presenter)
    presenter.interactor = interactor
    presenter.router = self
    presenter.view = viewController
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
      self.popViewController(animated: false) {
        self.showManageCardViewController(shiftCardConfiguration: shiftCardConfiguration) { _ in }
      }
    }
  }
}

extension ManageShiftCardModule: ShiftCardSettingsModuleDelegate {
  func showCardInfo() {
    presenter?.viewModel.cardInfoVisible.next(true)
  }

  func hideCardInfo() {
    presenter?.viewModel.cardInfoVisible.next(false)
  }

  func isCardInfoVisible() -> Bool {
    return presenter?.viewModel.cardInfoVisible.value ?? false
  }

  func cardStateChanged() {
    presenter?.refreshCard()
  }

  func fundingSourceChanged() {
    presenter?.refreshCard()
  }
}
