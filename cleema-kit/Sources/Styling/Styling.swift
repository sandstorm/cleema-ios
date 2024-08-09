//
//  Created by Kumpels and Friends on 15.12.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

#if canImport(UIKit)
import UIKit
#endif
import SwiftUI

public enum Styling {
    public static let bundle = Bundle.module

    public static let cleemaLogo = Asset.cleemaLogo.image
    public static let projectsIcon = Asset.projectsIcon.image
    public static let newsIcon = Asset.newsIcon.image

    public static func configureApp() {
        registerFonts()
        configureAppearance()
    }

    static func configureAppearance() {
        #if canImport(UIKit)
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.backgroundEffect = UIBlurEffect(style: .systemThinMaterialLight)
        tabBarAppearance.backgroundColor = .accent.withAlphaComponent(0.25)
        let tabBarItemAppearance = UITabBarItemAppearance()

        tabBarItemAppearance.normal.iconColor = .dimmed
        tabBarItemAppearance.normal.titleTextAttributes = [
            .font: UIFont.montserrat(size: 12),
            .foregroundColor: UIColor.dimmed
        ]
        tabBarItemAppearance.selected.iconColor = .defaultText
        tabBarItemAppearance.selected.titleTextAttributes = [
            .font: UIFont.montserrat(size: 12),
            .foregroundColor: UIColor.defaultText
        ]

        tabBarAppearance.stackedLayoutAppearance = tabBarItemAppearance
        UITabBar.appearance().standardAppearance = tabBarAppearance

        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithDefaultBackground()
        navAppearance.backgroundEffect = UIBlurEffect(style: .systemThinMaterialDark)
        navAppearance.backgroundColor = .defaultText.withAlphaComponent(0.3)
        navAppearance.titleTextAttributes = [.font: UIFont.montserrat(size: 18).bold(), .foregroundColor: UIColor.light]
        let buttonAppearance = UIBarButtonItemAppearance()
        buttonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.accent]
        navAppearance.buttonAppearance = buttonAppearance
        UINavigationBar.appearance().standardAppearance = navAppearance

        let scrollNavAppearance = UINavigationBarAppearance()
        scrollNavAppearance.configureWithTransparentBackground()
        scrollNavAppearance.titleTextAttributes = [
            .font: UIFont.montserrat(size: 18).bold(),
            .foregroundColor: UIColor.light
        ]
        UINavigationBar.appearance().scrollEdgeAppearance = scrollNavAppearance

        UIRefreshControl.appearance().tintColor = .white

        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).tintColor = .dimmed
        UISearchBar.appearance()
            .setSearchFieldBackgroundImage(UIImage(named: "searchbar-background", in: .module, with: nil), for: .normal)
        UISearchBar.appearance()
            .setImage(UIImage(named: "magnifyingGlass", in: .module, with: nil), for: .search, state: .normal)

        let sheetNavAppearance = UINavigationBarAppearance()
        sheetNavAppearance.configureWithDefaultBackground()
        sheetNavAppearance.backgroundColor = .accent
        sheetNavAppearance.shadowColor = .clear
        sheetNavAppearance.titleTextAttributes = [
            .font: UIFont.montserrat(size: 18).bold(),
            .foregroundColor: UIColor.defaultText
        ]
        sheetNavAppearance.largeTitleTextAttributes = [
            .font: UIFont.montserrat(size: 24).bold(),
            .foregroundColor: UIColor.defaultText
        ]

        UINavigationBar.appearance(whenContainedInInstancesOf: [UIPresentationController.self])
            .standardAppearance = sheetNavAppearance
        UINavigationBar.appearance(whenContainedInInstancesOf: [UIPresentationController.self])
            .scrollEdgeAppearance = sheetNavAppearance

        UISegmentedControl.appearance().selectedSegmentTintColor = .defaultText
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.defaultText], for: .normal)
        UISegmentedControl.appearance().backgroundColor = .white

        UIProgressView.appearance().tintColor = .accent
        UIProgressView.appearance().trackTintColor = .accent.withAlphaComponent(0.3)

        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = .defaultText
        #endif
    }
}
