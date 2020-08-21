import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13
import "../imports"

Item {
    id: root
    property var fromAccount: ({})
    property var toAccount: ({ type: "" })
    property var asset: ({ name: "", symbol: "" })
    property var amount: ({ value: "", fiatValue: "", currency: "" })
    property string currency: "USD"
    property var gas: ({ value: "", symbol: "", fiatValue: "" })
    height: content.height
    
    Column {
        id: content
        anchors.left: parent.left
        anchors.right: parent.right

        LabelValueRow {
            id: itmFrom
            label: qsTr("From")
            value: Item {
                anchors.fill: parent
                anchors.verticalCenter: parent.verticalCenter

                StyledText {
                    font.pixelSize: 15
                    height: 22
                    text: root.fromAccount.name
                    elide: Text.ElideRight
                    anchors.left: parent.left
                    anchors.right: imgFromWallet.left
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignVCenter
                }
                SVGImage {
                    id: imgFromWallet
                    sourceSize.height: 18
                    sourceSize.width: 18
                    anchors.right: parent.right
                    anchors.rightMargin: Style.current.padding
                    anchors.verticalCenter: parent.verticalCenter
                    fillMode: Image.PreserveAspectFit
                    source: "../app/img/walletIcon.svg"
                }
                ColorOverlay {
                    anchors.fill: imgFromWallet
                    source: imgFromWallet
                    color: fromAccount.iconColor
                }
            }
        }
        LabelValueRow {
            id: itmTo
            property var props: { "primaryText": "replace1", "secondaryText": "me1" }
            label: qsTr("Recipient")
            states: [
                State {
                    name: "Address"
                    when: root.toAccount.type === RecipientSelector.Type.Address
                    PropertyChanges {
                        target: txtToPrimary
                        text: root.toAccount.address
                        elide: Text.ElideMiddle
                        anchors.leftMargin: 190
                    }
                    PropertyChanges {
                        target: txtToSecondary
                        width: 0
                    }
                },
                State {
                    name: "Contact"
                    when: root.toAccount.type === RecipientSelector.Type.Contact && !!root.toAccount.address
                    PropertyChanges {
                        target: metSecondary
                        text: root.toAccount.ensVerified ? root.toAccount.alias : root.toAccount.address
                    }
                    PropertyChanges {
                        target: txtToSecondary
                        anchors.rightMargin: Style.current.padding + idtToContact.width + 8
                        width: metSecondary.elidedWidth
                        text: metSecondary.elidedText
                    }
                    PropertyChanges {
                        target: idtToContact
                        source: root.toAccount.identicon
                        visible: true
                    }
                    PropertyChanges {
                        target: txtToPrimary
                        text: Utils.removeStatusEns(root.toAccount.name)
                    }
                },
                State {
                    name: "Account"
                    when: root.toAccount.type === RecipientSelector.Type.Account && !!root.toAccount.address
                    PropertyChanges {
                        target: metSecondary
                        text: root.toAccount.address
                    }
                    PropertyChanges {
                        target: txtToSecondary
                        anchors.rightMargin: Style.current.padding + imgToWallet.width + 8
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
                        color: root.toAccount.iconColor
                    }
                    PropertyChanges {
                        target: txtToPrimary
                        text: root.toAccount.name
                    }
                }
            ]
            value: Item {
                id: recipientRoot
                anchors.fill: parent
                anchors.verticalCenter: parent.verticalCenter

                StyledText {
                    id: txtToPrimary
                    font.pixelSize: 15
                    height: 22
                    anchors.left: parent.left
                    anchors.right: txtToSeparator.left
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
                StyledText {
                    id: txtToSeparator
                    font.pixelSize: 15
                    height: 22
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
                    font.pixelSize: 15
                    height: 22
                    color: Style.current.secondaryText
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignVCenter
                }
                TextMetrics {
                    id: metSecondary
                    elideWidth: 102
                    elide: Text.ElideMiddle
                }
                SVGImage {
                    id: imgToWallet
                    visible: false
                    sourceSize.height: 18
                    sourceSize.width: 18
                    anchors.right: parent.right
                    anchors.rightMargin: Style.current.padding
                    anchors.verticalCenter: parent.verticalCenter
                    fillMode: Image.PreserveAspectFit
                    source: "../app/img/walletIcon.svg"
                }
                ColorOverlay {
                    id: ovlToWallet
                    anchors.fill: imgToWallet
                    visible: false
                    source: imgToWallet
                }
                Identicon {
                    id: idtToContact
                    visible: false
                    anchors.right: parent.right
                    anchors.rightMargin: Style.current.padding
                    anchors.verticalCenter: parent.verticalCenter
                    width: 32
                    height: 32
                }
            }
        }
        LabelValueRow {
            id: itmAsset
            label: qsTr("Asset")
            value: Item {
                anchors.fill: parent
                anchors.verticalCenter: parent.verticalCenter

                StyledText {
                    font.pixelSize: 15
                    height: 22
                    text: (root.asset && root.asset.name) ? root.asset.name : ""
                    anchors.left: parent.left
                    anchors.right: txtAssetSymbol.left
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignVCenter
                }
                StyledText {
                    id: txtAssetSymbol
                    font.pixelSize: 15
                    height: 22
                    text: (root.asset && root.asset.symbol) ? root.asset.symbol : ""
                    color: Style.current.secondaryText
                    anchors.right: imgAsset.left
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignVCenter
                }
                Image {
                    id: imgAsset
                    sourceSize.height: 32
                    sourceSize.width: 32
                    anchors.right: parent.right
                    anchors.rightMargin: Style.current.padding
                    anchors.verticalCenter: parent.verticalCenter
                    fillMode: Image.PreserveAspectFit
                    source: "../app/img/tokens/" + ((root.asset && root.asset.symbol) ? root.asset.symbol : "ETH") + ".png"
                    onStatusChanged: {
                        if (status == Image.Error) {
                            source = "../app/img/tokens/0-native.png"
                        }
                    }
                }
            }
        }
        LabelValueRow {
            id: itmAmount
            label: qsTr("Amount")
            value: Item {
                id: amountRoot
                anchors.fill: parent
                anchors.verticalCenter: parent.verticalCenter

                StyledText {
                    font.pixelSize: 15
                    height: 22
                    text: root.amount.value ? Utils.stripTrailingZeros(root.amount.value) : ""
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
                    font.pixelSize: 15
                    height: 22
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
                    font.pixelSize: 15
                    height: 22
                    text: "~" + (root.amount.fiatValue ? root.amount.fiatValue : "0.00")
                    anchors.right: txtAmountCurrency.left
                    anchors.rightMargin: 5
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignVCenter
                }
                StyledText {
                    id: txtAmountCurrency
                    font.pixelSize: 15
                    height: 22
                    text: root.currency.toUpperCase()
                    color: Style.current.secondaryText
                    anchors.right: parent.right
                    anchors.rightMargin: Style.current.padding
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
        LabelValueRow {
            id: itmNetworkFee
            label: qsTr("Network fee")
            value: Item {
                id: networkFeeRoot
                anchors.fill: parent
                anchors.verticalCenter: parent.verticalCenter

                StyledText {
                    font.pixelSize: 15
                    height: 22
                    text: (root.gas && root.gas.value) ? Utils.stripTrailingZeros(root.gas.value) : ""
                    anchors.left: parent.left
                    anchors.right: txtFeeSymbol.left
                    anchors.rightMargin: 5
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }
                StyledText {
                    id: txtFeeSymbol
                    font.pixelSize: 15
                    height: 22
                    text: ((root.gas && root.gas.symbol) ? root.gas.symbol : "") + " •"
                    color: Style.current.secondaryText
                    anchors.right: txtFeeFiat.left
                    anchors.rightMargin: 5
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignVCenter
                }
                StyledText {
                    id: txtFeeFiat
                    font.pixelSize: 15
                    height: 22
                    text: "~" + ((root.gas && root.gas.fiatValue) ? root.gas.fiatValue : "0.00")
                    anchors.right: txtFeeCurrency.left
                    anchors.rightMargin: 5
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignVCenter
                }
                StyledText {
                    id: txtFeeCurrency
                    font.pixelSize: 15
                    height: 22
                    text: root.currency.toUpperCase()
                    color: Style.current.secondaryText
                    anchors.right: parent.right
                    anchors.rightMargin: Style.current.padding
                    anchors.verticalCenter: parent.verticalCenter
                    horizontalAlignment: Text.AlignRight
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }
}
