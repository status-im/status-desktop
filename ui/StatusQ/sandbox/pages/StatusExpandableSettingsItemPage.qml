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

    Rectangle {
        width: parent.width
        height: 30
        color: Theme.palette.baseColor2
        StatusBaseText {
            anchors.verticalCenter: parent.verticalCenter
            text: "Type Primary"
            color: Theme.palette.directColor1
        }
    }

    StatusExpandableItem {
        anchors.horizontalCenter: parent.horizontalCenter

        expandable: false
        asset.name: "seed-phrase"
        primaryText: "Back up seed phrase"
        secondaryText: "Back up your seed phrase now to secure this account ajhaDH SDHSAHDLSADBSA,DLISAHDLASD ADASDHASLDHALSDHAS DAS,DASJDGLIASGD"
        button.text: qsTr("Back up seed phrase")
    }

    StatusExpandableItem {
        anchors.horizontalCenter: parent.horizontalCenter

        expandable: true
        asset.name: "secret"
        primaryText: "Account signing phrase"
        secondaryText: "View your signing phrase and ensure that you never get scammed. View your signing phrase and ensure that you never get scammed."
        expandableComponent: notImplemented
    }

    StatusExpandableItem {
        anchors.horizontalCenter: parent.horizontalCenter

        expandable: true
        asset.name: "seed-phrase"
        primaryText: "View private key"
        secondaryText: "Back up your seed phrase now to secure this account"
        expandableComponent: notImplemented
        button.text: "View private key"
        button.icon.name: "tiny/public-chat"
        button.onClicked: {
            // To-do open  enter password Modal
            expanded = !expanded
        }
    }

    Rectangle {
        width: parent.width
        height: 30
        color:  Theme.palette.baseColor2
        StatusBaseText {
            anchors.verticalCenter: parent.verticalCenter
            text: "Type Secondary"
            color: Theme.palette.directColor1
        }
    }

    StatusExpandableItem {
        anchors.horizontalCenter: parent.horizontalCenter

        type: StatusExpandableItem.Type.Secondary
        expandable: true
        asset.isImage: true
        asset.name: "qrc:/demoapp/data/profile-image-1.jpeg"
        primaryText: "CryptoKitties"
        additionalText: "1456 USD"
        expandableComponent: notImplemented
    }

    StatusExpandableItem {
        anchors.horizontalCenter: parent.horizontalCenter

        type: StatusExpandableItem.Type.Secondary
        expandable: true
        asset.isImage: true
        asset.name: "qrc:/demoapp/data/profile-image-1.jpeg"
        primaryText: "Adding Really long text to test scenario of having very long text along with tertiary text"
        additionalText: "564.90 USD"
        expandableComponent: notImplemented
    }

    StatusExpandableItem {
        anchors.horizontalCenter: parent.horizontalCenter

        type: StatusExpandableItem.Type.Secondary
        expandable: true
        primaryText: "CryptoKitties"
        additionalText: "1456 USD"
        expandableComponent: notImplemented
    }

    Rectangle {
        width: parent.width
        height: 30
        color:  Theme.palette.baseColor2
        StatusBaseText {
            anchors.verticalCenter: parent.verticalCenter
            text: "Type Tertiary"
            color: Theme.palette.directColor1
        }
    }

    StatusExpandableItem {
        anchors.horizontalCenter: parent.horizontalCenter

        type: StatusExpandableItem.Type.Tertiary
        expandable: true
        primaryText: "CryptoKitties"
        expandableComponent: notImplemented
    }

    StatusExpandableItem {
        anchors.horizontalCenter: parent.horizontalCenter

        type: StatusExpandableItem.Type.Tertiary
        expandable: true
        primaryText: "Rescue Moon"
        expandableComponent: notImplemented
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
