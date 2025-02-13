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
import shared.panels 1.0

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
    required property string fiatFees
    required property string cryptoFees
    required property string estimatedTime
    required property bool hasFees
    required property bool estimatedTimeLoading

    property bool enoughFundsForTransaction: true
    property bool enoughFundsForFees: false

    title: qsTr("Sign Request")
    subtitle: SQUtils.StringUtils.extractDomainFromLink(root.dappUrl)
    headerIconComponent: RoundImageWithBadge {
        imageUrl: root.dappIcon
        width: 40
        height: 40
        badgeSize: 16
        badgeMargin: 2
        badgeIcon: Theme.svg("sign-blue")
    }

    gradientColor: root.accountColor
    headerMainText: root.signingTransaction ? qsTr("%1 wants you to sign this transaction with %2").arg(root.dappName).arg(root.accountName)
                                            : qsTr("%1 wants you to sign this message with %2").arg(root.dappName).arg(root.accountName)

    fromImageSmartIdenticon.asset.name: "filled-account"
    fromImageSmartIdenticon.asset.emoji: root.accountEmoji
    fromImageSmartIdenticon.asset.color: root.accountColor
    fromImageSmartIdenticon.asset.isLetterIdenticon: !!root.accountEmoji
    toImageSmartIdenticon.asset.name: Theme.svg("sign")
    toImageSmartIdenticon.asset.bgColor: Theme.palette.primaryColor3
    toImageSmartIdenticon.asset.width: 24
    toImageSmartIdenticon.asset.height: 24
    toImageSmartIdenticon.asset.color: Theme.palette.primaryColor1

    infoTagText: qsTr("Only sign if you trust the dApp")
    infoTag.states: [
        State {
            name: "insufficientFunds"
            when: root.hasFees && !root.enoughFundsForTransaction
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
            spacing: Theme.bigPadding
            ColumnLayout {
                spacing: 2
                StatusBaseText {
                    text: qsTr("Max fees:")
                    color: Theme.palette.baseColor1
                    font.pixelSize: Theme.additionalTextSize
                }
                StatusTextWithLoadingState {
                    id: maxFees
                    Layout.fillWidth: true
                    objectName: "footerFiatFeesText"
                    text: formatBigNumber(root.fiatFees, root.currentCurrency)
                    loading: root.feesLoading && root.hasFees
                    elide: Qt.ElideMiddle
                    Binding on text {
                        when: !root.hasFees
                        value: qsTr("No fees")
                    }
                    Binding on customColor {
                        value: !root.hasFees || root.enoughFundsForFees ? Theme.palette.directColor1 : Theme.palette.dangerColor1
                    }

                    onTextChanged: {
                        if (text === "" || loading) {
                            return
                        }
                        maxFeesAnimation.restart()
                    }

                    StatusColorAnimation {
                        id: maxFeesAnimation
                        target: maxFees
                        targetProperty: "customColor"
                        running: !maxFees.loading && root.hasFees
                        fromColor: maxFees.customColor
                    }
                }
            }
            ColumnLayout {
                spacing: 2
                visible: root.hasFees
                StatusBaseText {
                    text: qsTr("Est. time:")
                    color: Theme.palette.baseColor1
                    font.pixelSize: Theme.additionalTextSize
                }
                StatusTextWithLoadingState {
                    id: estimatedTime
                    objectName: "footerEstimatedTime"
                    text: root.estimatedTime
                    loading: root.estimatedTimeLoading

                    onTextChanged: {
                        if (text === "" || loading) {
                            return
                        }
                        estimatedTimeAnimation.restart()
                    }

                    StatusColorAnimation {
                        id: estimatedTimeAnimation
                        target: estimatedTime
                        targetProperty: "customColor"
                        running: !estimatedTime.loading
                    }
                }
            }
        }
    }

    // Payload
    ContentPanel {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.bottomMargin: Theme.bigPadding
        payloadToDisplay: root.requestPayload
        visible: !!root.requestPayload
    }

    // Account
    SignInfoBox {
        Layout.fillWidth: true
        Layout.bottomMargin: Theme.bigPadding
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
        Layout.bottomMargin: Theme.bigPadding
        objectName: "networkBox"
        caption: qsTr("Network")
        primaryText: root.networkName
        icon: root.networkIconPath
    }

    // Fees
    SignInfoBox {
        Layout.fillWidth: true
        Layout.bottomMargin: Theme.bigPadding
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
                    id: fiatFees
                    objectName: "fiatFeesText"
                    Layout.alignment: Qt.AlignRight
                    text: formatBigNumber(root.fiatFees, root.currentCurrency)
                    horizontalAlignment: Text.AlignRight
                    font.pixelSize: Theme.additionalTextSize
                    loading: root.feesLoading

                    Binding on customColor {
                        value: root.enoughFundsForFees ? Theme.palette.directColor1 : Theme.palette.dangerColor1
                    }
                    onTextChanged: {
                        if (text === "" || loading) {
                            return
                        }
                        fiatFeesAnimation.restart()
                    }

                    StatusColorAnimation {
                        id: fiatFeesAnimation
                        target: fiatFees
                        targetProperty: "customColor"
                        fromColor: fiatFees.customColor
                    }
                }
                StatusTextWithLoadingState {
                    id: cryptoFees
                    objectName: "cryptoFeesText"
                    Layout.alignment: Qt.AlignRight
                    text: formatBigNumber(root.cryptoFees, Constants.ethToken)
                    horizontalAlignment: Text.AlignRight
                    font.pixelSize: Theme.additionalTextSize
                    loading: root.feesLoading

                    Binding on customColor {
                        value: root.enoughFundsForFees ? Theme.palette.baseColor1 : Theme.palette.dangerColor1
                    }
                    onTextChanged: {
                        if (text === "" || loading) {
                            return
                        }
                        cryptoFeesAnimation.restart()
                    }

                    StatusColorAnimation {
                        id: cryptoFeesAnimation
                        target: cryptoFees
                        fromColor: cryptoFees.customColor
                        targetProperty: "customColor"
                        running: !maxFees.loading && root.hasFees
                    }
                }
            }
        ]
    }
}
