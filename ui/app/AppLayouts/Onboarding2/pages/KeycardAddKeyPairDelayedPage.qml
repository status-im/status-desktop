import QtQuick 2.15
import QtQuick.Layouts 1.15

import AppLayouts.Onboarding.enums 1.0

/*!
   \qmltype KeycardAddKeyPairDelayedPage
   \inherits KeycardAddKeyPairPage
   \brief It wraps KeycardAddKeyPairPaget and controls it using addKeyPairState
    property and adding minimal times of displaying particular states.
*/
KeycardAddKeyPairPage {
    id: root

    property int addKeyPairState

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
