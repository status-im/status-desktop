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

Item {
    id: root

    property StartupStore startupStore

    Component.onCompleted: {
        button.forceActiveFocus()
    }

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
            cache: false
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
            text: root.startupStore.currentStartupState.flowType === Constants.startupFlow.firstRunNewUserNewKeycardKeys ||
                  root.startupStore.currentStartupState.flowType === Constants.startupFlow.firstRunNewUserImportSeedPhraseIntoKeycard ||
                  root.startupStore.currentStartupState.flowType === Constants.startupFlow.firstRunOldUserKeycardImport?
                      qsTr("Would you like to use TouchID instead of a PIN code\nto login to Status using your Keycard?") :
                      qsTr("Would you like to use Touch ID\nto login to Status?")
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
                objectName: "touchIdYesUseTouchIDButton"
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("Yes, use Touch ID")
                onClicked: {
                    dimBackground.active = true
                    root.startupStore.doPrimaryAction()
                }
                Keys.onPressed: {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        event.accepted = true
                        root.startupStore.doPrimaryAction()
                    }
                }
            }
            StatusBaseText {
                id: keycardLink
                objectName: "touchIdIPreferToUseMyPasswordText"
                Layout.alignment: Qt.AlignHCenter
                color: Theme.palette.primaryColor1
                text: root.startupStore.currentStartupState.flowType === Constants.startupFlow.firstRunNewUserNewKeycardKeys ||
                      root.startupStore.currentStartupState.flowType === Constants.startupFlow.firstRunNewUserImportSeedPhraseIntoKeycard ||
                      root.startupStore.currentStartupState.flowType === Constants.startupFlow.firstRunOldUserKeycardImport?
                          qsTr("I prefer to use my PIN") :
                          qsTr("I prefer to use my password")
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
                        root.startupStore.doSecondaryAction()
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
}
