import QtQuick

import AppLayouts.Onboarding.enums

/*!
   \qmltype KeycardCreatePinDelayedPage
   \inherits KeycardCreatePinPage
   \brief It wraps KeycardCreatePinPage and controls it using authorizationState
    and pinSettingState properties and adding minimal time of displaying a success
    state.
*/
KeycardCreatePinPage {
    id: root

    required property int pinSettingState
    required property int authorizationState
    required property int keycardPinInfoPageDelay

    success: root.authorizationState === Onboarding.ProgressState.Success &&
             root.pinSettingState === Onboarding.ProgressState.Success

    signal finished
    signal authorizationRequested

    Timer {
        interval: root.keycardPinInfoPageDelay
        running: root.success

        onTriggered: root.finished()
    }

    Connections {
        target: root

        function onPinSettingStateChanged() {
            if (root.pinSettingState === Onboarding.ProgressState.Success)
                root.authorizationRequested()
        }
    }
}
