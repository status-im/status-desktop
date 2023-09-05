import QtQuick 2.3

import StatusQ.Core 0.1

import utils 1.0
import shared 1.0
import shared.panels 1.0
import shared.popups 1.0
import shared.views.chat 1.0
import shared.controls.chat 1.0
import shared.controls 1.0
import shared.stores 1.0

Item {
    id: root
    width: rectangleBubble.width
    height: rectangleBubble.height

    property var store              // expected ui/app/AppLayouts/Chat/stores/RootStore.qml
    property var contactsStore

    property var transactionParams

    property var transactionParamsObject: {
        try {
            return JSON.parse(transactionParams)
        } catch (e) {
            console.error('Error parsing command parameters')
            console.error('JSON:', transactionParams)
            console.error('Error:', e)
            return {
                id: "",
                fromAddress: "",
                address: "",
                contract: "",
                value: "",
                transactionHash: "",
                commandState: 1,
                signature: null
            }
        }
    }

    property var token:{
        try {
            return JSON.parse(transactionParamsObject.contract)
        } catch (e) {
            console.error('Error parsing command parameters')
            console.error('JSON:', transactionParamsObject.contract)
            console.error('Error:', e)
            return ""
        }
    }

    property var selectedRecipient: {
        return {
            address: transactionParamsObject.address,
            name: senderDisplayName,
            type: RecipientSelector.Type.Contact,
            alias: senderDisplayName
        }
    }

    property string tokenAmount: transactionParamsObject.value
    property string tokenSymbol: token.symbol || ""
    property string fiatValue: {
        if (!tokenAmount || !token.symbol) {
            return "0"
        }
        var defaultFiatSymbol = root.store.currentCurrency
        return root.store.getFiatValue(tokenAmount, token.symbol, defaultFiatSymbol) + " " + defaultFiatSymbol
    }
    property int state: transactionParamsObject.commandState

    // Any transaction where isCurrentUser is true is actually outgoing transaction.
    property bool outgoing: isCurrentUser

    property int innerMargin: 12
    property bool isError: transactionParamsObject.contract === "{}"
    onTokenSymbolChanged: {
        if (!!tokenSymbol) {
            tokenImage.source = Style.png("tokens/"+root.tokenSymbol)
        }
    }

    Rectangle {
        id: rectangleBubble
        width: (bubbleLoader.active ? bubbleLoader.width : valueContainer.width)
               + timeText.width + 3 * root.innerMargin
        height: childrenRect.height + root.innerMargin
        radius: 16
        color: Style.current.background
        border.color: Style.current.border
        border.width: 1

        StyledText {
            id: title
            color: Style.current.secondaryText
            text: {
                if (root.state === Constants.transactionRequested) {
                    let prefix = outgoing? "↑ " : "↓ "
                    return prefix + qsTr("Transaction request")
                }

                return outgoing ?
                    qsTr("↑ Outgoing transaction") :
                    qsTr("↓ Incoming transaction")
            }
            font.weight: Font.Medium
            anchors.top: parent.top
            anchors.topMargin: Style.current.halfPadding
            anchors.left: parent.left
            anchors.leftMargin: root.innerMargin
            font.pixelSize: 13
        }

        Item {
            id: valueContainer
            width: childrenRect.width
            height: tokenText.height + fiatText.height
            anchors.top: title.bottom
            anchors.topMargin: 4
            anchors.left: parent.left
            anchors.leftMargin: root.innerMargin

            StyledText {
                id: txtError
                color: Style.current.danger
                visible: root.isError
                text: qsTr("Token not found on your current network")
            }

            Image {
                id: tokenImage
                visible: !root.isError
                width: 24
                height: 24
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                id: tokenText
                visible: !root.isError
                color: Style.current.textColor
                text: `${root.tokenAmount} ${root.tokenSymbol}`
                anchors.left: tokenImage.right
                anchors.leftMargin: Style.current.halfPadding
                font.pixelSize: 22
            }

            StyledText {
                id: fiatText
                visible: !root.isError
                color: Style.current.secondaryText
                text: root.fiatValue
                anchors.top: tokenText.bottom
                anchors.left: tokenText.left
                font.pixelSize: 13
            }
        }

        Loader {
            id: bubbleLoader
            active: {
                return !root.isError && (
                    isCurrentUser ||
                    (!isCurrentUser &&
                        !(root.state === Constants.addressRequested ||
                        root.state === Constants.transactionRequested)
                    )
                )
            }
            sourceComponent: stateBubbleComponent
            anchors.top: valueContainer.bottom
            anchors.topMargin: Style.current.halfPadding
            anchors.left: parent.left
            anchors.leftMargin: root.innerMargin
        }

        Component {
            id: stateBubbleComponent

            StateBubble {
                state: root.state
                outgoing: root.outgoing
            }
        }

        Loader {
            id: buttonsLoader
            active: !root.isError && (
                    (root.state === Constants.addressRequested && !root.outgoing) ||
                    (root.state === Constants.addressReceived && root.outgoing) ||
                    (root.state === Constants.transactionRequested && !root.outgoing)
            )
            sourceComponent: root.outgoing ? signAndSendComponent : acceptTransactionComponent
            anchors.top: bubbleLoader.active ? bubbleLoader.bottom : valueContainer.bottom
            anchors.topMargin: bubbleLoader.active ? root.innerMargin : 20
            width: parent.width
        }

        Component {
            id: acceptTransactionComponent

            AcceptTransactionView {
                state: root.state
                store: root.store
                contactsStore: root.contactsStore
                token: root.token
                fiatValue: root.fiatValue
                tokenAmount: root.tokenAmount
                selectedRecipient: root.selectedRecipient
            }
        }

        Component {
            id: signAndSendComponent

            SendTransactionButton {
                selectedAsset: token
                selectedAmount: tokenAmount
                selectedFiatAmount: fiatValue
                fromAddress: transactionParamsObject.fromAddress
                selectedRecipient: root.selectedRecipient
                onSendTransaction: {
                    // TODO: https://github.com/status-im/status-desktop/issues/6778
                    console.log("not implemented")
                }
            }
        }

        StyledText {
            id: timeText
            color: Style.current.secondaryText
            text: LocaleUtils.formatTime(messageTimestamp, Locale.ShortFormat)
            anchors.left: bubbleLoader.active ? bubbleLoader.right : undefined
            anchors.leftMargin: bubbleLoader.active ? 13 : 0
            anchors.right: bubbleLoader.active ? undefined : parent.right
            anchors.rightMargin: bubbleLoader.active ? 0 : root.innerMargin
            anchors.bottom: bubbleLoader.active ? bubbleLoader.bottom : buttonsLoader.top
            anchors.bottomMargin: bubbleLoader.active ? -root.innerMargin : 7
            font.pixelSize: 10
        }
    }
}
