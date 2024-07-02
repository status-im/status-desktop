import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1 as SQUtils
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1
import StatusQ.Popups.Dialog 0.1

import AppLayouts.Wallet.panels 1.0

import shared.controls 1.0

import utils 1.0

StatusDialog {
    id: root

    required property string fromTokenSymbol
    required property string fromTokenAmount
    required property string fromTokenContractAddress

    required property string toTokenSymbol
    required property string toTokenAmount
    required property string toTokenContractAddress

    required property string accountName
    required property string accountAddress
    required property string accountEmoji
    required property string accountColorId

    required property string networkShortName // e.g. "oeth"
    required property string networkName // e.g. "Optimism"
    required property string networkIconPath // e.g. `Style.svg("network/Network=Optimism")`
    required property string networkBlockExplorerUrl

    required property string currentCurrency
    required property string fiatFees
    required property string cryptoFees
    required property double slippage

    required property int loginType // RootStore.loginType -> Constants.LoginType enum

    property bool loading // refreshing fees

    property string serviceProviderName: "Paraswap"
    property string serviceProviderURL: "https://www.paraswap.io/"

    title: qsTr("Sign Swap")
    //: e.g. (swap) 100 DAI to 100 USDT
    subtitle: qsTr("%1 %2 to %3 %4").arg(d.formatBigNumber(fromTokenAmount)).arg(fromTokenSymbol).arg(d.formatBigNumber(toTokenAmount)).arg(toTokenSymbol)

    width: 480
    padding: 0

    QtObject {
        id: d

        readonly property color walletColor: Utils.getColorForId(root.accountColorId)

        function openLinkWithConfirmation(linkUrl) {
            Global.openLinkWithConfirmation(linkUrl, SQUtils.StringUtils.extractDomainFromLink(linkUrl))
        }

        function getExplorerName() {
            if (root.networkShortName === Constants.networkShortChainNames.arbitrum) {
                return qsTr("Arbiscan")
            }
            if (root.networkShortName === Constants.networkShortChainNames.optimism) {
                return qsTr("Optimistic")
            }
            return qsTr("Etherscan")
        }

        function formatBigNumber(number: string) {
            return number.replace('.', Qt.locale().decimalPoint)
        }
    }

    header: StatusDialogHeader {
        visible: root.title || root.subtitle
        headline.title: root.title
        headline.subtitle: root.subtitle
        actions.closeButton.onClicked: root.closeHandler()

        leftComponent: StatusSmartIdenticon {
            id: walletHeaderIcon
            asset.name: !!root.accountEmoji ? "" : "filled-account"
            asset.emoji: root.accountEmoji
            asset.color: d.walletColor
            asset.isLetterIdenticon: !!root.accountEmoji
            asset.bgWidth: 40
            asset.bgHeight: 40

            bridgeBadge.visible: true
            bridgeBadge.border.width: 2
            bridgeBadge.color: Style.current.darkBlue
            bridgeBadge.image.source: Style.svg("sign")
        }
    }

    footer: StatusDialogFooter {
        dropShadowEnabled: true

        leftButtons: ObjectModel {
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
                        objectName: "footerFiatFeesText"
                        text: "%1 %2".arg(d.formatBigNumber(root.fiatFees)).arg(root.currentCurrency)
                        loading: root.loading
                    }
                }
                ColumnLayout {
                    spacing: 2
                    StatusBaseText {
                        text: qsTr("Max slippage:")
                        color: Theme.palette.baseColor1
                        font.pixelSize: Style.current.additionalTextSize
                    }
                    StatusBaseText {
                        objectName: "footerMaxSlippageText"
                        text: "%1%".arg(LocaleUtils.numberToLocaleString(root.slippage))
                    }
                }
            }
        }
        rightButtons: ObjectModel {
            RowLayout {
                Layout.rightMargin: 4
                spacing: Style.current.halfPadding
                StatusFlatButton {
                    objectName: "rejectButton"
                    Layout.preferredHeight: signButton.height
                    text: qsTr("Reject")
                    onClicked: root.reject() // close and emit rejected() signal
                }
                StatusButton {
                    objectName: "signButton"
                    id: signButton
                    interactive: !root.loading
                    icon.name: Constants.authenticationIconByType[root.loginType]
                    text: qsTr("Sign")
                    onClicked: root.accept() // close and emit accepted() signal
                }
            }
        }
    }

    StatusScrollView {
        id: scrollView
        anchors.fill: parent
        contentWidth: availableWidth
        topPadding: 0
        bottomPadding: 0

        ColumnLayout {
            anchors.left: parent.left
            anchors.leftMargin: 4
            anchors.right: parent.right
            anchors.rightMargin: 4
            spacing: 0

            // header with gradient
            Rectangle {
                Layout.fillWidth: true
                Layout.leftMargin: -parent.anchors.leftMargin - scrollView.leftPadding
                Layout.rightMargin: -parent.anchors.rightMargin - scrollView.rightPadding
                Layout.preferredHeight: 266 // design
                gradient: Gradient {
                    GradientStop { position: 0.0; color: Utils.setColorAlpha(d.walletColor, 0.05) } // 5% of wallet color
                    GradientStop { position: 1.0; color: root.backgroundColor }
                }

                ColumnLayout {
                    width: 336 // by design
                    spacing: 12
                    anchors.centerIn: parent

                    Row {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: -10
                        StatusRoundedImage {
                            objectName: "fromImage"
                            width: 40
                            height: 40
                            border.width: 2
                            border.color: "transparent"
                            image.source: Constants.tokenIcon(root.fromTokenSymbol)
                        }
                        StatusRoundedImage {
                            objectName: "toImage"
                            width: 40
                            height: 40
                            border.width: 2
                            border.color: Theme.palette.statusBadge.foregroundColor
                            image.source: Constants.tokenIcon(root.toTokenSymbol)
                        }
                    }

                    StatusBaseText {
                        objectName: "headerText"
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                        font.weight: Font.DemiBold
                        //: e.g. "Swap 100 DAI to 100 USDT in <account name> on <network chain name>"
                        text: qsTr("Swap %1 %2 to %3 %4 in %5 on %6").arg(d.formatBigNumber(root.fromTokenAmount)).arg(root.fromTokenSymbol)
                          .arg(d.formatBigNumber(root.toTokenAmount)).arg(root.toTokenSymbol).arg(root.accountName).arg(root.networkName)
                        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                        horizontalAlignment: Text.AlignHCenter
                        lineHeightMode: Text.FixedHeight
                        lineHeight: 22
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 4
                        StatusBaseText {
                            font.pixelSize: Style.current.additionalTextSize
                            text: qsTr("Powered by")
                            onLinkActivated: d.openLinkWithConfirmation(root.serviceProviderURL)
                        }
                        StatusLinkText {
                            Layout.topMargin: 1
                            text: root.serviceProviderName
                            normalColor: Theme.palette.directColor1
                            linkColor: Theme.palette.directColor1
                            font.weight: Font.Normal
                            onClicked: d.openLinkWithConfirmation(root.serviceProviderURL)
                        }
                        StatusIcon {
                            width: 16
                            height: 16
                            icon: "external-link"
                            color: Theme.palette.directColor1
                        }
                    }

                    InformationTag {
                        Layout.alignment: Qt.AlignHCenter
                        tagPrimaryLabel.text: qsTr("Review all details before signing")
                        asset.name: "info"
                    }
                }
            }

            StatusDialogDivider {
                Layout.fillWidth: true
                Layout.bottomMargin: Style.current.bigPadding
            }

            // Pay
            SignInfoBox {
                Layout.fillWidth: true
                Layout.bottomMargin: Style.current.bigPadding
                objectName: "payBox"
                caption: qsTr("Pay")
                primaryText: "%1 %2".arg(d.formatBigNumber(root.fromTokenAmount)).arg(root.fromTokenSymbol)
                secondaryText: SQUtils.Utils.elideAndFormatWalletAddress(root.fromTokenContractAddress)
                icon: Constants.tokenIcon(root.fromTokenSymbol)
                badge: root.networkIconPath
                components: [
                    SignButtonWithMenu {
                        symbol: root.fromTokenSymbol
                        contractAddress: root.fromTokenContractAddress
                        networkName: root.networkName
                        explorerName: d.getExplorerName()
                        networkBlockExplorerUrl: root.networkBlockExplorerUrl
                        onOpenLink: (link) => d.openLinkWithConfirmation(link)
                    }
                ]
            }

            // Receive
            SignInfoBox {
                Layout.fillWidth: true
                Layout.bottomMargin: Style.current.bigPadding
                objectName: "receiveBox"
                caption: qsTr("Receive")
                primaryText: "%1 %2".arg(d.formatBigNumber(root.toTokenAmount)).arg(root.toTokenSymbol)
                secondaryText: SQUtils.Utils.elideAndFormatWalletAddress(root.toTokenContractAddress)
                icon: Constants.tokenIcon(root.toTokenSymbol)
                badge: root.networkIconPath
                components: [
                    SignButtonWithMenu {
                        symbol: root.toTokenSymbol
                        contractAddress: root.toTokenContractAddress
                        networkName: root.networkName
                        explorerName: d.getExplorerName()
                        networkBlockExplorerUrl: root.networkBlockExplorerUrl
                        onOpenLink: (link) => d.openLinkWithConfirmation(link)
                    }
                ]
            }

            // Account
            SignInfoBox {
                Layout.fillWidth: true
                Layout.bottomMargin: Style.current.bigPadding
                objectName: "accountBox"
                caption: qsTr("In account")
                primaryText: root.accountName
                secondaryText: SQUtils.Utils.elideAndFormatWalletAddress(root.accountAddress)
                asset.name: !!root.accountEmoji ? "" : "filled-account"
                asset.emoji: root.accountEmoji
                asset.color: d.walletColor
                asset.isLetterIdenticon: !!root.accountEmoji
                asset.bgWidth: 40
                asset.bgHeight: 40
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
                components: [
                    ColumnLayout {
                        spacing: 2
                        StatusBaseText {
                            objectName: "fiatFeesText"
                            Layout.alignment: Qt.AlignRight
                            text: "%1 %2".arg(d.formatBigNumber(root.fiatFees)).arg(root.currentCurrency)
                            horizontalAlignment: Text.AlignRight
                            font.pixelSize: Style.current.additionalTextSize
                        }
                        StatusBaseText {
                            objectName: "cryptoFeesText"
                            Layout.alignment: Qt.AlignRight
                            text: "%1 ETH".arg(d.formatBigNumber(root.cryptoFees))
                            horizontalAlignment: Text.AlignRight
                            font.pixelSize: Style.current.additionalTextSize
                            color: Theme.palette.baseColor1
                        }
                    }
                ]
            }
        }
    }
}
