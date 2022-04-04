import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Controls.Universal 2.12

import StatusQ.Controls 0.1

import shared 1.0
import shared.panels 1.0
import "../popups"
import "../stores"

import utils 1.0

Page {
    id: page

    signal btnNewUserClicked()
    signal btnExistingUserClicked()

    background: Rectangle {
        color: Style.current.background
    }

    Component.onCompleted: {
        if (OnboardingStore.showBeforeGetStartedPopup) {
            beforeGetStartedModal.open();
        }
    }

    BeforeGetStartedModal {
        id: beforeGetStartedModal
        onClosed: {
            OnboardingStore.showBeforeGetStartedPopup = false;
        }
    }

    Item {
        id: container
        width: 425
        height: 513
        anchors.centerIn: parent

        Image {
            id: keysImg
            width: 256
            height: 256
            anchors.horizontalCenter: parent.horizontalCenter
            fillMode: Image.PreserveAspectFit
            source: Style.png("onboarding/welcome")
            mipmap: true
        }

        StyledText {
            id: txtTitle1
            text: qsTr("Welcome to Status")
            anchors.topMargin: Style.current.padding
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: keysImg.bottom
            font.letterSpacing: -0.2
            font.pixelSize: 22
        }

        StyledText {
            id: txtDesc1
            color: Style.current.secondaryText
            text: qsTr("Your fully decentralized gateway to Ethereum and Web3. Crypto wallet, privacy first group chat, and dApp browser.")
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            anchors.right: parent.right
            anchors.left: parent.left
            anchors.top: txtTitle1.bottom
            anchors.topMargin: Style.current.padding
            font.pixelSize: 15
        }

        StatusButton {
            id: btnNewUser
            anchors.top: txtDesc1.bottom
            anchors.topMargin: 40
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("I am new to Status")
            onClicked: {
                page.btnNewUserClicked();
            }
        }

        StatusFlatButton {
            id: btnExistingUser
            text: qsTr("I already use Status")
            anchors.top: btnNewUser.bottom
            anchors.topMargin: Style.current.padding
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: {
                page.btnExistingUserClicked();
            }
        }
    }
}
