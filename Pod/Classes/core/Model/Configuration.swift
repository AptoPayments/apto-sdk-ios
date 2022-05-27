//
//  ProjectConfiguration.swift
//  AptoSDK
//
//  Created by Ivan Oliver Martínez on 13/01/2017.
//
//

import Foundation

open class ContextConfiguration {
    public let teamConfiguration: TeamConfiguration
    public let projectConfiguration: ProjectConfiguration

    init(teamConfiguration: TeamConfiguration, projectConfiguration: ProjectConfiguration) {
        self.teamConfiguration = teamConfiguration
        self.projectConfiguration = projectConfiguration
    }
}

open class TeamConfiguration {
    public let logoUrl: String?
    public let name: String

    init(logoUrl: String?, name: String) {
        self.logoUrl = logoUrl
        self.name = name
    }
}

public struct ProjectBranding: Codable {
    public let uiBackgroundPrimaryColor: String
    public let uiBackgroundSecondaryColor: String
    public let iconPrimaryColor: String
    public let iconSecondaryColor: String
    public let iconTertiaryColor: String
    public let textPrimaryColor: String
    public let textSecondaryColor: String
    public let textTertiaryColor: String
    public let textTopBarPrimaryColor: String
    public let textTopBarSecondaryColor: String
    public let textLinkColor: String
    public let textLinkUnderlined: Bool
    public let textButtonColor: String
    public let buttonCornerRadius: Float
    public let uiPrimaryColor: String
    public let uiSecondaryColor: String
    public let uiTertiaryColor: String
    public let uiErrorColor: String
    public let uiSuccessColor: String
    public let uiNavigationPrimaryColor: String
    public let uiNavigationSecondaryColor: String
    public let uiBackgroundOverlayColor: String
    public let textMessageColor: String
    public let badgeBackgroundPositiveColor: String
    public let badgeBackgroundNegativeColor: String
    public let showToastTitle: Bool
    public let transactionDetailsCollapsable: Bool
    public let disclaimerBackgroundColor: String
    public let uiStatusBarStyle: String
    public let logoUrl: String?
    public let uiTheme: String
}

public struct Branding: Codable {
    public let light: ProjectBranding
    public let dark: ProjectBranding
}

open class ProjectConfiguration {
    public let name: String
    public let summary: String?
    public let allowUserLogin: Bool
    public let skipSteps: Bool
    public let strictAddressValidation: Bool
    public let primaryAuthCredential: DataPointType
    public let secondaryAuthCredential: DataPointType
    public let supportEmailAddress: String?
    public let branding: Branding
    public let allowedCountries: [Country]
    public let welcomeScreenAction: WorkflowAction
    let defaultCountryCode: Int
    let requiredSignedPayloads: Bool
    let products: [Product]
    let isTrackerActive: Bool?
    let trackerAccessToken: String?

    init(name: String,
         summary: String?,
         allowUserLogin: Bool,
         primaryAuthCredential: DataPointType,
         secondaryAuthCredential: DataPointType,
         skipSteps: Bool,
         strictAddressValidation: Bool,
         defaultCountryCode: Int,
         requiredSignedPayloads: Bool,
         products: [Product],
         welcomeScreenAction: WorkflowAction,
         supportEmailAddress: String?,
         branding: Branding,
         allowedCountries: [Country]?,
         isTrackerActive: Bool?,
         trackerAccessToken: String?)
    {
        self.name = name
        self.summary = summary
        self.allowUserLogin = allowUserLogin
        self.primaryAuthCredential = primaryAuthCredential
        self.secondaryAuthCredential = secondaryAuthCredential
        self.skipSteps = skipSteps
        self.strictAddressValidation = strictAddressValidation
        self.defaultCountryCode = defaultCountryCode
        self.requiredSignedPayloads = requiredSignedPayloads
        self.products = products
        self.welcomeScreenAction = welcomeScreenAction
        self.supportEmailAddress = supportEmailAddress
        self.branding = branding
        self.isTrackerActive = isTrackerActive
        self.trackerAccessToken = trackerAccessToken
        if let allowedCountries = allowedCountries, !allowedCountries.isEmpty {
            self.allowedCountries = allowedCountries
        } else {
            self.allowedCountries = [Country.defaultCountry]
        }
    }
}
