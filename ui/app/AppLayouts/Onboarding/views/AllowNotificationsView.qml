import QtQuick 2.13
import QtQuick.Controls 2.13

import StatusQ.Controls 0.1

import shared 1.0
import shared.panels 1.0

import utils 1.0

import "../controls"

OnboardingBasePage {
    id: page

    signal btnOkClicked()

    backButtonVisible: false

    QtObject {
        id: d
        readonly property int titlePixelSize: Style.dp(22)
        readonly property real titleLetterSpacing: -Style.dp(0.2)
        readonly property int okButtonTopMargin: Style.dp(40)
    }

    Image {
        id: notificationImg
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: txtTitle.top
        anchors.bottomMargin: Style.current.padding
        fillMode: Image.PreserveAspectFit
        source: Style.png("onboarding/notifications@2x")
    }

    StyledText {
        id: txtTitle
        text: qsTr("Allow notifications")
        font.bold: true
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        font.letterSpacing: d.titleLetterSpacing
        font.pixelSize: d.titlePixelSize
    }

    StyledText {
        id: txtDesc
        color: Style.current.secondaryText
        text: qsTr("Status will notify you about new messages. You can\nedit your notification preferences later in settings.")
        horizontalAlignment: Text.AlignHCenter
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: txtTitle.bottom
        anchors.topMargin: Style.current.padding
        font.pixelSize: Style.current.primaryTextFontSize
    }

    StatusButton {
        id: btnOk
        anchors.top: txtDesc.bottom
        anchors.topMargin: d.okButtonTopMargin
        anchors.horizontalCenter: parent.horizontalCenter
        text: qsTr("Ok, got it")
        onClicked: {
            page.btnOkClicked();
        }
    }
}
