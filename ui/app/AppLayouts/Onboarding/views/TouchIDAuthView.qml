import QtQuick 2.13
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import shared.panels 1.0

import utils 1.0

import "../controls"
import "../panels"
import "../stores"

OnboardingBasePage {
    id: root

    property string userPass

    signal genKeysDone()

    backButtonVisible: false

    Item {
        id: container
        enabled: !dimBackground.active
        anchors.centerIn: parent
        width: 425
        height: {
            let h = 0
            const children = this.children
            Object.keys(children).forEach(function (key) {
                const child = children[key]
                h += child.height + Style.current.padding
            })
            return h
        }
        Image {
            id: keysImg
            width: 188
            height: 185
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            fillMode: Image.PreserveAspectFit
            antialiasing: true
            source: Style.png("onboarding/fingerprint@2x")
            mipmap: true
        }

        StyledText {
            id: txtTitle
            text: qsTr("Biometrics")
            anchors.topMargin: Style.current.padding
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: keysImg.bottom
            font.letterSpacing: -0.2
            font.pixelSize: 22
        }

        StyledText {
            id: txtDesc
            width: 426
            anchors.top: txtTitle.bottom
            anchors.topMargin: Style.current.padding
            color: Style.current.secondaryText
            text: qsTr("Would you like to use your Touch ID to login to Status?")
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            font.pixelSize: 15
        }
        ColumnLayout {
            anchors.topMargin: 40
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: txtDesc.bottom
            spacing: Style.current.bigPadding
            StatusButton {
                id: button
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("Yes, use Touch ID")
                onClicked: {
                    OnboardingStore.accountSettings.storeToKeychainValue = Constants.storeToKeychainValueStore;
                    dimBackground.active = true;
                    OnboardingStore.storeToKeyChain(userPass);
                }
            }
            StatusBaseText {
                id: keycardLink
                Layout.alignment: Qt.AlignHCenter
                color: Theme.palette.primaryColor1
                text: qsTr("I prefer to use my password")
                font.pixelSize: 15
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onEntered: {
                        parent.font.underline = true
                    }
                    onExited: {
                        parent.font.underline = false
                    }
                    onClicked: {
                        OnboardingStore.accountSettings.storeToKeychainValue = Constants.storeToKeychainValueNever;
                        root.genKeysDone();
                    }
                }
            }
        }
    }

    Loader {
        id: dimBackground
        anchors.fill: parent
        active: false
        sourceComponent: Rectangle {
            color: Qt.rgba(0, 0, 0, 0.4)
        }
    }

    Connections {
        enabled: !!OnboardingStore.mainModuleInst
        target: OnboardingStore.mainModuleInst
        onStoringPasswordSuccess: {
            dimBackground.active = false;
            root.genKeysDone();
        }
        onStoringPasswordError: {
            dimBackground.active = false;
        }
    }
}
