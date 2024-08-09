//
//  Created by Kumpels and Friends on 12.12.22.
//  Copyright © 2023 Kumpels and Friends. All rights reserved.
//

import Foundation
import SwiftUINavigation

public extension AlertState {
    static var followInvitationNotPossible: Self {
        .init(
            title: TextState(L10n.Alert.Invitation.LocalImpossible.title),
            message: TextState(L10n.Alert.Invitation.LocalImpossible.message),
            buttons: [
                .cancel(
                    TextState(L10n.Alert.Invitation.Dismiss.title)
                )
            ]
        )
    }

    static var invitationDenied: Self {
        .init(
            title: TextState(L10n.Alert.Invitation.Denied.title),
            message: TextState(L10n.Alert.Invitation.Denied.message),
            buttons: [
                .cancel(
                    TextState(L10n.Alert.Invitation.Dismiss.title)
                )
            ]
        )
    }

    static func errorResponse(message: String? = nil) -> Self {
        .init(
            title: TextState(L10n.Alert.Generic.title),
            message: TextState(message ?? L10n.Alert.Generic.message),
            buttons: [
                .cancel(
                    TextState(L10n.Alert.Invitation.Dismiss.title)
                )
            ]
        )
    }
}
