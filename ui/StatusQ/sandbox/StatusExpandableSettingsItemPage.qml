import QtQuick 2.14
import QtQuick.Layouts 1.14
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

Column {
    spacing: 12
    width: 800
    anchors.top:parent.top
    leftPadding: 20
    rightPadding: 20

    StatusExpandableSettingsItem {
        anchors.horizontalCenter: parent.horizontalCenter

        expandable: false
        icon.name: "seed-phrase"
        primaryText: qsTr("Back up seed phrase")
        secondaryText: qsTr("Back up your seed phrase now to secure this account ajhaDH SDHSAHDLSADBSA,DLISAHDLASD ADASDHASLDHALSDHAS DAS,DASJDGLIASGD")
        button.text: qsTr("Back up seed phrase")
    }

    StatusExpandableSettingsItem {
        anchors.horizontalCenter: parent.horizontalCenter

        expandable: true
        icon.name: "secret"
        primaryText: qsTr("Account signing phrase")
        secondaryText: qsTr("View your signing phrase and ensure that you never get scammed")
        expandableComponent: notImplemented
    }

    StatusExpandableSettingsItem {
        anchors.horizontalCenter: parent.horizontalCenter

        expandable: true
        icon.name: "seed-phrase"
        primaryText: qsTr("View private key")
        secondaryText: qsTr("Back up your seed phrase now to secure this account")
        expandableComponent: notImplemented
        button.text: qsTr("View private key")
        button.icon.name: "tiny/public-chat"
        button.onClicked: {
            // To-do open  enter password Modal
            expanded = !expanded
        }
    }

    Component {
        id: notImplemented
        Rectangle {
            anchors.centerIn: parent
            width: 654
            height: infoText.implicitHeight
            color: Theme.palette.baseColor5
            StatusBaseText {
                id: infoText
                anchors.centerIn: parent
                color: Theme.palette.directColor4
                font.pixelSize: 15
                lineHeight: 22
                lineHeightMode: Text.FixedHeight
                font.weight: Font.Medium
                text: qsTr("Not Implemented")
            }
        }
    }
}
