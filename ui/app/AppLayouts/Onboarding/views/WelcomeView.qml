import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import shared 1.0
import shared.panels 1.0
import "../popups"
import "../stores"

import utils 1.0

Item {
    id: root

    property StartupStore startupStore

    Component.onCompleted: {
        if (root.startupStore.showBeforeGetStartedPopup()) {
            beforeGetStartedModal.open();
            return
        }
        btnNewUser.forceActiveFocus()
    }

    QtObject {
        id: d

        function showMetricsAndRunAction(action) {
            Global.openMetricsEnablePopupRequested(Constants.metricsEnablePlacement.welcome, popup => popup.closed.connect(() => action()))
        }
    }

    BeforeGetStartedModal {
        id: beforeGetStartedModal
        onClosed: {
            root.startupStore.beforeGetStartedPopupAccepted()
            btnNewUser.forceActiveFocus()
        }
    }

    Item {
        id: container
        width: 425
        height: 513
        anchors.centerIn: parent

        Image {
            id: keysImg
            width: 230
            height: 230
            anchors.horizontalCenter: parent.horizontalCenter
            fillMode: Image.PreserveAspectFit
            source: Theme.png("onboarding/welcome")
            mipmap: true
            cache: false
        }

        StyledText {
            id: txtTitle1
            text: qsTr("Welcome to Status")
            anchors.topMargin: Theme.bigPadding
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: keysImg.bottom
            font.letterSpacing: -0.2
            font.pixelSize: 22
        }

        StyledText {
            id: txtDesc1
            color: Theme.palette.secondaryText
            text: qsTr("Your fully decentralized gateway to Ethereum and Web3. Crypto wallet, privacy first group chat, and communities.")
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.top: txtTitle1.bottom
            anchors.topMargin: Theme.padding
            font.pixelSize: 15
        }

        StatusButton {
            id: btnNewUser
            objectName: "welcomeViewIAmNewToStatusButton"
            anchors.top: txtDesc1.bottom
            anchors.topMargin: Theme.xlPadding
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("I am new to Status")
            onClicked: {
                d.showMetricsAndRunAction(root.startupStore.doPrimaryAction)
            }
            Keys.onPressed: {
                if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    event.accepted = true
                    d.showMetricsAndRunAction(root.startupStore.doPrimaryAction)
                }
            }
        }

        StatusFlatButton {
            id: btnExistingUser
            text: qsTr("I already use Status")
            anchors.top: btnNewUser.bottom
            anchors.topMargin: Theme.bigPadding
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: {
                d.showMetricsAndRunAction(root.startupStore.doSecondaryAction)
            }
        }
    }
}
