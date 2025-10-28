import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import utils

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls
import StatusQ.Components

Item {
    property string ensUsername: ""
    signal okBtnClicked()

    StatusBaseText {
        id: sectionTitle
        text: qsTr("ENS usernames")
        anchors.left: parent.left
        anchors.leftMargin: Theme.bigPadding
        anchors.top: parent.top
        anchors.topMargin: Theme.bigPadding
        font.weight: Font.Bold
        font.pixelSize: Theme.fontSize20
        color: Theme.palette.directColor1
    }


    // TODO: replace with StatusQ component
    Rectangle {
        id: circle
        anchors.top: sectionTitle.bottom
        anchors.topMargin: Theme.bigPadding
        anchors.horizontalCenter: parent.horizontalCenter
        width: 60
        height: 60
        radius: 120
        color: Theme.palette.primaryColor1

        StatusBaseText {
            text: "✓"
            opacity: 0.7
            font.weight: Font.Bold
            font.pixelSize: Theme.fontSize18
            color: Theme.palette.indirectColor1
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    StatusBaseText {
        id: title
        text: qsTr("Username removed")
        anchors.top: circle.bottom
        anchors.topMargin: Theme.bigPadding
        font.weight: Font.Bold
        font.pixelSize: Theme.fontSize24
        anchors.left: parent.left
        anchors.right: parent.right
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        color: Theme.palette.directColor1
    }

    StatusBaseText {
        id: subtitle
        text: qsTr("The username %1 will be removed and your deposit will be returned once the transaction is mined").arg(ensUsername)
        anchors.top: title.bottom
        anchors.topMargin: 24
        font.pixelSize: Theme.secondaryTextFontSize
        anchors.left: parent.left
        anchors.right: parent.right
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        color: Theme.palette.directColor1
    }

    StatusBaseText {
        id: progress
        text: qsTr("You can follow the progress in the Transaction History section of your wallet.")
        anchors.top: subtitle.bottom
        anchors.topMargin: 24
        font.pixelSize: Theme.tertiaryTextFontSize
        anchors.left: parent.left
        anchors.right: parent.right
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        color: Theme.palette.baseColor1

    }

    StatusButton {
        id: startBtn
        anchors.top: progress.bottom
        anchors.topMargin: Theme.padding
        anchors.horizontalCenter: parent.horizontalCenter
        text: qsTr("Ok, got it")
        onClicked: okBtnClicked()
    }
}
