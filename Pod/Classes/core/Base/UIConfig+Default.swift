import Foundation

extension UIConfig {
  public static let `default` = UIConfig(
    branding: Branding(light: projectBranding, dark: projectBranding)
  )
  
  private static let projectBranding = ProjectBranding(
    uiBackgroundPrimaryColor: "f2f3f4",
    uiBackgroundSecondaryColor: "f2f3f4",
    iconPrimaryColor: "000000",
    iconSecondaryColor: "000000",
    iconTertiaryColor: "000000",
    textPrimaryColor: "FF2B2D35",
    textSecondaryColor: "FF54565F",
    textTertiaryColor: "FFBBBDBD",
    textTopBarPrimaryColor: "202A36",
    textTopBarSecondaryColor: "FFFFFF",
    textLinkColor: "FF54565F",
    textLinkUnderlined: true,
    textButtonColor: "FFFFFF",
    buttonCornerRadius: 12.0,
    uiPrimaryColor: "F90D00",
    uiSecondaryColor: "FF9500",
    uiTertiaryColor: "FFCC00",
    uiErrorColor: "FFDC4337",
    uiSuccessColor: "DB1D0E",
    uiNavigationPrimaryColor: "f2f3f4",
    uiNavigationSecondaryColor: "202a36",
    uiBackgroundOverlayColor: "f2f3f4",
    textMessageColor: "FFFFFF",
    badgeBackgroundPositiveColor: "61ca00",
    badgeBackgroundNegativeColor: "326700",
    showToastTitle: true,
    transactionDetailsCollapsable: true,
    disclaimerBackgroundColor: "f2f3f4",
    uiStatusBarStyle: "light",
    logoUrl: nil,
    uiTheme: "theme_2"
  )
}
