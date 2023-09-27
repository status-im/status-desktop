import QtQuick 2.15
import QtQuick.Layouts 1.14
import QtGraphicalEffects 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils

import utils 1.0
import shared.panels 1.0

import AppLayouts.Communities.helpers 1.0
import AppLayouts.Communities.panels 1.0

import SortFilterProxyModel 0.2

StatusScrollView {
    id: root

    property int viewWidth: 560 // by design
    property bool preview: false

    // https://bugreports.qt.io/browse/QTBUG-84269
    /* required */ property TokenObject token
    /* required */ property string feeText
    /* required */ property string feeErrorText
    /* required */ property bool isFeeLoading


    readonly property bool isAssetView: token.type === Constants.TokenType.ERC20

    readonly property string name: token.name
    readonly property string description: token.description
    readonly property string symbol: token.symbol
    readonly property int supply: token.supply
    readonly property url artworkSource: token.artworkSource
    readonly property rect artworkCropRect: token.artworkCropRect
    readonly property bool infiniteSupply: token.infiniteSupply
    readonly property int remainingTokens: root.preview ? root.supply : token.remainingTokens
    readonly property int deployState: token.deployState
    readonly property string accountName: token.accountName
    readonly property string chainName: token.chainName
    readonly property string chainId: token.chainId
    readonly property string accountAddress: token.accountAddress
    readonly property bool remotelyDestruct: token.remotelyDestruct
    readonly property int remotelyDestructState: token.remotelyDestructState
    readonly property bool transferable: token.transferable
    readonly property string chainIcon: token.chainIcon
    readonly property int decimals: token.decimals

    readonly property bool deploymentCompleted:
        deployState === Constants.ContractTransactionStatus.Completed

    readonly property string feeLabel:
        isAssetView ? qsTr("Mint asset on %1").arg(token.chainName)
                    : qsTr("Mint collectible on %1").arg(token.chainName)
                    
    // Models:
    property var tokenOwnersModel

    // Required for preview mode:
    property var accounts
    signal mintClicked()

    signal airdropRequested(string address)
    signal generalAirdropRequested

    signal viewProfileRequested(string contactId)
    signal viewMessagesRequested(string contactId)

    signal remoteDestructRequested(string name, string address)
    signal kickRequested(string name, string contactId, string address)
    signal banRequested(string name, string contactId, string address)

    QtObject {
        id: d

        readonly property int iconSize: 20
    }

    padding: 0
    contentWidth: mainLayout.width
    contentHeight: mainLayout.height

    ColumnLayout {
        id: mainLayout

        width: root.viewWidth
        spacing: Style.current.padding

        RowLayout {
            visible: !root.preview && !root.deploymentCompleted
            spacing: Style.current.halfPadding

            StatusDotsLoadingIndicator { visible: (root.deployState === Constants.ContractTransactionStatus.InProgress) }

            StatusIcon {
                visible: (root.deployState === Constants.ContractTransactionStatus.Failed)
                icon: "warning"
                color: Theme.palette.dangerColor1
            }

            StatusBaseText {
                elide: Text.ElideRight
                font.pixelSize: Theme.primaryTextFontSize
                text: (root.deployState === Constants.ContractTransactionStatus.InProgress) ?
                          (root.isAssetView ?
                               qsTr("Asset is being minted") : qsTr("Collectible is being minted")) :
                          (root.deployState === Constants.ContractTransactionStatus.Failed) ?
                              (root.isAssetView ? qsTr("Asset minting failed") : qsTr("Collectible minting failed")) : ""
                color: (root.deployState === Constants.ContractTransactionStatus.Failed) ? Theme.palette.dangerColor1 : Theme.palette.directColor1
            }
        }

        TokenInfoPanel {
            Layout.fillWidth: true

            token: root.token
        }

        RowLayout {
            visible: root.preview
            Layout.fillWidth: true

            StatusIcon {
                Layout.preferredWidth: d.iconSize
                Layout.preferredHeight: d.iconSize
                Layout.alignment: Qt.AlignTop
                color: Theme.palette.baseColor1
                icon: "info"
            }

            StatusBaseText {
                Layout.fillWidth: true
                wrapMode: Text.Wrap
                font.pixelSize: Style.current.primaryTextFontSize
                color: Theme.palette.baseColor1
                text: qsTr("Review token details before minting it as they can’t be edited later")
            }
        }

        FeesBox {
            id: feesBox

            Layout.fillWidth: true
            Layout.topMargin: Style.current.padding

            implicitWidth: 0
            visible: root.preview

            accountErrorText: root.feeErrorText

            model: QtObject {
                readonly property string title: root.feeLabel
                readonly property string feeText: root.isFeeLoading ?
                                                      "" : root.feeText
                readonly property bool error: root.feeErrorText !== ""
            }

            accountsSelector.model: root.accounts || null

            Component.onCompleted: {
                const initIndex = StatusQUtils.ModelUtils.indexOf(
                                    accountsSelector.model, "name",
                                    token.accountName)

                accountsSelector.currentIndex = (initIndex !== -1) ? initIndex : 0

                accountsSelector.currentIndexChanged.connect(() => {
                    if (accountsSelector.currentIndex < 0)
                        return

                    const item = StatusQUtils.ModelUtils.get(
                                   accountsSelector.model,
                                   accountsSelector.currentIndex)
                    token.accountAddress = item.address
                    token.accountName = item.name
                })
            }
        }

        StatusButton {
            Layout.preferredHeight: 44
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            Layout.topMargin: Style.current.halfPadding

            visible: root.preview
            enabled: !root.isFeeLoading && root.feeErrorText === ""

            text: qsTr("Mint")

            onClicked: root.mintClicked()
        }

        SortableTokenHoldersPanel {
            visible: !root.preview && root.deploymentCompleted

            model: root.tokenOwnersModel
            tokenName: root.name
            showRemotelyDestructMenuItem: !root.isAssetView && root.remotelyDestruct
            isAirdropEnabled: root.deploymentCompleted &&
                              (token.infiniteSupply || token.remainingTokens > 0)

            Layout.topMargin: Style.current.padding
            Layout.fillWidth: true

            onViewProfileRequested: root.viewProfileRequested(contactId)
            onViewMessagesRequested: root.viewMessagesRequested(contactId)
            onAirdropRequested: root.airdropRequested(address)
            onGeneralAirdropRequested: root.generalAirdropRequested()
            onRemoteDestructRequested: root.remoteDestructRequested(name, address)

            onKickRequested: root.kickRequested(name, contactId, address)
            onBanRequested: root.banRequested(name, contactId, address)
        }
    }
}
