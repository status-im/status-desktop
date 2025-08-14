import QtQuick
import QtQuick.Layouts

import AppLayouts.Onboarding.enums

/*!
   \qmltype KeycardAddKeyPairDelayedPage
   \inherits KeycardAddKeyPairPage
   \brief It wraps KeycardAddKeyPairPage and controls it using addKeyPairState
    property and adding minimal times of displaying particular states.
*/
KeycardAddKeyPairPage {
    id: root

    required property int addKeyPairState

    inProgress: d.addKeyPairState !== Onboarding.ProgressState.Success

    signal finished

    QtObject {
        id: d

        property int addKeyPairState: root.addKeyPairState

        readonly property int inProgressMinimalTime: 2000
        readonly property int successMinimalTime: 2000

        Binding on addKeyPairState {
            when: extendingInProgressStateTimer.running
            value: Onboarding.ProgressState.InProgress
        }
    }

    Timer {
        id: extendingInProgressStateTimer

        interval: d.inProgressMinimalTime
        running: true
    }

    Timer {
        id: extendingSuccessStateTimer

        running: root.addKeyPairState === Onboarding.ProgressState.Success
        interval: d.successMinimalTime

        onTriggered: root.finished()
    }
}
