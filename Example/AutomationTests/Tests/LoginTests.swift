//
//  LoginTests.swift
//  ShiftSDK
//
//  Created by Ivan Oliver Martínez on 17/08/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import Foundation
import ShiftSDK

class LoginTests: ShiftUITest {
  
  func skipTestNonExistingUserShowsSignupFlow() {
    
    // Given
    let testTeam = helper.provisionTestTeam(name: "Test Team")
    let testProject = helper.provisionTestProject(team: testTeam, name: "Test Project")
    let keys = helper.getKeys(teamId: testTeam?.teamId, projectId: testProject?.projectId)
    self.configure(teamKey: keys?["teamKey"], projectKey: keys?["projectKey"])
    let nonExistingPhoneNumber = "9366665555"
    
    // When
    SDKLauncherScreen(self)
      .waitForScreen()
      .startShiftSDK()
    
    WelcomeScreenScreen(self)
      .waitForScreen()
      .agreeProjectDisclaimer()
    
    CollectLoanDataScreen(self)
      .waitForScreen()
      .selectLoan(amount:2800)
      .selectLoan(purpose:"Bills")
      .next()
    
    InputPhoneScreen(self)
      .waitForScreen()
      .input(phoneNumber: nonExistingPhoneNumber)
      .wait(seconds: 1)
      .next()
    
    VerifyPhoneNumberScreen(self)
      .waitForScreen()
      .waitUntilAvailable { AutomationStorage.verificationSecret as AnyObject? }
      .input(verificationCode:AutomationStorage.verificationSecret!)
      .submitCode()
    
    // Then
    BasicUserInfoScreen(self)
      .waitForScreen()
    
  }
  
  func skipTestExistingUserShowsLoginFlow() {
    
    // Given
    let testTeam = helper.provisionTestTeam(name: "Test Team")
    let testProject = helper.provisionTestProject(team: testTeam, name: "Test Project")
    let keys = helper.getKeys(teamId: testTeam?.teamId, projectId: testProject?.projectId)
    self.configure(teamKey: keys?["teamKey"], projectKey: keys?["projectKey"])

    guard let testUser = helper.provisionTestUser(teamKey: keys?["teamKey"], projectKey: keys?["projectKey"], verifiedPhone: true) else {
      SDKLauncherScreen(self).fail()
      return
    }
    
    let phoneNumber = testUser.userData.phoneDataPoint
    
    // When
    SDKLauncherScreen(self)
      .waitForScreen()
      .startShiftSDK()
    
    WelcomeScreenScreen(self)
      .waitForScreen()
      .agreeProjectDisclaimer()
    
    CollectLoanDataScreen(self)
      .waitForScreen()
      .selectLoan(amount:2800)
      .selectLoan(purpose:"Bills")
      .next()
    
    InputPhoneScreen(self)
      .waitForScreen()
      .input(phoneNumber: phoneNumber.phoneNumber.value!)
      .next()
    
    VerifyPhoneNumberScreen(self)
      .waitForScreen()
      .waitUntilAvailable { AutomationStorage.verificationSecret as AnyObject? }
      .input(verificationCode:AutomationStorage.verificationSecret!)
      .submitCode()
    
    // Then
    VerifyEmailScreen(self)
      .waitForScreen()
    
  }
  
}
