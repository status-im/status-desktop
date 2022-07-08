import QtQuick 2.13

import utils 1.0
import shared 1.0
import shared.panels 1.0
import shared.stores 1.0


Rectangle {
    id: transactionListItem

    property var tokens
    property string currentAccountAddress: ""
    property string ethValue: ""
    property bool isHovered: false
    property string symbol: ""
    property string locale: ""
    property bool isIncoming: to === currentAccountAddress

    signal launchTransactionModal()

    anchors.right: parent.right
    anchors.left: parent.left
    height: 64
    color: isHovered ? Style.current.secondaryBackground : Style.current.transparent
    radius: 8

    Component.onCompleted: {
        const count = transactionListItem.tokens.length
        for (var i = 0; i < count; i++) {
            let token = transactionListItem.tokens[i]
            if (token.address === contract) {
                transactionListItem.symbol = token.symbol
                break
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: launchTransactionModal()
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onEntered: {
            transactionListItem.isHovered = true
        }
        onExited: {
            transactionListItem.isHovered = false
        }
    }

    Row {
        anchors.left: parent.left
        anchors.leftMargin: Style.current.smallPadding
        anchors.verticalCenter: parent.verticalCenter
        spacing: 5

        Image {
            id: assetIcon
            width: 40
            height: 40
            source: Style.png("tokens/"
                    + (transactionListItem.symbol
                       != "" ? transactionListItem.symbol : "ETH"))
            anchors.verticalCenter: parent.verticalCenter
            onStatusChanged: {
                if (assetIcon.status == Image.Error) {
                    assetIcon.source = Style.png("tokens/DEFAULT-TOKEN@3x")
                }
            }

            anchors.leftMargin: Style.current.padding
        }

        StyledText {
            id: transferIcon
            anchors.verticalCenter: parent.verticalCenter
            height: 15
            width: 15
            color: isIncoming ? Style.current.success : Style.current.danger
            text: isIncoming ? "↓" : "↑"
        }

        StyledText {
            id: transactionValue
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: Style.current.primaryTextFontSize
            text: ethValue + " " + transactionListItem.symbol
        }
    }

    Row {
        anchors.right: timeInfo.left
        anchors.rightMargin: Style.current.smallPadding
        anchors.top: parent.top
        anchors.topMargin: Style.current.bigPadding
        spacing: 5

        StyledText {
            text: isIncoming ?
                    qsTr("From ") :
                    qsTr("To ")
            color: Style.current.secondaryText
            font.pixelSize: Style.current.primaryTextFontSize
            font.strikeout: false
        }

        Address {
            id: addressValue
            text: isIncoming ? from : to
            maxWidth: 120
            width: 120
            horizontalAlignment: Text.AlignRight
            font.pixelSize: Style.current.primaryTextFontSize
            color: Style.current.textColor
        }
    }

    Row {
        id: timeInfo
        anchors.right: parent.right
        anchors.rightMargin: Style.current.smallPadding
        anchors.top: parent.top
        anchors.topMargin: Style.current.bigPadding
        spacing: 5

        StyledText {
            text: " • "
            font.weight: Font.Bold
            color: Style.current.secondaryText
            font.pixelSize: Style.current.primaryTextFontSize
        }

        StyledText {
            id: timeIndicator
            text: qsTr("At ")
            color: Style.current.secondaryText
            font.pixelSize: Style.current.primaryTextFontSize
            font.strikeout: false
        }
        StyledText {
            id: timeValue
            text: Utils.formatLongDateTime(parseInt(timestamp) * 1000, RootStore.accountSensitiveSettings.isDDMMYYDateFormat, RootStore.accountSensitiveSettings.is24hTimeFormat)
            font.pixelSize: Style.current.primaryTextFontSize
            anchors.rightMargin: Style.current.smallPadding
        }
    }
}
