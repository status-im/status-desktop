import QtQuick 2.3
import "../../../../../shared"
import "../../../../../imports"
import "./TransactionComponents"

Rectangle {
    property string tokenAmount: "100"
    property string token: "SNT"
    property string fiatValue: "10 USD"
    property bool outgoing: true
    property string state: "addressReceived"
    property int timestamp: 1598454756329

    id: root
    width: 170
    height: childrenRect.height
    radius: 16
    color: Style.current.background
    border.color: Style.current.border
    border.width: 1

    StyledText {
        id: title
        color: Style.current.secondaryText
        text: outgoing ? qsTr("↑ Outgoing transaction") : qsTr("↓ Incoming transaction")
        font.weight: Font.Medium
        anchors.top: parent.top
        anchors.topMargin: Style.current.halfPadding
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: 13
    }

    Item {
        id: valueContainer
        height: tokenText.height + fiatText.height
        anchors.top: title.bottom
        anchors.topMargin: 4
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.left: parent.left
        anchors.leftMargin: 12

        Image {
            id: tokenImage
            source: `../../../../img/tokens/${root.token}.png`
            width: 24
            height: 24
            anchors.verticalCenter: parent.verticalCenter
        }

        StyledText {
            id: tokenText
            color: Style.current.text
            text: `${root.tokenAmount} ${root.token}`
            anchors.left: tokenImage.right
            anchors.leftMargin: Style.current.halfPadding
            font.pixelSize: 22
        }

        StyledText {
            id: fiatText
            color: Style.current.secondaryText
            text: root.fiatValue
            anchors.top: tokenText.bottom
            anchors.left: tokenText.left
            font.pixelSize: 13
        }
    }

    Loader {
        id: bubbleLoader
        active: root.state !== Constants.addressRequested || !outgoing
        sourceComponent: stateBubbleComponent
        anchors.top: valueContainer.bottom
        anchors.topMargin: Style.current.halfPadding
        width: parent.width
        height: item.height + 12
    }

    Component {
        id: stateBubbleComponent

        StateBubble {
            state: root.state
        }
    }

    Loader {
        id: buttonsLoader
        active: (root.state === Constants.addressRequested && !root.outgoing) ||
                (root.state === Constants.addressReceived && root.outgoing)
        sourceComponent: root.outgoing ? signAndSendComponent : acceptTransactionComponent
        anchors.top: bubbleLoader.active ? bubbleLoader.bottom : valueContainer.bottom
        anchors.topMargin: bubbleLoader.active ? 0 : Style.current.halfPadding
        width: parent.width
        height: item.height
    }

    Component {
        id: acceptTransactionComponent

        AcceptTransaction {}
    }

    Component {
        id: signAndSendComponent

        SendTransactionButton {}
    }

    StyledText {
        id: timeText
        color: Style.current.secondaryText
        text: Utils.formatTime(root.timestamp)
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 9
        anchors.right: parent.right
        anchors.rightMargin: 12
        font.pixelSize: 10
    }

}

/*##^##
Designer {
    D{i:0;formeditorColor:"#4c4e50";formeditorZoom:1.25}
}
##^##*/
