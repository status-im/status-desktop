import QtQuick 2.14
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import utils 1.0
import shared.controls 1.0

Item {
    id: root

    signal startBtnClicked()

    property string username: ""
    property int profileContentWidth
    property bool startButtonEnabled: true
    property string tooltipText

    StatusScrollView {
        id: sview
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        anchors.top: parent.top
        anchors.bottom: startBtn.top
        anchors.bottomMargin: Style.current.padding
        anchors.left: parent.left
        anchors.right: parent.right

        contentWidth: availableWidth

        Item {
            id: contentItem
            width: sview.availableWidth
            height: childrenRect.height

            Image {
                id: image
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                fillMode: Image.PreserveAspectFit
                source: Style.png("ens/ens-header-" + Style.current.name + "@2x")
                cache: false
            }

            StatusBaseText {
                id: title
                text: qsTr("Get a universal username")
                anchors.top: image.bottom
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
                text: qsTr("ENS names transform those crazy-long addresses into unique usernames.")
                anchors.top: title.bottom
                anchors.topMargin: 24
                font.pixelSize: 14
                anchors.left: parent.left
                anchors.right: parent.right
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                color: Theme.palette.directColor1
            }

            StatusBaseText {
                id: element1Number
                text: "1"
                anchors.left: parent.left
                anchors.leftMargin: 24
                anchors.top: subtitle.bottom
                anchors.topMargin: 24
                font.weight: Font.Bold
                font.pixelSize: 14
                color: Theme.palette.directColor1
            }

            StatusBaseText {
                id: element1Title
                text: qsTr("Customize your chat name")
                anchors.left: element1Number.right
                anchors.leftMargin: 24
                anchors.top: subtitle.bottom
                anchors.topMargin: 24
                anchors.right: parent.right
                wrapMode: Text.WordWrap
                font.weight: Font.Bold
                font.pixelSize: 14
                color: Theme.palette.directColor1
            }

            StatusBaseText {
                id: element1Subtitle
                text: qsTr("An ENS name can replace your random 3-word name in chat. Be @yourname instead of %1.").arg(root.username)
                anchors.left: element1Number.right
                anchors.leftMargin: 24
                anchors.top: element1Title.bottom
                anchors.topMargin: 24
                anchors.right: parent.right
                wrapMode: Text.WordWrap
                font.pixelSize: 14
                color: Theme.palette.directColor1
            }

            StatusBaseText {
                id: element2Number
                text: "2"
                anchors.left: parent.left
                anchors.leftMargin: 24
                anchors.top: element1Subtitle.bottom
                anchors.topMargin: 24
                font.weight: Font.Bold
                font.pixelSize: 14
                color: Theme.palette.directColor1
            }

            StatusBaseText {
                id: element2Title
                text: qsTr("Simplify your ETH address")
                anchors.left: element2Number.right
                anchors.leftMargin: 24
                anchors.top: element1Subtitle.bottom
                anchors.topMargin: 24
                anchors.right: parent.right
                wrapMode: Text.WordWrap
                font.weight: Font.Bold
                font.pixelSize: 14
                color: Theme.palette.directColor1
            }

            StatusBaseText {
                id: element2Subtitle
                text: qsTr("You can receive funds to your easy-to-share ENS name rather than your hexadecimal hash (0x...).")
                anchors.left: element2Number.right
                anchors.leftMargin: 24
                anchors.top: element2Title.bottom
                anchors.topMargin: 24
                anchors.right: parent.right
                wrapMode: Text.WordWrap
                font.pixelSize: 14
                color: Theme.palette.directColor1
            }

            StatusBaseText {
                id: element3Number
                text: "3"
                anchors.left: parent.left
                anchors.leftMargin: 24
                anchors.top: element2Subtitle.bottom
                anchors.topMargin: 24
                font.weight: Font.Bold
                font.pixelSize: 14
                color: Theme.palette.directColor1
            }

            StatusBaseText {
                id: element3Title
                text: qsTr("Receive transactions in chat")
                anchors.left: element3Number.right
                anchors.leftMargin: 24
                anchors.top: element2Subtitle.bottom
                anchors.topMargin: 24
                anchors.right: parent.right
                wrapMode: Text.WordWrap
                font.weight: Font.Bold
                font.pixelSize: 14
                color: Theme.palette.directColor1
            }

            StatusBaseText {
                id: element3Subtitle
                text: qsTr("Others can send you funds via chat in one simple step.")
                anchors.left: element3Number.right
                anchors.leftMargin: 24
                anchors.top: element3Title.bottom
                anchors.right: parent.right
                wrapMode: Text.WordWrap
                anchors.topMargin: 24
                font.pixelSize: 14
                color: Theme.palette.directColor1
            }

            StatusBaseText {
                id: element4Number
                text: "4"
                anchors.left: parent.left
                anchors.leftMargin: 24
                anchors.top: element3Subtitle.bottom
                anchors.topMargin: 24
                font.weight: Font.Bold
                font.pixelSize: 14
                color: Theme.palette.directColor1
            }

            StatusBaseText {
                id: element4Title
                text: qsTr("10 SNT to register")
                anchors.left: element4Number.right
                anchors.leftMargin: 24
                anchors.top: element3Subtitle.bottom
                anchors.topMargin: 24
                anchors.right: parent.right
                wrapMode: Text.WordWrap
                font.weight: Font.Bold
                font.pixelSize: 14
                color: Theme.palette.directColor1
            }

            StatusBaseText {
                id: element4Subtitle
                text: qsTr("Register once to keep the name forever. After 1 year you can release the name and get your SNT back.")
                anchors.left: element4Number.right
                anchors.leftMargin: 24
                anchors.top: element4Title.bottom
                anchors.topMargin: 24
                anchors.right: parent.right
                wrapMode: Text.WordWrap
                font.pixelSize: 14
                color: Theme.palette.directColor1
            }


            StatusBaseText {
                id: element5Number
                text: "@"
                anchors.left: parent.left
                anchors.leftMargin: 24
                anchors.top: element4Subtitle.bottom
                anchors.topMargin: 24
                font.weight: Font.Bold
                font.pixelSize: 14
                color: Theme.palette.directColor1
            }

            StatusBaseText {
                id: element5Title
                text: qsTr("Already own a username?")
                anchors.left: element5Number.right
                anchors.leftMargin: 24
                anchors.top: element4Subtitle.bottom
                anchors.topMargin: 24
                anchors.right: parent.right
                wrapMode: Text.WordWrap
                font.weight: Font.Bold
                font.pixelSize: 14
                color: Theme.palette.directColor1
            }

            StatusBaseText {
                id: element5Subtitle
                text: qsTr("You can verify and add any usernames you own in the next steps.")
                anchors.left: element5Number.right
                anchors.leftMargin: 24
                anchors.top: element5Title.bottom
                anchors.topMargin: 24
                anchors.right: parent.right
                wrapMode: Text.WordWrap
                font.pixelSize: 14
                color: Theme.palette.directColor1
            }

            StatusBaseText {
                id: poweredBy
                text: qsTr("Powered by Ethereum Name Services")
                anchors.left: element5Number.right
                anchors.leftMargin: 24
                anchors.top: element5Subtitle.bottom
                anchors.topMargin: 40
                anchors.right: parent.right
                wrapMode: Text.WordWrap
                font.pixelSize: 11
                color: Theme.palette.directColor1
            }
        }
    }

    DisabledTooltipButton {
        id: startBtn
        interactive: startButtonEnabled
        buttonType: DisabledTooltipButton.Normal
        aliasedObjectName: "ensStartButton"
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Style.current.padding
        anchors.horizontalCenter: parent.horizontalCenter
        text: qsTr("Start")
        tooltipText: root.tooltipText
        onClicked: startBtnClicked()
    }
}

