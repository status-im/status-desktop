import QtQuick 2.14
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.14

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

Item {
    property string ensUsername: ""
    signal okBtnClicked()

    StatusBaseText {
        id: sectionTitle
        //% "ENS usernames"
        text: qsTrId("ens-usernames")
        anchors.left: parent.left
        anchors.leftMargin: 24
        anchors.top: parent.top
        anchors.topMargin: 24
        font.weight: Font.Bold
        font.pixelSize: 20
        color: Theme.palette.directColor1
    }


    // TODO: replace with StatusQ component
    Rectangle {
        id: circle
        anchors.top: sectionTitle.bottom
        anchors.topMargin: 24
        anchors.horizontalCenter: parent.horizontalCenter
        width: 60
        height: 60
        radius: 120
        color: Theme.palette.primaryColor1

        StatusBaseText {
            text: "✓"
            opacity: 0.7
            font.weight: Font.Bold
            font.pixelSize: 18
            color: Theme.palette.indirectColor1
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    StatusBaseText {
        id: title
        //% "Username added"
        text: qsTrId("ens-saved-title")
        anchors.top: circle.bottom
        anchors.topMargin: 24
        font.weight: Font.Bold
        font.pixelSize: 24
        anchors.left: parent.left
        anchors.right: parent.right
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        color: Theme.palette.directColor1
    }

    StatusBaseText {
        id: subtitle
        //% "%1 is now connected with your chat key and can be used in Status."
        text: qsTrId("-1-is-now-connected-with-your-chat-key-and-can-be-used-in-status-").arg(ensUsername)
        anchors.top: title.bottom
        anchors.topMargin: 24
        font.pixelSize: 14
        anchors.left: parent.left
        anchors.right: parent.right
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        color: Theme.palette.directColor1
    }

    StatusButton {
        id: startBtn
        anchors.top: subtitle.bottom
        anchors.topMargin: Style.current.padding
        anchors.horizontalCenter: parent.horizontalCenter
        //% "Ok, got it"
        text: qsTrId("ens-got-it")
        onClicked: okBtnClicked()
    }
}
