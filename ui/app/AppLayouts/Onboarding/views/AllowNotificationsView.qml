import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import shared 1.0
import shared.panels 1.0

import utils 1.0

import "../stores"

Item {
    id: root

    property StartupStore startupStore

    Component.onCompleted: {
        btnOk.forceActiveFocus()
    }

    QtObject {
        id: d
        readonly property int titlePixelSize: 22
        readonly property real titleLetterSpacing: -0.2
        readonly property int okButtonTopMargin: 40
    }

    Image {
        id: notificationImg
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: txtTitle.top
        anchors.bottomMargin: Theme.padding
        fillMode: Image.PreserveAspectFit
        source: Theme.png("onboarding/notifications@2x")
        cache: false
    }

    StyledText {
        id: txtTitle
        text: qsTr("Allow notifications")
        font.bold: true
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        font.letterSpacing: d.titleLetterSpacing
        font.pixelSize: d.titlePixelSize
        lineHeight: 1.2
    }

    StyledText {
        id: txtDesc
        color: Theme.palette.secondaryText
        text: qsTr("Status will notify you about new messages. You can\nedit your notification preferences later in settings.")
        horizontalAlignment: Text.AlignHCenter
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: txtTitle.bottom
        anchors.topMargin: Theme.padding
        font.pixelSize: Theme.primaryTextFontSize
        lineHeight: 1.2
    }

    StatusButton {
        id: btnOk
        objectName: "allowNotificationsOnboardingOkButton"
        anchors.top: txtDesc.bottom
        anchors.topMargin: d.okButtonTopMargin
        anchors.horizontalCenter: parent.horizontalCenter
        leftPadding: Theme.padding
        rightPadding: Theme.padding
        font.weight: Font.Medium
        text: qsTr("Start using Status")
        onClicked: {
            root.startupStore.doPrimaryAction()
        }
        Keys.onPressed: {
            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                event.accepted = true
                root.startupStore.doPrimaryAction()
            }
        }
    }
}
