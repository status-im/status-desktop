import QtQuick 2.13

import "../popups"
import "../stores"
import "../shared"

Item {
    property var onClosed: function () {}

    signal showCreatePasswordView()

    id: genKeyView
    anchors.fill: parent

    Component.onCompleted: {
        genKeyModal.open()
    }

    GenKeyModal {
        property bool wentNext: false
        id: genKeyModal
        onNextClick: function (selectedIndex, displayName) {
            wentNext = true
            OnboardingStore.setCurrentAccountAndDisplayName(selectedIndex, displayName)
            showCreatePasswordView()
        }
        onClosed: function () {
            if (!wentNext) {
                genKeyView.onClosed()
            }
        }
    }
}
