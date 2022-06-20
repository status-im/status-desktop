import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13

import StatusQ.Controls 0.1 as StatusQ
import StatusQ.Components 0.1

import utils 1.0

import "../status"
import "../panels"
import "../controls"
import "../popups"
import shared.controls.chat 1.0


Item {
    id: root
    property var fromAccount
    property var toAccount
    property var asset
    property var amount
    property string trxData: ""
    property string currency: "USD"
    property var gas
    height: content.height
    signal fromClicked
    signal gasClicked
    // Creates a mouse area around the "from account". When clicked, triggers
    // the "fromClicked" signal
    property bool isFromEditable: false
    // Creates a mouse area around the "network fee". When clicked, triggers
    // the "gasClicked" signal
    property bool isGasEditable: false
    property bool isValid: toValid && fromValid && gasValid
    property bool fromValid: true
    property bool toValid: true
    property bool toWarn: false
    property bool gasValid: true

    Column {
        id: content
        anchors.left: parent.left
        anchors.right: parent.right
        LabelValueRow {
            id: itmFrom
            //% "From"
            label: qsTrId("from")
            value: Item {
                id: itmFromValue
                anchors.fill: parent
                anchors.verticalCenter: parent.verticalCenter
                function needsRightPadding() {
                    return !root.fromValid || root.isFromEditable
                }
                Row {
                    spacing: Style.current.halfPadding
                    rightPadding: itmFromValue.needsRightPadding() ? Style.current.halfPadding : 0
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter

                    StyledText {
                        font.pixelSize: Style.current.primaryTextFontSize
                        height: Style.dp(22)
                        text: root.fromAccount ? root.fromAccount.name : ""
                        elide: Text.ElideRight
                        anchors.verticalCenter: parent.verticalCenter
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                    }
                    SVGImage {
                        id: imgFromWallet
                        sourceSize.height: Style.dp(18)
                        sourceSize.width: Style.dp(18)
                        visible: !!root.fromAccount ? root.fromAccount.type === RecipientSelector.Type.Account : true
                        horizontalAlignment: Image.AlignLeft
                        width: itmFromValue.needsRightPadding() ? (Style.current.halfPadding + sourceSize.width) : undefined // adding width to add addl spacing to image
                        anchors.verticalCenter: parent.verticalCenter
                        fillMode: Image.PreserveAspectFit
                        source: Style.svg("walletIcon")
                        ColorOverlay {
                            visible: parent.visible
                            anchors.fill: parent
                            source: parent
                            color: root.fromAccount && root.fromAccount.color ? root.fromAccount.color : Style.current.blue
                        }
                    }
                    SVGImage {
                        id: fromInvalid
                        anchors.verticalCenter: parent.verticalCenter
                        width: Style.dp(13)
                        height: Style.dp(13)
                        sourceSize.height: height * 2
                        sourceSize.width: width * 2
                        fillMode: Image.PreserveAspectFit
                        source: Style.svg("exclamation_outline")
                        visible: !root.fromValid
                    }
                    SVGImage {
                        id: fromArrow
                        width: Style.dp(13)
                        height: Style.dp(7)
                        visible: root.isFromEditable
                        anchors.verticalCenter: parent.verticalCenter
                        fillMode: Image.PreserveAspectFit
                        source: Style.svg("caret")
                        rotation: 270
                        ColorOverlay {
                            anchors.fill: parent
                            visible: parent.visible
                            source: parent
                            color: Style.current.secondaryText
                        }
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    visible: fromArrow.visible
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.fromClicked()
                }
            }
        }
        LabelValueRow {
            id: itmTo
            function needsRightPadding() {
                return !root.toValid || root.toWarn
            }
            //% "Recipient"
            label: qsTrId("recipient")
            states: [
                State {
                    name: "Address"
                    when: !!root.toAccount && root.toAccount.type === RecipientSelector.Type.Address
                    PropertyChanges {
                        target: txtToPrimary
                        //% "Unknown"
                        text: (!!root.toAccount && root.toAccount.address) ? root.toAccount.address : qsTrId("active-unknown")
                        elide: Text.ElideMiddle
                        anchors.leftMargin: Style.dp(190)
                        anchors.right: parent.right
                    }
                    PropertyChanges {
                        target: txtToSecondary
                        width: 0
                    }
                },
                State {
                    name: "Contact"
                    when: !!root.toAccount && root.toAccount.type === RecipientSelector.Type.Contact && !!root.toAccount.address
                    PropertyChanges {
                        target: metSecondary
                        text: root.toAccount.ensVerified ? root.toAccount.alias : root.toAccount.address
                    }
                    PropertyChanges {
                        target: txtToSecondary
                        anchors.right: idtToContact.left
                        anchors.rightMargin: Style.current.halfPadding
                        width: txtToSecondary.visible ? metSecondary.elidedWidth : 0
                        text: metSecondary.elidedText
                        visible: root.toAccount.address !== Constants.zeroAddress
                    }
                    PropertyChanges {
                        target: idtToContact
                        visible: true
                    }
                    PropertyChanges {
                        target: txtToPrimary
                        text: Utils.removeStatusEns(root.toAccount.name)
                    }
                },
                State {
                    name: "Account"
                    when: !!root.toAccount && root.toAccount.type === RecipientSelector.Type.Account && !!root.toAccount.address
                    PropertyChanges {
                        target: metSecondary
                        text: root.toAccount.address
                    }
                    PropertyChanges {
                        target: txtToSecondary
                        anchors.right: imgToWallet.left
                        anchors.rightMargin: Style.current.halfPadding
                        text: metSecondary.elidedText
                        width: metSecondary.elidedWidth
                    }
                    PropertyChanges {
                        target: imgToWallet
                        visible: true
                    }
                    PropertyChanges {
                        target: ovlToWallet
                        visible: true
                        color: root.toAccount.color
                    }
                    PropertyChanges {
                        target: txtToPrimary
                        text: root.toAccount.name
                    }
                }
            ]

            StyledText {
                id: txtToPrimary
                font.pixelSize: Style.current.primaryTextFontSize
                height: Style.dp(22)
                anchors.left: parent.left
                anchors.right: txtToSeparator.visible ? txtToSeparator.left : idtToContact.left
                anchors.rightMargin: txtToSeparator.visible ? 0 : Style.current.halfPadding
                anchors.verticalCenter: parent.verticalCenter
                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
            }
            StyledText {
                id: txtToSeparator
                font.pixelSize: Style.current.primaryTextFontSize
                height: Style.dp(22)
                text: " • "
                visible: txtToSecondary.visible && txtToSecondary.width > 0
                color: Style.current.secondaryText
                anchors.right: txtToSecondary.left
                anchors.verticalCenter: parent.verticalCenter
                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignVCenter
            }
            StyledText {
                id: txtToSecondary
                visible: true
                font.pixelSize: Style.current.primaryTextFontSize
                height: Style.dp(22)
                color: Style.current.secondaryText
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                horizontalAlignment: Text.AlignRight
                verticalAlignment: Text.AlignVCenter
            }
            TextMetrics {
                id: metSecondary
                elideWidth: Style.dp(102)
                elide: Text.ElideMiddle
            }
            SVGImage {
                id: imgToWallet
                visible: false
                sourceSize.height: Style.dp(18)
                sourceSize.width: Style.dp(18)
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                fillMode: Image.PreserveAspectFit
                source: Style.svg("walletIcon")
            }
            ColorOverlay {
                id: ovlToWallet
                anchors.fill: imgToWallet
                visible: false
                source: imgToWallet
            }
            UserImage {
                id: idtToContact
                visible: false
                anchors.right: toInvalid.visible ? toInvalid.left : parent.right
                anchors.rightMargin: toInvalid.visible ? Style.current.halfPadding : 0
                anchors.verticalCenter: parent.verticalCenter
                name: root.toAccount.name
                pubkey: root.toAccount.pubKey
                image: root.toAccount.icon
            }
            SVGImage {
                id: toInvalid
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                width: Style.dp(13)
                height: Style.dp(13)
                sourceSize.height: height * 2
                sourceSize.width: width * 2
                fillMode: Image.PreserveAspectFit
                source: Style.svg("exclamation_outline")
                visible: !root.toValid || root.toWarn
            }
        }
        LabelValueRow {
            id: itmAsset
            //% "Asset"
            label: qsTrId("wallet-asset")
            value: Item {
                anchors.fill: parent
                anchors.verticalCenter: parent.verticalCenter

                StyledText {
                    font.pixelSize: Style.current.primaryTextFontSize
                    height: Style.dp(22)
                    text: (root.asset && root.asset.name) ? root.asset.name : ""
                    anchors.left: parent.left
                    anchors.right: txtAssetSymbol.left
                    anchors.rightMargin: Style.current.halfPadding
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignVCenter
                }
                StyledText {
                    id: txtAssetSymbol
                    font.pixelSize: Style.current.primaryTextFontSize
                    height: Style.dp(22)
                    text: (root.asset && root.asset.symbol) ? root.asset.symbol : ""
                    color: Style.current.secondaryText
                    anchors.right: imgAsset.left
                    anchors.rightMargin: Style.current.halfPadding
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignVCenter
                }
                Image {
                    id: imgAsset
                    sourceSize.height: Style.dp(32)
                    sourceSize.width: Style.dp(32)
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    fillMode: Image.PreserveAspectFit
                    source: Style.png("tokens/" + ((root.asset && root.asset.symbol) ? root.asset.symbol : "ETH"))
                    onStatusChanged: {
                        if (status == Image.Error) {
                            source = Style.png("tokens/DEFAULT-TOKEN@3x")
                        }
                    }
                }
            }
        }
        LabelValueRow {
            id: itmAmount
            //% "Amount"
            label: qsTrId("amount")
            value: Item {
                id: amountRoot
                anchors.fill: parent
                anchors.verticalCenter: parent.verticalCenter

                StyledText {
                    font.pixelSize: Style.current.primaryTextFontSize
                    height: Style.dp(22)
                    text: (root.amount && root.amount.value) ? Utils.stripTrailingZeros(root.amount.value) : ""
                    anchors.left: parent.left
                    anchors.right: txtAmountSymbol.left
                    anchors.rightMargin: 5
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
                StyledText {
                    id: txtAmountSymbol
                    font.pixelSize: Style.current.primaryTextFontSize
                    height: Style.dp(22)
                    text: ((root.asset && root.asset.symbol) ? root.asset.symbol : "") + " •"
                    color: Style.current.secondaryText
                    anchors.right: txtAmountFiat.left
                    anchors.rightMargin: 5
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignVCenter
                }
                StyledText {
                    id: txtAmountFiat
                    font.pixelSize: Style.current.primaryTextFontSize
                    height: Style.dp(22)
                    text: "~" + (root.amount && root.amount.fiatValue ? root.amount.fiatValue : "0.00")
                    anchors.right: txtAmountCurrency.left
                    anchors.rightMargin: 5
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignVCenter
                }
                StyledText {
                    id: txtAmountCurrency
                    font.pixelSize: Style.current.primaryTextFontSize
                    height: Style.dp(22)
                    text: root.currency.toUpperCase()
                    color: Style.current.secondaryText
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
        LabelValueRow {
            id: itmNetworkFee
            //% "Network fee"
            label: qsTrId("network-fee")
            visible: !!root.gas
            value: Item {
                id: networkFeeRoot
                anchors.fill: parent
                anchors.verticalCenter: parent.verticalCenter
                function needsRightPadding() {
                    return !root.gasValid || root.isGasEditable
                }
                Row {
                    spacing: Style.current.halfPadding
                    rightPadding: networkFeeRoot.needsRightPadding() ? Style.current.halfPadding : 0
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    StyledText {
                        id: networkFeeText
                        font.pixelSize: Style.current.primaryTextFontSize
                        width: Style.dp(75)
                        height: Style.dp(22)
                        text: (root.gas && root.gas.value) ? Utils.stripTrailingZeros(root.gas.value) : ""
                        anchors.verticalCenter: parent.verticalCenter
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight

                        StatusQ.StatusToolTip {
                            enabled: networkFeeText.truncated
                            id: networkFeeTooltip
                            text: networkFeeText.text
                        }

                        MouseArea {
                            enabled: networkFeeText.truncated
                            anchors.fill: parent
                            hoverEnabled: enabled
                            onEntered: networkFeeTooltip.visible = true
                            onExited: networkFeeTooltip.visible = false
                        }
                    }
                    StyledText {
                        id: txtFeeSymbol
                        font.pixelSize: Style.current.primaryTextFontSize
                        height: Style.dp(22)
                        text: ((root.gas && root.gas.symbol) ? root.gas.symbol : "") + " •"
                        color: Style.current.secondaryText
                        anchors.verticalCenter: parent.verticalCenter
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                    }
                    StyledText {
                        id: txtFeeFiat
                        font.pixelSize: Style.current.primaryTextFontSize
                        height: Style.dp(22)
                        text: "~" + ((root.gas && root.gas.fiatValue) ? root.gas.fiatValue : "0.00")
                        anchors.verticalCenter: parent.verticalCenter
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                    }
                    StyledText {
                        id: txtFeeCurrency
                        font.pixelSize: Style.current.primaryTextFontSize
                        height: Style.dp(22)
                        text: root.currency.toUpperCase()
                        color: Style.current.secondaryText
                        anchors.verticalCenter: parent.verticalCenter
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                    }
                    SVGImage {
                        id: gasInvalid
                        anchors.verticalCenter: parent.verticalCenter
                        width: Style.dp(13)
                        height: Style.dp(13)
                        sourceSize.height: height * 2
                        sourceSize.width: width * 2
                        fillMode: Image.PreserveAspectFit
                        source: Style.svg("exclamation_outline")
                        visible: !root.gasValid
                    }
                    SVGImage {
                        id: gasArrow
                        width: Style.dp(13)
                        height: Style.dp(7)
                        visible: root.isGasEditable
                        anchors.verticalCenter: parent.verticalCenter
                        fillMode: Image.PreserveAspectFit
                        source: Style.svg("caret")
                        rotation: 270
                        ColorOverlay {
                            anchors.fill: parent
                            visible: parent.visible
                            source: parent
                            color: Style.current.secondaryText
                        }
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    visible: gasArrow.visible
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.gasClicked()
                }
            }
        }
        LabelValueRow {
            id: itmData
            //% "Data"
            label: qsTrId("data")
            visible: trxData !== "0x" && trxData !== ""
            value: Item {
                id: dataRoot
                anchors.fill: parent
                anchors.verticalCenter: parent.verticalCenter
                Row {
                    spacing: Style.current.halfPadding
                    rightPadding: 0
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    StyledText {
                        font.pixelSize: Style.current.primaryTextFontSize
                        height: Style.dp(22)
                        width: Style.dp(200)
                        text: trxData
                        elide: Text.ElideRight
                        color: Style.current.secondaryText
                        anchors.verticalCenter: parent.verticalCenter
                        horizontalAlignment: Text.AlignRight
                        verticalAlignment: Text.AlignVCenter
                    }
                    SVGImage {
                        width: Style.dp(13)
                        height: Style.dp(7)
                        visible: true
                        anchors.verticalCenter: parent.verticalCenter
                        fillMode: Image.PreserveAspectFit
                        source: Style.svg("caret")
                        rotation: 270
                        ColorOverlay {
                            anchors.fill: parent
                            visible: parent.visible
                            source: parent
                            color: Style.current.secondaryText
                        }
                    }
                }

                // TODO: replace with StatusModal
                ModalPopup {
                    id: dataPopup
                    //% "Data field"
                    title: qsTrId("data-field")
                    height: Style.dp(286)
                    width: Style.dp(400)
                    Item {
                        anchors.fill: parent
                        anchors.leftMargin: 0
                        anchors.rightMargin: 0
                        ScrollView {
                            width: parent.width
                            height: Style.dp(150)
                            TextArea {
                                wrapMode: TextEdit.Wrap
                                readOnly: true
                                text: trxData
                            }
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: dataPopup.open()
                }
            }
        }
    }
}
