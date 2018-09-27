//
//  StandardFlowTests.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 02/11/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit
import ShiftSDK

class StandardFlowTests: ShiftUITest {
  
  func testStandardFlow() {
    
    // Given
    let testTeam = helper.provisionTestTeam(name: "Test Team")
    let testProject = helper.provisionTestProject(team: testTeam, name: "Test Project")
    let keys = helper.getKeys(teamId: testTeam?.teamId, projectId: testProject?.projectId)
    print("Team Key: \(keys!["teamKey"])")
    print("Project Key: \(keys!["projectKey"])")
    self.configure(teamKey: keys?["teamKey"], projectKey: keys?["projectKey"])
    
    let loanAmount = 2800
    let loanPurpose = "Bills"
    let firstName = "User"
    let lastName = "Test"
    let email = "test@shiftpayments.com"
    let phoneNumber = "9366665555"
    let address = "1310 Fillmore St."
    let zipCode = "94115"
    let homeType = "Own"
    let grossIncome = 90000
    let netIncome = 5000
    let creditScore = "Excellent (760+)"
    let birthDate = dateFromString(date: "05311980")!
    let ssn = "111111111"
    let pan = "4294800883199044"
    let expirationDate = "1221"
    let cvv = "123"
    
    // Then
    SDKLauncherScreen(self)
      .waitForScreen()
      .startShiftSDK()
    
    InputPhoneScreen(self)
      .waitForScreen()
      .input(phoneNumber: phoneNumber)
      .next()
    
    VerifyPhoneNumberScreen(self)
      .waitForScreen()
      .waitUntilAvailable { AutomationStorage.verificationSecret as AnyObject? }
      .input(verificationCode:AutomationStorage.verificationSecret!)
      .submitCode()
    
    CollectLoanDataScreen(self)
      .waitForScreen()
      .selectLoan(amount: loanAmount)
      .selectLoan(purpose: loanPurpose)
      .next()
    
    BasicUserInfoScreen(self)
      .waitForScreen()
      .input(firstName: firstName)
      .input(lastName: lastName)
      .input(email: email)
      .next()
    
    HomeScreen(self)
      .waitForScreen()
      .input(zipCode: zipCode)
      .select(homeType: homeType)
      .next()
    
    AddressScreen(self)
      .waitForScreen()
      .input(address: address)
      .next()
    
    GrossIncomeScreen(self)
      .waitForScreen()
      .select(grossIncome: grossIncome)
      .next()
    
    NetIncomeScreen(self)
      .waitForScreen()
      .select(netIncome: netIncome)
      .next()
    
    CreditScoreScreen(self)
      .waitForScreen()
      .select(creditScore: creditScore)
      .next()
    
    VerifyIdScreen(self)
      .waitForScreen()
      .input(birthdate: birthDate)
      .input(ssn: ssn)
      .getOffers()
    
    DisclaimerScreen(self)
      .waitForScreen()
      .agree()
    
    OfferListScreen(self)
      .waitForScreen()
      .applyToFirstOffer()
    
    ApplicationSummaryScreen(self)
      .waitForScreen()
      .scrollDown()
      .agree()
    
    SelectAccountTypeScreen(self)
      .waitForScreen()
      .issueVirtualCard()
    
    LoanFundedScreen(self)
      .waitForScreen()
      .viewVirtualCard()
    
    ShowCardScreen(self)
      .waitForScreen()
    
    // Start the sdk again
    resetSDK()
    
    SDKLauncherScreen(self)
      .waitForScreen()
      .startShiftSDK()
    
    CollectLoanDataScreen(self)
      .waitForScreen()
      .selectLoan(amount: loanAmount)
      .selectLoan(purpose: loanPurpose)
      .getOffers()
    
    OfferListScreen(self)
      .waitForScreen()
      .applyToFirstOffer()
    
    ApplicationSummaryScreen(self)
      .waitForScreen()
      .scrollDown()
      .agree()
    
    SelectAccountScreen(self)
      .waitForScreen()
      .addAccount()
    
    SelectAccountTypeScreen(self)
      .waitForScreen()
      .addCard()
    
    AddCardScreen(self)
      .waitForScreen()
      .enter(cardNumber: pan, expirationDate: expirationDate, cvv: cvv)
      .addCard()
    
    LoanFundedScreen(self)
      .waitForScreen()
    
    // Delete the new user
    helper.deleteUser(countryCode: 1, phoneNumber: phoneNumber)
    
  }
  
}
