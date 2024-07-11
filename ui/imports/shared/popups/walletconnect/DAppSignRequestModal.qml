import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.15

import StatusQ 0.1
import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as SQUtils
import AppLayouts.Wallet.popups 1.0
import AppLayouts.Wallet.panels 1.0

import shared.popups.walletconnect.panels 1.0

import utils 1.0

SignTransactionModalBase {
    id: root

    required property bool signingTransaction
    // DApp info
    required property url dappUrl
    required property url dappIcon
    required property string dappName
    // Payload to sign
    required property string requestPayload
    // Account
    required property color accountColor
    required property string accountName
    required property string accountEmoji
    required property string accountAddress
    // Network
    required property string networkName
    required property string networkIconPath
    // Fees
    required property string currentCurrency
    required property string fiatFees
    required property string cryptoFees
    required property string estimatedTime
    required property bool hasFees

    property bool enoughFundsForTransaction: true
    property bool enoughFundsForFees: false

    signButtonEnabled: enoughFundsForTransaction && enoughFundsForFees
    title: qsTr("Sign Request")
    subtitle: SQUtils.StringUtils.extractDomainFromLink(root.dappUrl)
    headerIconComponent: RoundImageWithBadge {
        imageUrl: root.dappIcon
        width: 40
        height: 40
    }

    gradientColor: Utils.setColorAlpha(root.accountColor, 0.05) // 5% of wallet color
    headerMainText: root.signingTransaction ? qsTr("%1 wants you to sign this transaction with %2").arg(root.dappName).arg(root.accountName) :
                                                qsTr("%1 wants you to sign this message with %2").arg(root.dappName).arg(root.accountName)

    fromImageSmartIdenticon.asset.name: "filled-account"
    fromImageSmartIdenticon.asset.emoji: root.accountEmoji
    fromImageSmartIdenticon.asset.color: root.accountColor
    fromImageSmartIdenticon.asset.isLetterIdenticon: !!root.accountEmoji
    toImageSmartIdenticon.asset.name: Style.svg("sign")
    toImageSmartIdenticon.asset.bgColor: Theme.palette.primaryColor3
    toImageSmartIdenticon.asset.width: 24
    toImageSmartIdenticon.asset.height: 24
    toImageSmartIdenticon.asset.color: Theme.palette.primaryColor1

    infoTagText: qsTr("Only sign if you trust the dApp")
    infoTag.states: [
        State {
            name: "insufficientFunds"
            when: !root.enoughFundsForTransaction
            PropertyChanges {
                target: infoTag
                asset.color: Theme.palette.dangerColor1
                tagPrimaryLabel.color: Theme.palette.dangerColor1
                backgroundColor: Theme.palette.dangerColor3
                bgBorderColor: Theme.palette.dangerColor2
                tagPrimaryLabel.text: qsTr("Insufficient funds for transaction")
            }
        }
    ]
    showHeaderDivider: !root.requestPayload

    leftFooterContents: ObjectModel {
        RowLayout {
            Layout.leftMargin: 4
            spacing: Style.current.bigPadding
            ColumnLayout {
                spacing: 2
                StatusBaseText {
                    text: qsTr("Max fees:")
                    color: Theme.palette.baseColor1
                    font.pixelSize: Style.current.additionalTextSize
                }
                StatusTextWithLoadingState {
                    Layout.fillWidth: true
                    objectName: "footerFiatFeesText"
                    text: "%1 %2".arg(formatBigNumber(root.fiatFees)).arg(root.currentCurrency)
                    loading: root.feesLoading
                    customColor: root.enoughFundsForFees ? Theme.palette.directColor1 : Theme.palette.dangerColor1
                    elide: Qt.ElideMiddle
                    Binding on text {
                        when: !root.hasFees
                        value: qsTr("No fees")
                    }
                }
            }
            ColumnLayout {
                spacing: 2
                visible: root.hasFees
                StatusBaseText {
                    text: qsTr("Est. time:")
                    color: Theme.palette.baseColor1
                    font.pixelSize: Style.current.additionalTextSize
                }
                StatusTextWithLoadingState {
                    objectName: "footerEstimatedTime"
                    text: root.estimatedTime
                    loading: root.feesLoading
                }
            }
        }
    }

    // Payload
    ContentPanel {
        Layout.fillWidth: true
        Layout.fillHeight: true
        payloadToDisplay: root.requestPayload
        visible: !!root.requestPayload
    }

    // Account
    SignInfoBox {
        Layout.fillWidth: true
        Layout.bottomMargin: Style.current.bigPadding
        objectName: "accountBox"
        caption: qsTr("Sign with")
        primaryText: root.accountName
        secondaryText: SQUtils.Utils.elideAndFormatWalletAddress(root.accountAddress)
        asset.name: "filled-account"
        asset.emoji: root.accountEmoji
        asset.color: root.accountColor
        asset.isLetterIdenticon: !!root.accountEmoji
    }

    // Network
    SignInfoBox {
        Layout.fillWidth: true
        Layout.bottomMargin: Style.current.bigPadding
        objectName: "networkBox"
        caption: qsTr("Network")
        primaryText: root.networkName
        icon: root.networkIconPath
    }

    // Fees
    SignInfoBox {
        Layout.fillWidth: true
        Layout.bottomMargin: Style.current.bigPadding
        objectName: "feesBox"
        caption: qsTr("Fees")
        primaryText: qsTr("Max. fees on %1").arg(root.networkName)
        secondaryText: " "
        enabled: false
        visible: root.hasFees
        components: [
            ColumnLayout {
                spacing: 2
                StatusTextWithLoadingState {
                    objectName: "fiatFeesText"
                    Layout.alignment: Qt.AlignRight
                    text: "%1 %2".arg(formatBigNumber(root.fiatFees)).arg(root.currentCurrency)
                    horizontalAlignment: Text.AlignRight
                    font.pixelSize: Style.current.additionalTextSize
                    loading: root.feesLoading
                    customColor: root.enoughFundsForFees ? Theme.palette.directColor1 : Theme.palette.dangerColor1
                }
                StatusTextWithLoadingState {
                    objectName: "cryptoFeesText"
                    Layout.alignment: Qt.AlignRight
                    text: "%1 ETH".arg(formatBigNumber(root.cryptoFees))
                    horizontalAlignment: Text.AlignRight
                    font.pixelSize: Style.current.additionalTextSize
                    customColor: root.enoughFundsForFees ? Theme.palette.baseColor1 : Theme.palette.dangerColor1
                    loading: root.feesLoading
                }
            }
        ]
    }
}