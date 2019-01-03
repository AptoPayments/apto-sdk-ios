//
//  NewApplicationModule.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 12/12/2017.
//

import UIKit

class NewApplicationModule: UIModule {
  private var linkSession: LinkSession {
    return shiftSession.linkSession
  }

  private var initialDataPointList: DataPointList

  private var contextConfiguration: ContextConfiguration! // swiftlint:disable:this implicitly_unwrapped_optional
  private var projectConfiguration: ProjectConfiguration {
    return contextConfiguration.projectConfiguration
  }
  private var linkConfiguration: LinkConfiguration! // swiftlint:disable:this implicitly_unwrapped_optional

  private var userMissingDataPoints: RequiredDataPointList! // swiftlint:disable:this implicitly_unwrapped_optional
  private var userDataPoints: DataPointList! // swiftlint:disable:this implicitly_unwrapped_optional

  private var linkOfferListModule: LinkOfferListModule?
  private var linkLoanDataCollectorModule: LinkLoanDataCollectorModule?
  private var userDataCollectorModule: UserDataCollectorModule?

  open var onOfferApplied: ((_ offerListModule: NewApplicationModule, _ offer: LoanOffer) -> Void)?

  // MARK: - Module Initialization

  init(serviceLocator: ServiceLocatorProtocol, initialDataPointList: DataPointList?) {
    self.initialDataPointList = initialDataPointList ?? DataPointList()
    super.init(serviceLocator: serviceLocator)
  }

  override func initialize(completion: @escaping Result<UIViewController, NSError>.Callback) {
    self.loadConfigurationFromServer { result in
      switch result {
      case .failure(let error):
        completion(.failure(error))
        return
      case .success:
        if self.linkConfiguration.posMode {
          // Empty user data
          self.userMissingDataPoints = self.linkConfiguration.userRequiredData.getMissingDataPoints(
            self.initialDataPointList)

          // Prepare the initial screen
          self.prepareInitialScreen(completion)
        }
        else {
          // try to get info about the current user
          self.shiftSession.currentUser(filterInvalidTokenResult: false) { result in
            switch result {
            case .failure:
              // There's no current user.
              ShiftPlatform.defaultManager().clearUserToken()
              self.userDataPoints = self.initialDataPointList

            case .success (let user):
              self.userDataPoints = user.userData
            }

            // Calculate the missing data points
            self.userMissingDataPoints = self.linkConfiguration.userRequiredData.getMissingDataPoints(
              self.userDataPoints)

            // Prepare the initial screen
            self.prepareInitialScreen(completion)
          }
        }
      }
    }
  }

  // MARK: - Initial Screen Setup

  fileprivate func prepareInitialScreen(_ completion:@escaping Result<UIViewController, NSError>.Callback) {
    if !linkConfiguration.skipLoanAmount || !linkConfiguration.skipLoanPurpose {
      let linkLoanDataCollectorModule = buildLoanDataCollectorModule(linkConfiguration,
                                                                     initialLoanData: linkSession.loanData,
                                                                     userMissingDataPoints: userMissingDataPoints)
      self.linkLoanDataCollectorModule = linkLoanDataCollectorModule
      addChild(module: linkLoanDataCollectorModule, completion: completion)
    }
    else {
      let disclaimers = linkConfiguration.loanProducts.compactMap { $0.prequalificationDisclaimer }
      let moduleLocator = serviceLocator.moduleLocator
      let userRequiredData = linkConfiguration.userRequiredData
      let userDataCollectorModule = moduleLocator.userDataCollectorModule(userRequiredData: userRequiredData,
                                                                          mode: .continueFlow,
                                                                          backButtonMode: .close,
                                                                          disclaimers: disclaimers)
      userDataCollectorModule.onClose = { [weak self] module in
        self?.close()
      }
      self.userDataCollectorModule = userDataCollectorModule
      self.addChild(module: userDataCollectorModule, completion: completion)
    }
  }

  // MARK: - Loan Data Collector Handling

  fileprivate func buildLoanDataCollectorModule(_ linkConfig: LinkConfiguration,
                                                initialLoanData: AppLoanData?,
                                                userMissingDataPoints: RequiredDataPointList)
      -> LinkLoanDataCollectorModule {
    let linkLoanDataCollectorModule = LinkLoanDataCollectorModule(
      serviceLocator: serviceLocator,
      loanData: linkSession.loanData,
      config: LinkLoanDataCollectorConfig(userMissingDataPoints: userMissingDataPoints, linkConfig: linkConfig))
    linkLoanDataCollectorModule.onClose = { [weak self] module in
      self?.close()
      self?.linkLoanDataCollectorModule = nil
    }
    linkLoanDataCollectorModule.onBack = { module in
      self.popModule {
        self.linkLoanDataCollectorModule = nil
      }
    }
    linkLoanDataCollectorModule.onLoanDataCollected = { module, loanData in
      if self.userMissingDataPoints.count() > 0 {
        self.showUserDataCollector(.continueFlow)
      }
      else {
        let prequalificationDisclaimers = linkConfig.loanProducts.compactMap { loanProduct -> Content? in
          guard let disclaimer = loanProduct.prequalificationDisclaimer else {
            return nil
          }
          switch disclaimer {
          case .plainText:
            return nil
          default:
            return disclaimer
          }
        }
        guard !prequalificationDisclaimers.isEmpty else {
          // Show the offer list
          self.showOfferList()
          return
        }
        self.shiftSession.currentUser { result in
          switch result {
          case .success (let user):
            self.showPrequalificationDisclaimers(disclaimers: prequalificationDisclaimers,
                                                 user: user)
          case .failure(let error):
            self.show(error: error)
          }
        }
      }
    }
    return linkLoanDataCollectorModule
  }

  // MARK: - User Data Collector Handling

  fileprivate func showUserDataCollector(_ mode: UserDataCollectorFinalStepMode) {
    let moduleLocator = serviceLocator.moduleLocator
    let userRequiredData = linkConfiguration.userRequiredData
    let disclaimers = linkConfiguration.loanProducts.compactMap { $0.prequalificationDisclaimer }
    let userDataCollectorModule = moduleLocator.userDataCollectorModule(userRequiredData: userRequiredData,
                                                                        mode: mode,
                                                                        backButtonMode: .back,
                                                                        disclaimers: disclaimers)
    userDataCollectorModule.onBack = { module in
      self.popModule {
        self.userDataCollectorModule = nil
      }
    }
    userDataCollectorModule.onClose = { module in
      self.close()
    }
    userDataCollectorModule.onUserDataCollected = { _, user in
      let prequalificationDisclaimers = self.linkConfiguration.loanProducts
        .compactMap { $0.prequalificationDisclaimer }
        .filter { !$0.isPlainText }
      guard !prequalificationDisclaimers.isEmpty else {
        self.showOfferList()
        return
      }
      self.showPrequalificationDisclaimers(disclaimers: prequalificationDisclaimers, user: user)
    }
    self.userDataCollectorModule = userDataCollectorModule
    self.push(module: userDataCollectorModule) { _ in
      print (self)
    }
  }

  // MARK: - Prequalification Disclaimers Handling

  fileprivate func showPrequalificationDisclaimers(disclaimers: [Content], user: ShiftUser) {
    if !disclaimers.isEmpty {
      var newDisclaimers = disclaimers
      let disclaimerToShow = newDisclaimers.removeFirst()

      self.showPrequalificationDisclaimer(
        disclaimer: disclaimerToShow,
        user: user,
        onClose: { _ in }, // Nothing to do here
        onAgree: { [weak self] _ in
          self?.showPrequalificationDisclaimers(disclaimers: newDisclaimers, user: user)
      })
    }
    else {
      self.showOfferList()
    }
  }

  fileprivate func showPrequalificationDisclaimer(disclaimer: Content?,
                                                  user: ShiftUser,
                                                  onClose: @escaping ((_ module: UIModuleProtocol) -> Void),
                                                  onAgree: @escaping ((_ module: UIModuleProtocol) -> Void)) {
    guard var disclaimer = disclaimer else {
      return
    }

    // Replace the State and Language in the disclaimer url
    let state = user.userData.addressDataPoint.region.value?.uppercased()
    disclaimer.replaceInURL(string: "%5Bstate%5D", with: state)
    disclaimer.replaceInURL(string: "%5Blanguage%5D", with: LocalLanguage.language)

    // Show the prequalification disclaimer
    let moduleLocator = serviceLocator.moduleLocator
    let prequalificationDisclaimerModule = moduleLocator.fullScreenDisclaimerModule(disclaimer: disclaimer)
    prequalificationDisclaimerModule.onClose = { [weak self] module in
      self?.dismissModule {
        onClose(module)
      }
    }
    prequalificationDisclaimerModule.onDisclaimerAgreed = { module in
      self.dismissModule {
        onAgree(module)
      }
    }
    self.present(module: prequalificationDisclaimerModule) { _ in }
  }

  // MARK: - Offer List Handling

  fileprivate func showOfferList() {
    let linkOfferListModule = LinkOfferListModule(serviceLocator: serviceLocator)
    linkOfferListModule.onClose = { [unowned self] _ in
      self.linkOfferListModule = nil
      self.close()
    }
    linkOfferListModule.onBack = { _ in
      self.popModule {
        self.linkOfferListModule = nil
      }
    }
    linkOfferListModule.onOfferApplied = { _, offer in
      self.onOfferApplied?(self, offer)
    }
    self.linkOfferListModule = linkOfferListModule
    push(module: linkOfferListModule) { _ in }
  }

  // MARK: - Load project configuration

  fileprivate func loadConfigurationFromServer(_ completion:@escaping Result<Void, NSError>.Callback) {
    self.shiftSession.contextConfiguration(true) { result in
      switch result {
      case .failure(let error):
        completion(.failure(error))
      case .success (let contextConfiguration):
        self.contextConfiguration = contextConfiguration
        self.linkSession.linkConfiguration(true) { result in
          switch result {
          case .failure(let error):
            completion(.failure(error))
          case .success(let linkConfiguration):
            self.linkConfiguration = linkConfiguration
            completion(.success(Void()))
          }
        }
      }
    }
  }

}
