import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml 2.15

import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import AppLayouts.Communities.controls 1.0
import AppLayouts.Communities.helpers 1.0
import AppLayouts.Communities.layouts 1.0
import AppLayouts.Communities.popups 1.0
import AppLayouts.Communities.views 1.0

import utils 1.0
import SortFilterProxyModel 0.2

StackView {
    id: root

    // General properties:
    property string communityName
    property int viewWidth: 560 // by design

    // Models:
    property var tokensModel
    property var accounts // Expected roles: address, name, color, emoji, walletType

    // Transaction related properties:
    property string feeText
    property string errorText
    property bool isFeeLoading: true

    // Network related properties:
    property var layer1Networks
    property var layer2Networks
    property var testNetworks
    property var enabledNetworks
    property var allNetworks

    signal mintCollectible(var collectibleItem)
    signal mintAsset(var assetItem)

    signal signMintTransactionOpened(int chainId, string accountAddress, int tokenType)

    signal signRemoteDestructTransactionOpened(var remotelyDestructTokensList, // [key , amount]
                                               string tokenKey)
    signal remotelyDestructCollectibles(var remotelyDestructTokensList, // [key , amount]
                                        string tokenKey)
    signal signBurnTransactionOpened(string tokenKey, int amount)
    signal burnToken(string tokenKey, int amount)
    signal airdropToken(string tokenKey, int type, var addresses)
    signal deleteToken(string tokenKey)

    function setFeeLoading() {
        root.isFeeLoading = true
        root.feeText = ""
        root.errorText = ""
    }

    function navigateBack() {
        pop(StackView.Immediate)
    }

    function resetNavigation() {
        pop(initialItem, StackView.Immediate)
    }

    function openNewTokenForm(isAssetView) {
        resetNavigation()

        const properties = { isAssetView }
        root.push(newTokenViewComponent, properties, StackView.Immediate)
    }

    property string previousPageName: depth > 1 ? qsTr("Back") : ""

    initialItem: SettingsPage {
        implicitWidth: 0
        title: qsTr("Tokens")

        buttons: StatusButton {
            objectName: "addNewItemButton"

            text: qsTr("Mint token")

            onClicked: root.push(newTokenViewComponent, StackView.Immediate)
        }

        contentItem: MintedTokensView {
            model: root.tokensModel

            onItemClicked: {
                root.push(tokenViewComponent, { tokenKey }, StackView.Immediate)
            }
        }
    }

    Component {
        id: tokenObjectComponent

        TokenObject {}
    }

    // Mint tokens possible view contents:
    Component {
        id: newTokenViewComponent

        SettingsPage {
            id: newTokenPage

            property TokenObject asset: TokenObject{
                type: Constants.TokenType.ERC20
            }

            property TokenObject collectible: TokenObject {
                type: Constants.TokenType.ERC721
            }

            property bool isAssetView: false
            property int validationMode: StatusInput.ValidationMode.OnlyWhenDirty
            property string referenceName: ""
            property string referenceSymbol: ""

            title: optionsTab.currentItem == assetsTab
                   ? qsTr("Mint asset") : qsTr("Mint collectible")

            contentItem: ColumnLayout {
                width: root.viewWidth
                spacing: Style.current.padding

                StatusSwitchTabBar {
                    id: optionsTab

                    Layout.preferredWidth: root.viewWidth
                    currentIndex: newTokenPage.isAssetView ? 1 : 0

                    StatusSwitchTabButton {
                        id: collectiblesTab

                        text: qsTr("Collectibles")
                    }

                    StatusSwitchTabButton {
                        id: assetsTab

                        text: qsTr("Assets")
                    }
                }

                StackLayout {
                    Layout.preferredWidth: root.viewWidth
                    Layout.fillHeight: true

                    currentIndex: optionsTab.currentItem == collectiblesTab ? 0 : 1

                    CustomEditCommunityTokenView {
                        id: newCollectibleView

                        isAssetView: false
                        validationMode: !newTokenPage.isAssetView
                                        ? newTokenPage.validationMode
                                        : StatusInput.ValidationMode.OnlyWhenDirty
                        collectible: newTokenPage.collectible
                    }

                    CustomEditCommunityTokenView {
                        id: newAssetView

                        isAssetView: true
                        validationMode: newTokenPage.isAssetView
                                        ? newTokenPage.validationMode
                                        : StatusInput.ValidationMode.OnlyWhenDirty
                        asset: newTokenPage.asset
                    }

                    component CustomEditCommunityTokenView: EditCommunityTokenView {
                        viewWidth: root.viewWidth
                        layer1Networks: root.layer1Networks
                        layer2Networks: root.layer2Networks
                        testNetworks: root.testNetworks
                        enabledNetworks: root.testNetworks
                        allNetworks: root.allNetworks
                        accounts: root.accounts
                        tokensModel: root.tokensModel

                        referenceName: newTokenPage.referenceName
                        referenceSymbol: newTokenPage.referenceSymbol

                        onPreviewClicked: {
                            const properties = {
                                token: isAssetView ? asset : collectible
                            }

                            root.push(previewTokenViewComponent, properties,
                                      StackView.Immediate)
                        }
                    }
                }
            }
        }
    }

    Component {
        id: previewTokenViewComponent

        SettingsPage {
            id: tokenPreviewPage

            property alias token: preview.token

            title: token.name
            subtitle: token.symbol

            contentItem: CommunityTokenView {
                id: preview

                function signMintTransaction() {
                    root.setFeeLoading()

                    if(preview.isAssetView)
                        root.mintAsset(token)
                    else
                        root.mintCollectible(token)

                    root.resetNavigation()
                }

                viewWidth: root.viewWidth
                preview: true

                onMintClicked: signMintPopup.open()

                SignTokenTransactionsPopup {
                    id: signMintPopup

                    anchors.centerIn: Overlay.overlay
                    title: qsTr("Sign transaction - Mint %1 token").arg(
                               signMintPopup.tokenName)
                    tokenName: preview.name
                    accountName: preview.accountName
                    networkName: preview.chainName
                    feeText: root.feeText
                    errorText: root.errorText
                    isFeeLoading: root.isFeeLoading

                    onOpened: {
                        root.setFeeLoading()
                        root.signMintTransactionOpened(
                                    preview.chainId, preview.accountAddress,
                                    preview.isAssetView ? Constants.TokenType.ERC20
                                                        : Constants.TokenType.ERC721)
                    }
                    onCancelClicked: close()
                    onSignTransactionClicked: preview.signMintTransaction()
                }
            }
        }
    }

    component TokenViewPage: SettingsPage {
        id: tokenViewPage

        readonly property alias token: view.token

        property alias tokenOwnersModel: view.tokenOwnersModel
        property alias airdropKey: view.airdropKey

        title: view.name
        subtitle: view.symbol

        buttons: [
            StatusButton {
                text: qsTr("Delete")
                type: StatusBaseButton.Type.Danger

                visible: view.deployState === Constants.ContractTransactionStatus.Failed

                onClicked: deleteTokenAlertPopup.open()
            },
            StatusButton {
                text: qsTr("Retry mint")

                visible: view.deployState === Constants.ContractTransactionStatus.Failed

                onClicked: {
                    // https://bugreports.qt.io/browse/QTBUG-91917
                    var isAssetView = tokenViewPage.token.type === Constants.TokenType.ERC20

                    // copy TokenObject
                    var tokenObject = tokenObjectComponent.createObject(
                                          null, view.token)

                    // Then move on to the new token view, but token pre-filled:
                    var properties = {
                        isAssetView,
                        referenceName: tokenObject.name,
                        referenceSymbol: tokenObject.symbol,
                        validationMode: StatusInput.ValidationMode.Always,
                        [isAssetView ? "asset" : "collectible"]: tokenObject
                    }

                    var tokenView = root.push(newTokenViewComponent, properties,
                                                StackView.Immediate)

                    // cleanup dynamically created TokenObject
                    tokenView.Component.destruction.connect(() => tokenObject.destroy())
                }
            }
        ]

        contentItem: CommunityTokenView {
            id: view

            property string airdropKey // TO REMOVE: Temporal property until airdrop backend is not ready to use token key instead of symbol

            viewWidth: root.viewWidth

            token: TokenObject {}

            onGeneralAirdropRequested: {
                root.airdropToken(view.airdropKey, view.token.type, []) // tokenKey instead when backend airdrop ready to use key instead of symbol
            }

            onAirdropRequested: {
                root.airdropToken(view.airdropKey, view.token.type, [address]) // tokenKey instead when backend airdrop ready to use key instead of symbol
            }

            onRemoteDestructRequested: {
                remotelyDestructPopup.open()
                // TODO: set the address selected in the popup's list
            }
        }

        footer: MintTokensFooterPanel {
            id: footer

            readonly property TokenObject token: view.token

            readonly property bool deployStateCompleted:
                token.deployState === Constants.ContractTransactionStatus.Completed

            function closePopups() {
                remotelyDestructPopup.close()
                alertPopup.close()
                signTransactionPopup.close()
                burnTokensPopup.close()
            }

            airdropEnabled: deployStateCompleted &&
                            (token.infiniteSupply ||
                             token.remainingTokens !== 0)

            remotelyDestructEnabled: deployStateCompleted &&
                                     !!view.tokenOwnersModel &&
                                     view.tokenOwnersModel.count > 0

            burnEnabled: deployStateCompleted

            remotelyDestructVisible: token.remotelyDestruct
            burnVisible: !token.infiniteSupply

            onAirdropClicked:root.airdropToken(view.airdropKey, // tokenKey instead when backend airdrop ready to use key instead of symbol
                                  view.token.type, [])

            onRemotelyDestructClicked: remotelyDestructPopup.open()
            onBurnClicked: burnTokensPopup.open()

            // helper properties to pass data through popups
            property var remotelyDestructTokensList
            property int burnAmount

            RemotelyDestructPopup {
                id: remotelyDestructPopup

                collectibleName: view.token.name
                model: view.tokenOwnersModel || null
                destroyOnClose: false

                onRemotelyDestructClicked: {
                    footer.remotelyDestructTokensList = remotelyDestructTokensList
                    alertPopup.tokenCount = tokenCount
                    alertPopup.open()
                }
            }

            AlertPopup {
                id: alertPopup

                property int tokenCount

                destroyOnClose: false

                title: qsTr("Remotely destruct %n token(s)", "", tokenCount)
                acceptBtnText: qsTr("Remotely destruct")
                alertText: qsTr("Continuing will destroy tokens held by members and revoke any permissions they are given. To undo you will have to issue them new tokens.")

                onAcceptClicked: {
                    signTransactionPopup.isRemotelyDestructTransaction = true
                    signTransactionPopup.open()
                }
            }

            SignTokenTransactionsPopup {
                id: signTransactionPopup

                property bool isRemotelyDestructTransaction
                readonly property string tokenKey: tokenViewPage.token.key

                function signTransaction() {
                    root.setFeeLoading()

                    if(signTransactionPopup.isRemotelyDestructTransaction)
                        root.remotelyDestructCollectibles(
                                    footer.remotelyDestructTokensList, tokenKey)
                    else
                        root.burnToken(tokenKey, footer.burnAmount)

                    footerPanel.closePopups()
                }

                title: signTransactionPopup.isRemotelyDestructTransaction
                       ? qsTr("Sign transaction - Self-destruct %1 tokens").arg(root.title)
                       : qsTr("Sign transaction - Burn %1 tokens").arg(root.title)

                tokenName: footer.token.name
                accountName: footer.token.accountName
                networkName: footer.token.chainName
                feeText: root.feeText
                isFeeLoading: root.isFeeLoading
                errorText: root.errorText

                onOpened: {
                    root.setFeeLoading()
                    signTransactionPopup.isRemotelyDestructTransaction
                            ? root.signRemoteDestructTransactionOpened(footer.remotelyDestructTokensList, tokenKey)
                            : root.signBurnTransactionOpened(tokenKey, footer.burnAmount)
                }
                onCancelClicked: close()
                onSignTransactionClicked: signTransaction()
            }

            BurnTokensPopup {
                id: burnTokensPopup

                communityName: root.communityName
                tokenName: footer.token.name
                remainingTokens: footer.token.remainingTokens
                tokenSource: footer.token.artworkSource

                onBurnClicked: {
                    footer.burnAmount = burnAmount
                    signTransactionPopup.isRemotelyDestructTransaction = false
                    signTransactionPopup.open()
                }
            }
        }

        AlertPopup {
            id: deleteTokenAlertPopup

            readonly property alias tokenName: view.token.name

            width: 521
            title: qsTr("Delete %1").arg(tokenName)
            acceptBtnText: qsTr("Delete %1 token").arg(tokenName)
            alertText: qsTr("%1 is not yet minted, are you sure you want to delete it? All data associated with this token including its icon and description will be permanently deleted.").arg(tokenName)

            onAcceptClicked: {
                root.deleteToken(tokenViewPage.token.key)
                root.navigateBack()
            }
            onCancelClicked: close()
        }
    }

    Component {
        id: tokenViewComponent

        Item {
            id: tokenViewPageWrapper

            property string tokenKey

            Repeater {
                model: SortFilterProxyModel {
                    sourceModel: root.tokensModel
                    filters: ValueFilter {
                        roleName: "contractUniqueKey"
                        value: tokenViewPageWrapper.tokenKey
                    }
                }

                delegate: TokenViewPage {
                    implicitWidth: 0
                    anchors.fill: parent

                    tokenOwnersModel: model.tokenOwnersModel
                    airdropKey: model.symbol // TO BE REMOVED: When airdrop backend is ready to use token key instead of symbol

                    token.accountName: model.accountName
                    token.artworkSource: model.image
                    token.chainIcon: model.chainIcon
                    token.chainId: model.chainId
                    token.chainName: model.chainName
                    token.decimals: model.decimals
                    token.deployState: model.deployState
                    token.description: model.description
                    token.infiniteSupply: model.infiniteSupply
                    token.key: model.contractUniqueKey
                    token.name: model.name
                    token.remainingTokens: model.remainingSupply
                    token.remotelyDestruct: model.remoteSelfDestruct
                    token.supply: model.supply
                    token.symbol: model.symbol
                    token.transferable: model.transferable
                    token.type: model.tokenType

                    // TODO: Backend
                    //token.accountAddress: model.accountAddress
                    //token.burnState: model.burnState
                    //token.remotelyDestructState: model.remotelyDestructState
                }

                onCountChanged: {
                    if (count === 0)
                        root.navigateBack()
                }
            }
        }
    }
}
