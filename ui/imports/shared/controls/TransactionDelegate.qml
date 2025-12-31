import QtQuick
import QtQuick.Layouts
import QtQml

import StatusQ.Components
import StatusQ.Core.Theme
import StatusQ.Core
import StatusQ.Controls
import StatusQ.Core.Utils as SQUtils

import AppLayouts.Wallet

import utils
import shared
import shared.stores as SharedStores

/*!
   \qmltype TransactionDelegate
   \inherits StatusListItem
   \inqmlmodule shared.controls
   \since shared.controls 1.0
   \brief Delegate for transaction activity list

   Delegate to display transaction activity data.

   \qml
    // Normal usage - in ListView with TransactionsModelAdaptor model
    TransactionDelegate {
        width: ListView.view.width
        currentCurrency: root.currentCurrency
        formatCurrencyAmountFn: root.formatCurrencyAmountFn
    }

    // Loading skeleton
    TransactionDelegate {
        loading: true
    }
   \endqml

   Additional usages should be handled using states.
*/

StatusListItem {
    id: root

    signal retryClicked()

    property string timeStampText: isModelDataValid ? LocaleUtils.formatRelativeTimestamp(modelData.timestamp * 1000) : ""
    property bool showAllAccounts: false
    property bool displayValues: true

    // for fiat value formatting in UI
    property string currentCurrency: ""
    property var formatCurrencyAmountFn: function(amount, symbol, options) { return "" }

    // All computed properties come from model (via TransactionsModelAdaptor)
    readonly property var modelData: loading ? null : (model?.activityEntry ?? null)
    readonly property bool isModelDataValid: !loading && modelData !== null && modelData !== undefined
    readonly property string txID: loading ? "" : (model?.txID ?? "")
    readonly property int transactionStatus: loading ? Constants.TransactionStatus.Pending : (model?.transactionStatus ?? Constants.TransactionStatus.Pending)
    readonly property bool isMultiTransaction: loading ? false : (model?.isMultiTransaction ?? false)
    readonly property double cryptoValue: loading ? 0.0 : (model?.cryptoValue ?? 0.0)
    readonly property double fiatValue: loading ? 0.0 : (model?.fiatValue ?? 0.0)
    readonly property double inCryptoValue: loading ? 0.0 : (model?.inCryptoValue ?? 0.0)
    readonly property double inFiatValue: loading ? 0.0 : (model?.inFiatValue ?? 0.0)
    readonly property double outCryptoValue: loading ? 0.0 : (model?.outCryptoValue ?? 0.0)
    readonly property double outFiatValue: loading ? 0.0 : (model?.outFiatValue ?? 0.0)
    readonly property string networkColor: loading ? "" : (model?.networkColor ?? "")
    readonly property string networkName: loading ? "" : (model?.networkName ?? "")
    readonly property string networkNameIn: loading ? "" : (model?.networkNameIn ?? "")
    readonly property string networkNameOut: loading ? "" : (model?.networkNameOut ?? "")
    readonly property string addressNameTo: loading ? "" : (model?.addressNameTo ?? "")
    readonly property string addressNameFrom: loading ? "" : (model?.addressNameFrom ?? "")
    readonly property bool isNFT: loading ? false : (model?.isNFT ?? false)
    readonly property bool isCommunityAssetViaAirdrop: loading ? false : (model?.isCommunityAssetViaAirdrop ?? false)
    readonly property string communityId: loading ? "" : (model?.communityId ?? "")
    readonly property var community: loading ? null : (model?.community ?? null)
    readonly property bool isCommunityToken: loading ? false : (model?.isCommunityToken ?? false)
    readonly property string communityImage: loading ? "" : (model?.communityImage ?? "")
    readonly property string communityName: loading ? "" : (model?.communityName ?? "")
    readonly property var dAppDetails: loading ? null : (model?.dAppDetails ?? null)
    readonly property string dAppIcon: loading ? "" : (model?.dAppIcon ?? "")
    readonly property string dAppUrl: loading ? "" : (model?.dAppUrl ?? "")
    readonly property string dAppName: loading ? "" : (model?.dAppName ?? "")
    readonly property string transactionValue: loading ? "" : (model?.transactionValue ?? "")
    readonly property string inTransactionValue: loading ? "" : (model?.inTransactionValue ?? "")
    readonly property string outTransactionValue: loading ? "" : (model?.outTransactionValue ?? "")
    readonly property string tokenImage: loading ? "" : (model?.tokenImage ?? "")
    readonly property string inTokenImage: loading ? "" : (model?.inTokenImage ?? "")
    readonly property string toAddress: loading ? "" : (model?.toAddress ?? "")
    readonly property string fromAddress: loading ? "" : (model?.fromAddress ?? "")
    readonly property string interactedContractAddress: loading ? "" : (model?.interactedContractAddress ?? "")
    readonly property string approvalSpender: loading ? "" : (model?.approvalSpender ?? "")

    property StatusAssetSettings statusIconAsset: StatusAssetSettings {
        width: 12
        height: 12
        bgWidth: width + 2
        bgHeight: bgWidth
        bgRadius: bgWidth / 2
        bgColor: root.color
        color: "transparent"
        name: {
            switch(root.transactionStatus) {
            case Constants.TransactionStatus.Pending:
                return Assets.svg("transaction/pending")
            case Constants.TransactionStatus.Complete:
            case Constants.TransactionStatus.Finalised:
                return Assets.svg("transaction/confirmed")
            case Constants.TransactionStatus.Failed:
                return Assets.svg("transaction/failed")
            default:
                return ""
            }
        }
    }

    property StatusAssetSettings tokenIconAsset: StatusAssetSettings {
        width: 20
        height: 20
        bgWidth: width + 2
        bgHeight: height + 2
        bgRadius: bgWidth / 2
        bgColor: d.lightTheme && Constants.isDefaultTokenIcon(root.tokenImage) ?
                     StatusColors.white : "transparent"
        color: "transparent"
        isImage: !loading
        name: root.tokenImage
        isLetterIdenticon: loading
    }

    QtObject {
        id: d

        property int loadingPixelSize: 13
        property int datePixelSize: 12
        property int titlePixelSize: 15
        property int subtitlePixelSize: 13
        property bool showRetryButton: false

        readonly property bool isLightTheme: Theme.palette.name === Constants.lightThemeName
        property color animatedBgColor
        readonly property int txType: root.loading ? 0 : (model?.txType ?? 0)

        readonly property var secondIconAsset: StatusAssetSettings {
            width: root.tokenIconAsset.width
            height: root.tokenIconAsset.height
            bgWidth: width + 2
            bgHeight: height + 2
            bgRadius: bgWidth / 2
            bgColor: StatusColors.white
            isImage: root.tokenIconAsset.isImage
            color: root.tokenIconAsset.color
            name: d.secondIconSource
            isLetterIdenticon: root.tokenIconAsset.isLetterIdenticon
        }

        readonly property string secondIconSource: {
            if (!root.isModelDataValid || root.isNFT) {
                return ""
            }

            if (modelData.txType === Constants.TransactionType.Swap) {
                return root.inTokenImage
            } else if (modelData.txType === Constants.TransactionType.Approve) {
                return root.dAppIcon
            }
            return ""
        }
        readonly property bool isSecondIconVisible: secondIconSource !== ""
    }

    function getSubtitle(allAccounts, description) {
        if (root.isCommunityAssetViaAirdrop) {
            let communityInfo = ""
            if (!description) {
                // Showing image only in delegate. In description url shouldn't be showed
                communityInfo += "<img src='" + root.communityImage + "' width='18' height='18' </img> "
            }
            communityInfo += root.communityName
            return qsTr("%1 (community asset) from %2 on %3").arg(root.transactionValue).arg(communityInfo).arg(root.networkName)
        }

        switch(d.txType) {
        case Constants.TransactionType.Send:
            // Cross chain send. Use bridge pattern
            if (root.networkNameIn != root.networkNameOut && root.networkNameIn && root.networkNameOut) {
                if (allAccounts)
                    return qsTr("%1 from %2 to %3 on %4 and %5").arg(inTransactionValue).arg(fromAddress).arg(toAddress).arg(networkNameOut).arg(networkNameIn)
                return qsTr("%1 to %2 on %3 and %4").arg(inTransactionValue).arg(toAddress).arg(networkNameOut).arg(networkNameIn)
            }

            if (allAccounts)
                return qsTr("%1 from %2 to %3 on %4").arg(transactionValue).arg(fromAddress).arg(toAddress).arg(networkName)
            return qsTr("%1 to %2 on %3").arg(transactionValue).arg(toAddress).arg(networkName)

        case Constants.TransactionType.Receive:
            // Cross chain receive. Use bridge pattern
            if (root.networkNameIn != root.networkNameOut && root.networkNameIn && root.networkNameOut) {
                if (allAccounts)
                    return qsTr("%1 from %2 to %3 on %4 and %5").arg(inTransactionValue).arg(fromAddress).arg(toAddress).arg(networkNameOut).arg(networkNameIn)
                return qsTr("%1 from %2 on %3 and %4").arg(inTransactionValue).arg(toAddress).arg(networkNameOut).arg(networkNameIn)
            }

            if (allAccounts)
                return qsTr("%1 from %2 to %3 on %4").arg(transactionValue).arg(fromAddress).arg(toAddress).arg(networkName)
            return qsTr("%1 from %2 on %3").arg(transactionValue).arg(fromAddress).arg(networkName)
        case Constants.TransactionType.Destroy:
            if (allAccounts)
                return qsTr("%1 at %2 on %3 in %4").arg(inTransactionValue).arg(toAddress).arg(networkName).arg(toAddress)
            return qsTr("%1 at %2 on %3").arg(inTransactionValue).arg(toAddress).arg(networkName)
        case Constants.TransactionType.Swap:
            if (allAccounts)
                return qsTr("%1 to %2 in %3 on %4").arg(outTransactionValue).arg(inTransactionValue).arg(fromAddress).arg(networkName)
            return qsTr("%1 to %2 on %3").arg(outTransactionValue).arg(inTransactionValue).arg(networkName)
        case Constants.TransactionType.Bridge:
            if (allAccounts) {
                if (networkNameIn)
                    return qsTr("%1 from %2 to %3 in %4").arg(outTransactionValue).arg(networkNameOut).arg(networkNameIn).arg(fromAddress)
                return qsTr("%1 from %2 in %3").arg(outTransactionValue).arg(networkNameOut).arg(fromAddress)
            }
            if (networkNameIn)
                return qsTr("%1 from %2 to %3").arg(outTransactionValue).arg(networkNameOut).arg(networkNameIn)
            return qsTr("%1 from %2").arg(outTransactionValue).arg(networkNameOut)
        case Constants.TransactionType.ContractDeployment:
            const name = addressNameTo || addressNameFrom
            return qsTr("Via %1 on %2").arg(name).arg(networkName)
        case Constants.TransactionType.Mint:
            if (allAccounts)
                return qsTr("%1 via %2 in %3").arg(transactionValue).arg(networkName).arg(toAddress)
            return qsTr("%1 via %2").arg(transactionValue).arg(networkName)
        case Constants.TransactionType.Approve:
            if (root.dAppUrl !== "") {
                if (allAccounts)
                    return qsTr("%1 in %2 for %3 on %4").arg(transactionValue).arg(toAddress).arg(dAppUrl).arg(networkName)
                return qsTr("%1 for %2 on %3").arg(transactionValue).arg(dAppUrl).arg(networkName)
            }
            if (allAccounts)
                return qsTr("%1 in %2 for %3 on %4").arg(transactionValue).arg(fromAddress).arg(approvalSpender).arg(networkName)
            return qsTr("%1 for %2 on %3").arg(transactionValue).arg(approvalSpender).arg(networkName)
        case Constants.TransactionType.ContractInteraction:
        default:
            // Unknown contract interaction
            if (allAccounts)
                return qsTr("Between %1 and %2 on %3").arg(fromAddress).arg(interactedContractAddress).arg(networkName)
            return qsTr("With %1 on %2").arg(interactedContractAddress).arg(networkName)
        }
    }

    rightPadding: 16
    enabled: !root.loading
    color: {
        if (bgColorAnimation.running) {
            return d.animatedBgColor
        }
        return sensor.containsMouse ? Theme.palette.baseColor5 : StatusColors.transparent
    }

    statusListItemIcon.active: (loading || root.asset.name)
    asset {
        width: 24
        height: 24
        isImage: false
        imgIsIdenticon: true
        isLetterIdenticon: loading
        name: {
            if (!root.isModelDataValid)
                return ""

            switch(d.txType) {
            case Constants.TransactionType.Send:
                return "send"
            case Constants.TransactionType.Receive:
                return "receive"
            case Constants.TransactionType.Mint:
                return "token"
            case Constants.TransactionType.Destroy:
                return "destroy"
            case Constants.TransactionType.Swap:
                return "swap"
            case Constants.TransactionType.Bridge:
                return "bridge"
            case Constants.TransactionType.ContractDeployment:
                return "contract_deploy"
            case Constants.TransactionType.Approve:
                return "approve"
            default:
                return "contract_deploy"
            }
        }
        bgColor: "transparent"
        color: Theme.palette.directColor1
        bgBorderWidth: 1
        bgBorderColor: Theme.palette.primaryColor3
    }

    sensor.children: [
        StatusRoundIcon {
            id: leftIconStatusIcon
            visible: !root.loading
            anchors {
                right: root.statusListItemIcon.right
                bottom: root.statusListItemIcon.bottom
            }
            asset: root.statusIconAsset
        }
    ]

    // Title
    title: {
        if (root.loading) {
            return "dummmy"
        } else if (!root.isModelDataValid) {
            return ""
        }

        const isPending = root.transactionStatus === Constants.TransactionStatus.Pending
        const failed = root.transactionStatus === Constants.TransactionStatus.Failed
        switch(d.txType) {
        case Constants.TransactionType.Send:
            return failed ? qsTr("Send failed") : (isPending ? qsTr("Sending") : qsTr("Sent"))
        case Constants.TransactionType.Receive:
            return failed ? qsTr("Receive failed") : (isPending ? qsTr("Receiving") : qsTr("Received"))
        case Constants.TransactionType.Destroy:
            return failed ? qsTr("Destroy failed") : (isPending ? qsTr("Destroying") : qsTr("Destroyed"))
        case Constants.TransactionType.Swap:
            return failed ? qsTr("Swap failed") : (isPending ? qsTr("Swapping") : qsTr("Swapped"))
        case Constants.TransactionType.Bridge:
            return failed ? qsTr("Bridge failed") : (isPending ? qsTr("Bridging") : qsTr("Bridged"))
        case Constants.TransactionType.ContractDeployment:
            return failed ? qsTr("Contract deployment failed") : (isPending ? qsTr("Deploying contract") : qsTr("Contract deployed"))
        case Constants.TransactionType.Mint:
            if (isNFT)
                return failed ? qsTr("Collectible minting failed") : (isPending ? qsTr("Minting collectible") : qsTr("Collectible minted"))
            return failed ? qsTr("Token minting failed") : (isPending ? qsTr("Minting token") : qsTr("Token minted"))
        case Constants.TransactionType.Approve:
            return failed ? qsTr("Failed to set spending cap") : (isPending ? qsTr("Setting spending cap") : qsTr("Spending cap set"))
        default:
            return qsTr("Interaction")
        }
    }
    statusListItemTitleArea.anchors.rightMargin: root.rightPadding
    statusListItemTitle.font.weight: Font.DemiBold
    statusListItemTitle.font.pixelSize: root.loading ? d.loadingPixelSize : d.titlePixelSize

    // title icons and date
    statusListItemTitleIcons.sourceComponent: Row {
        spacing: 8
        Row {
            id: tokenImagesRow
            visible: !root.loading && !!root.tokenIconAsset.name
            spacing: secondTokenImage.visible ? -tokenImage.width * 0.2 : 0
            StatusRoundIcon {
                id: tokenImage
                anchors.verticalCenter: parent.verticalCenter
                asset: root.tokenIconAsset
            }
            StatusRoundIcon {
                id: secondTokenImage
                visible: d.isSecondIconVisible
                anchors.verticalCenter: parent.verticalCenter
                asset: d.secondIconAsset
            }
        }
        StatusTextWithLoadingState {
            anchors.verticalCenter: parent.verticalCenter
            text: root.loading ? root.title : root.timeStampText
            verticalAlignment: Qt.AlignVCenter
            font.pixelSize: root.loading ? d.loadingPixelSize : d.datePixelSize
            visible: !!text
            loading: root.loading
            customColor: Theme.palette.baseColor1
            leftPadding: tokenImagesRow.visible ? 0 : parent.spacing
        }
    }

    // subtitle
    subTitle: {
        if (root.loading) {
            return "dummy text dummy text dummy text dummy text dummy text dummy text"
        }

        if (!root.isModelDataValid) {
            return ""
        }

        return getSubtitle(root.showAllAccounts, false)
    }
    statusListItemSubTitle.textFormat: root.isCommunityAssetViaAirdrop ? Text.RichText : Text.AutoText
    statusListItemSubTitle.maximumLoadingStateWidth: 400
    statusListItemSubTitle.customColor: Theme.palette.directColor1
    statusListItemSubTitle.font.pixelSize: root.loading ? d.loadingPixelSize : d.subtitlePixelSize
    statusListItemTagsRowLayout.anchors.topMargin: 4 // Spacing between title row nad subtitle row

    // Right side components
    components: [
        Loader {
            active: root.displayValues && !headerStatusLoader.active
            visible: active
            sourceComponent: ColumnLayout {
                StatusTextWithLoadingState {
                    id: cryptoValueText
                    text: {
                        if (root.loading) {
                            return "dummy text"
                        } else if (!root.isModelDataValid || root.isNFT) {
                            return ""
                        }

                        switch(d.txType) {
                        case Constants.TransactionType.Send:
                            return "−" + root.transactionValue
                        case Constants.TransactionType.Receive:
                            return "+" + root.transactionValue
                        case Constants.TransactionType.Swap:
                            let outValue = root.outTransactionValue
                            outValue = outValue.replace('<', '&lt;')
                            let inValue = root.inTransactionValue
                            inValue = inValue.replace('<', '&lt;')
                            return "<font color=\"%1\">-%2</font> <font color=\"%3\">/</font> <font color=\"%4\">+%5</font>"
                                          .arg(Theme.palette.directColor1)
                                          .arg(outValue)
                                          .arg(Theme.palette.baseColor1)
                                          .arg(Theme.palette.successColor1)
                                          .arg(inValue)
                        case Constants.TransactionType.Bridge:
                        case Constants.TransactionType.Approve:
                        default:
                            return ""
                        }
                    }
                    horizontalAlignment: Qt.AlignRight
                    Layout.alignment: Qt.AlignRight
                    font.pixelSize: root.loading ? d.loadingPixelSize : 13
                    customColor: {
                        if (!root.isModelDataValid)
                            return ""

                        switch(d.txType) {
                        case Constants.TransactionType.Receive:
                        case Constants.TransactionType.Swap:
                            return Theme.palette.successColor1
                        default:
                            return Theme.palette.directColor1
                        }
                    }
                    loading: root.loading
                }
                StatusTextWithLoadingState {
                    id: fiatValueText
                    Layout.alignment: Qt.AlignRight
                    horizontalAlignment: Qt.AlignRight
                    text: {
                        if (root.loading) {
                            return "dummy text"
                        } else if (!root.isModelDataValid || root.isNFT || !modelData.symbol) {
                            return ""
                        }

                        switch(d.txType) {
                        case Constants.TransactionType.Send:
                            return "−" + root.formatCurrencyAmountFn(root.fiatValue, root.currentCurrency)
                        case Constants.TransactionType.Receive:
                            return "+" + root.formatCurrencyAmountFn(root.fiatValue, root.currentCurrency)
                        case Constants.TransactionType.Swap:
                            return "-%1 / +%2".arg(root.formatCurrencyAmountFn(root.outFiatValue, root.currentCurrency))
                                              .arg(root.formatCurrencyAmountFn(root.inFiatValue, root.currentCurrency))
                        case Constants.TransactionType.Bridge:
                        case Constants.TransactionType.Approve:
                        default:
                            return ""
                        }
                    }
                    font.pixelSize: root.loading ? d.loadingPixelSize : 12
                    customColor: Theme.palette.baseColor1
                    loading: root.loading
                }
            }
        },
        Loader {
            id: headerStatusLoader
            active: false
            visible: active
            sourceComponent: Rectangle {
                id: statusRect
                width: transactionTypeIcon.width + (retryButton.visible ? retryButton.width + 5 : 0)
                height: transactionTypeIcon.height
                anchors.verticalCenter: parent.verticalCenter
                color: "transparent"
                radius: 100
                border {
                    width: retryButton.visible ? 1 : 0
                    color: root.asset.bgBorderColor
                }

                StatusButton {
                    id: retryButton
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 10
                    radius: height / 2
                    height: parent.height * 0.7
                    verticalPadding: 0
                    horizontalPadding: radius
                    text: qsTr("Retry")
                    size: StatusButton.Small
                    type: StatusButton.Primary
                    visible: d.showRetryButton
                    onClicked: root.retryClicked()
                }

                StatusSmartIdenticon {
                    id: transactionTypeIcon
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.right: parent.right
                    enabled: false
                    asset: root.asset
                    active: !!root.asset.name
                    loading: root.loading
                    name: root.title
                }

                StatusRoundIcon {
                    visible: !root.loading
                    anchors {
                        right: transactionTypeIcon.right
                        bottom: transactionTypeIcon.bottom
                    }
                    asset: root.statusIconAsset
                }
            }
        }
    ]

    states: [
        State {
            name: "header"
            PropertyChanges {
                target: headerStatusLoader
                active: true
            }
            PropertyChanges {
                target: leftIconStatusIcon
                visible: false
            }
            PropertyChanges {
                target: root.statusListItemIcon
                active: false
            }
            PropertyChanges {
                target: root.asset
                bgBorderWidth: d.showRetryButton ? 0 : 1
                width: 34
                height: 34
                bgWidth: 56
                bgHeight: 56
            }
            PropertyChanges {
                target: root.statusIconAsset
                width: 17
                height: 17
            }
            // PropertyChanges { // TODO uncomment when retry failed tx is implemented
            //     target: d
            //     titlePixelSize: 17
            //     datePixelSize: 13
            //     subtitlePixelSize: 15
            //     loadingPixelSize: 14
            //     showRetryButton: (!root.loading && root.transactionStatus === Constants.TransactionStatus.Failed && walletRootStore.isOwnedAccount(modelData.sender))
            // }
        }
    ]

    ColorAnimation {
        id: bgColorAnimation

        target: d
        property: "animatedBgColor"
        from: d.isLightTheme ? "#33869eff" : "#1a4360df"
        to: "transparent"
        duration: 1000
        alwaysRunToEnd: true

        onStopped: {
            modelData.doneHighlighting()
        }
    }
    // Add a delay before the animation to make it easier to notice when scrolling
    Timer {
        id: delayAnimation
        interval: 250
        running: root.visible && isModelDataValid && modelData.highlight
        repeat: false
        onTriggered: {
            bgColorAnimation.start()
        }
    }
}
