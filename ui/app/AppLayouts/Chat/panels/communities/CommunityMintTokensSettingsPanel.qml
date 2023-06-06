import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14
import QtQml 2.15

import StatusQ.Core 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Controls 0.1

import AppLayouts.Chat.layouts 1.0
import AppLayouts.Chat.views.communities 1.0
import AppLayouts.Chat.popups.community 1.0
import AppLayouts.Chat.helpers 1.0

import utils 1.0
import SortFilterProxyModel 0.2

SettingsPageLayout {
    id: root

    // General properties:
    property string communityName
    property int viewWidth: 560 // by design

    // Models:
    property var tokensModel
    property var accounts // Expected roles: address, name, color, emoji

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
    signal signMintTransactionOpened(int chainId, string accountAddress)

    signal signRemoteDestructTransactionOpened(var selfDestructTokensList, // [key , amount]
                                             string tokenKey)

    signal remotelyDestructCollectibles(var selfDestructTokensList, // [key , amount]
                                          string tokenKey)

    signal signBurnTransactionOpened(string tokenKey, int amount)

    signal burnToken(string tokenKey, int amount)

    signal airdropToken(string tokenKey)

    signal deleteToken(string tokenKey)

    function setFeeLoading() {
        root.isFeeLoading = true
        root.feeText = ""
        root.errorText = ""
    }

    function navigateBack() {
        stackManager.pop(StackView.Immediate)
    }

    function resetNavigation(isAssetView = false) {
        d.isAssetView = isAssetView
        stackManager.clear(d.initialViewState, StackView.Immediate)
    }

    QtObject {
        id: d

        readonly property string initialViewState: "WELCOME_OR_LIST_TOKENS"
        readonly property string newTokenViewState: "NEW_TOKEN"
        readonly property string previewTokenViewState: "PREVIEW_TOKEN"
        readonly property string tokenViewState: "VIEW_TOKEN"

        readonly property string welcomePageTitle: qsTr("Tokens")
        readonly property string newCollectiblePageTitle: qsTr("Mint collectible")
        readonly property string newAssetPageTitle: qsTr("Mint asset")
        readonly property string newTokenButtonText: qsTr("Mint token")
        readonly property string backButtonText: qsTr("Back")

        property string accountName
        property int chainId
        property string chainName

        property var tokenOwnersModel
        property var remotelyDestructTokensList
        property bool remotelyDestruct
        property bool burnVisible
        property string tokenKey
        property int burnAmount
        property int remainingTokens
        property url artworkSource
        property bool isAssetView: false
        property var currentToken // CollectibleObject or AssetObject type

        readonly property var initialItem: (root.tokensModel && root.tokensModel.count > 0) ? mintedTokensView : welcomeView

        signal airdropClicked()
        signal remoteDestructAddressClicked(string address)
        signal retryMintClicked()

        function updateInitialStackView() {
            if(stackManager.stackView) {
                if(initialItem === welcomeView)
                    stackManager.stackView.replace(mintedTokensView, welcomeView, StackView.Immediate)
                if(initialItem === mintedTokensView)
                    stackManager.stackView.replace(welcomeView, mintedTokensView, StackView.Immediate)
            }
        }

        onInitialItemChanged: updateInitialStackView()
    }

    QtObject {
        id: temp_

        readonly property CollectibleObject collectible: CollectibleObject{}
        readonly property AssetObject asset: AssetObject{}
    }

    secondaryHeaderButton.type: StatusBaseButton.Type.Danger

    content: StackView {
        anchors.fill: parent
        initialItem: d.initialItem

        Component.onCompleted: stackManager.pushInitialState(d.initialViewState)
    }

    state: stackManager.currentState
    states: [
        State {
            name: d.initialViewState
            PropertyChanges {target: root; title: d.welcomePageTitle}
            PropertyChanges {target: root; subTitle: ""}
            PropertyChanges {target: root; previousPageName: ""}
            PropertyChanges {target: root; primaryHeaderButton.visible: true}
            PropertyChanges {target: root; primaryHeaderButton.text: d.newTokenButtonText}
            PropertyChanges {target: root; secondaryHeaderButton.visible: false}
        },
        State {
            name: d.newTokenViewState
            PropertyChanges {target: root; title: d.isAssetView ? d.newAssetPageTitle : d.newCollectiblePageTitle }
            PropertyChanges {target: root; subTitle: ""}
            PropertyChanges {target: root; previousPageName: d.backButtonText}
            PropertyChanges {target: root; primaryHeaderButton.visible: false}
            PropertyChanges {target: root; secondaryHeaderButton.visible: false}
        },
        State {
            name: d.previewTokenViewState
            PropertyChanges {target: root; previousPageName: d.backButtonText}
            PropertyChanges {target: root; primaryHeaderButton.visible: false}
            PropertyChanges {target: root; secondaryHeaderButton.visible: false}
        },
        State {
            name: d.tokenViewState
            PropertyChanges {target: root; previousPageName: d.backButtonText}
            PropertyChanges {target: root; primaryHeaderButton.visible: false}
            PropertyChanges {target: root; footer: mintTokenFooter}
        }
    ]

    onPrimaryHeaderButtonClicked: {
        if(root.state == d.initialViewState) {
            // Then move on to the new token view, with the specific tab selected:
            stackManager.push(d.newTokenViewState,
                              newTokenView,
                              {
                                  isAssetView: d.isAssetView
                              },
                              StackView.Immediate)
        }

        if(root.state == d.tokenViewState) {
            if(d.currentToken) {
                if(d.isAssetView) {
                    // Copy current data:
                    temp_.asset.copyAsset(d.currentToken)

                    // Update to point to new instance
                    d.currentToken = temp_.asset

                    // Reset the stack:
                    root.resetNavigation(true)

                    // Then move on to the new token view, but asset pre-filled:
                    stackManager.push(d.newTokenViewState,
                                      newTokenView,
                                      {
                                          isAssetView: d.isAssetView,
                                          referenceName: d.currentToken.name,
                                          referenceSymbol: d.currentToken.symbol,
                                          validationMode: StatusInput.ValidationMode.Always,
                                          asset: d.currentToken
                                      },
                                      StackView.Immediate)
                } else {
                    // Copy current data:
                    temp_.collectible.copyCollectible(d.currentToken)

                    // Update to point to new instance
                    d.currentToken = temp_.collectible

                    // Reset the stack:
                    root.resetNavigation(false)

                    // Then move on to the new token view, but collectible pre-filled:
                    stackManager.push(d.newTokenViewState,
                                      newTokenView,
                                      {
                                          isAssetView: d.isAssetView,
                                          referenceName: d.currentToken.name,
                                          referenceSymbol: d.currentToken.symbol,
                                          validationMode: StatusInput.ValidationMode.Always,
                                          collectible: d.currentToken
                                      },
                                      StackView.Immediate)
                }
            } else console.warn("Mint Token Settings - Trying to retry undefined token object.")
        }
    }

    onSecondaryHeaderButtonClicked: {
        if(root.state == d.tokenViewState)
            deleteTokenAlertPopup.open()
    }

    StackViewStates {
        id: stackManager

        stackView: root.contentItem
    }

    // Mint tokens possible view contents:
    Component {
        id: welcomeView

        CommunityWelcomeSettingsView {
            viewWidth: root.viewWidth
            image: Style.png("community/mint2_1")
            title: qsTr("Community tokens")
            subtitle: qsTr("You can mint custom tokens and import tokens for your community")
            checkersModel: [
                qsTr("Create remotely destructible soulbound tokens for admin permissions"),
                qsTr("Reward individual members with custom tokens for their contribution"),
                qsTr("Mint tokens for use with community and channel permissions")
            ]
        }
    }

    Component {
        id: newTokenView

        ColumnLayout {
            id: colLayout

            property CollectibleObject collectible: CollectibleObject{}
            property AssetObject asset: AssetObject{}
            property bool isAssetView: false
            property int validationMode: StatusInput.ValidationMode.OnlyWhenDirty
            property string referenceName: ""
            property string referenceSymbol: ""

            width: root.viewWidth
            spacing: Style.current.padding

            StatusSwitchTabBar {
                id: optionsTab

                Layout.preferredWidth: root.viewWidth
                currentIndex: colLayout.isAssetView ? 1 : 0

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

                CustomCommunityNewTokenView {
                    id: newCollectibleView

                    isAssetView: false
                    validationMode: !colLayout.isAssetView ? colLayout.validationMode : StatusInput.ValidationMode.OnlyWhenDirty
                    collectible: colLayout.collectible
                    referenceName: colLayout.referenceName
                    referenceSymbol: colLayout.referenceSymbol
                }

                CustomCommunityNewTokenView {
                    id: newAssetView

                    isAssetView: true
                    validationMode: colLayout.isAssetView ? colLayout.validationMode : StatusInput.ValidationMode.OnlyWhenDirty
                    asset: colLayout.asset
                    referenceName: colLayout.referenceName
                    referenceSymbol: colLayout.referenceSymbol
                }

                component CustomCommunityNewTokenView: CommunityNewTokenView {
                    isAssetView: false
                    viewWidth: root.viewWidth
                    layer1Networks: root.layer1Networks
                    layer2Networks: root.layer2Networks
                    testNetworks: root.testNetworks
                    enabledNetworks: root.testNetworks
                    allNetworks: root.allNetworks
                    accounts: root.accounts
                    tokensModel: root.tokensModel

                    onPreviewClicked: {
                        stackManager.push(d.previewTokenViewState,
                                          previewTokenView,
                                          {
                                              preview: true,
                                              isAssetView,
                                              asset,
                                              collectible
                                          },
                                          StackView.Immediate)
                    }
                }
            }

            Binding {
                target: root
                property: "title"
                value: optionsTab.currentItem == collectiblesTab ? d.newCollectiblePageTitle : d.newAssetPageTitle
                restoreMode: Binding.RestoreBindingOrValue
            }
        }
    }

    Component {
        id: previewTokenView

        CommunityTokenView {
            id: preview

            function signMintTransaction() {
                root.setFeeLoading()
                if(preview.isAssetView)
                    root.mintAsset(asset)
                else
                    root.mintCollectible(collectible)

                root.resetNavigation()
            }

            viewWidth: root.viewWidth

            onMintClicked: signMintPopup.open()

            Binding {
                target: root
                property: "title"
                value: preview.name
            }

            Binding {
                target: root
                property: "subTitle"
                value: preview.symbol
                restoreMode: Binding.RestoreBindingOrValue
            }

            SignTokenTransactionsPopup {
                id: signMintPopup

                anchors.centerIn: Overlay.overlay
                title: qsTr("Sign transaction - Mint %1 token").arg(signMintPopup.tokenName)
                tokenName: preview.name
                accountName: preview.accountName
                networkName: preview.chainName
                feeText: root.feeText
                errorText: root.errorText
                isFeeLoading: root.isFeeLoading

                onOpened: {
                    root.setFeeLoading()
                    root.signMintTransactionOpened(preview.chainId, preview.accountAddress)
                }
                onCancelClicked: close()
                onSignTransactionClicked: preview.signMintTransaction()
            }
        }
    }

    Component {
        id: mintTokenFooter

        MintTokensFooterPanel {
            id: footerPanel

            readonly property bool deployStateFailed : (!!d.currentToken) ? d.currentToken.deployState === Constants.ContractTransactionStatus.Failed : false

            function closePopups() {
                remotelyDestructPopup.close()
                alertPopup.close()
                signTransactionPopup.close()
                burnTokensPopup.close()
            }

            airdropEnabled: !deployStateFailed
            remotelyDestructEnabled: !deployStateFailed
            burnEnabled: !deployStateFailed

            remotelyDestructVisible: d.remotelyDestruct
            burnVisible: d.burnVisible

            onAirdropClicked: d.airdropClicked()
            onRemotelyDestructClicked: remotelyDestructPopup.open()
            onBurnClicked: burnTokensPopup.open()

            RemotelyDestructPopup {
                id: remotelyDestructPopup

                collectibleName: root.title
                model: d.tokenOwnersModel
                destroyOnClose: false

                onRemotelyDestructClicked: {
                    d.remotelyDestructTokensList = remotelyDestructTokensList
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

                function signTransaction() {
                    root.setFeeLoading()
                    if(signTransactionPopup.isRemotelyDestructTransaction) {
                        root.remotelyDestructCollectibles(d.remotelyDestructTokensList, d.tokenKey)
                    } else {
                        root.burnToken(d.tokenKey, d.burnAmount)
                    }

                    footerPanel.closePopups()
                }

                title: signTransactionPopup.isRemotelyDestructTransaction ? qsTr("Sign transaction - Self-destruct %1 tokens").arg(root.title) :
                                                                            qsTr("Sign transaction - Burn %1 tokens").arg(root.title)
                tokenName: root.title
                accountName: d.accountName
                networkName: d.chainName
                feeText: root.feeText
                isFeeLoading: root.isFeeLoading
                errorText: root.errorText

                onOpened: {
                    root.setFeeLoading()
                    signTransactionPopup.isRemotelyDestructTransaction ? root.signRemoteDestructTransactionOpened(d.remotelyDestructTokensList, d.tokenKey) :
                                                                         root.signBurnTransactionOpened(d.tokenKey, d.burnAmount)
                }
                onCancelClicked: close()
                onSignTransactionClicked: signTransaction()
            }

            BurnTokensPopup {
                id: burnTokensPopup

                communityName: root.communityName
                tokenName: root.title
                remainingTokens: d.remainingTokens
                tokenSource: d.artworkSource

                onBurnClicked: {
                    d.burnAmount = burnAmount
                    signTransactionPopup.isRemotelyDestructTransaction = false
                    signTransactionPopup.open()
                }
            }

            Connections {
                target: d

                function onRemoteDestructAddressClicked(address) {
                    remotelyDestructPopup.open()
                    // TODO: set the address selected in the popup's list
                }
            }
        }
    }

    Component {
        id: mintedTokensView

        CommunityMintedTokensView {
            viewWidth: root.viewWidth
            model: root.tokensModel
            onItemClicked: {
                d.chainId = chainId
                d.chainName = chainName
                d.accountName = accountName
                d.tokenKey = tokenKey
                stackManager.push(d.tokenViewState,
                                  tokenView,
                                  {
                                      preview: false,
                                      tokenKey
                                  },
                                  StackView.Immediate)
            }
        }
    }

    Component {
        id: tokenView

        CommunityTokenView {
            id: view

            property string airdropKey // TO REMOVE: Temporal property until airdrop backend is not ready to use token key instead of symbol
            property int tokenType

            viewWidth: root.viewWidth
            collectible: CollectibleObject{}
            asset: AssetObject{}

            Binding {
                target: root
                property: "title"
                value: view.name
            }

            Binding {
                target: root
                property: "subTitle"
                value: view.symbol
                restoreMode: Binding.RestoreBindingOrValue
            }

            Binding {
                target: root
                property: "primaryHeaderButton.visible"
                value: view.deployState === Constants.ContractTransactionStatus.Failed
            }

            Binding {
                target: root
                property: "primaryHeaderButton.text"
                value: (view.deployState === Constants.ContractTransactionStatus.Failed) ? qsTr("Retry mint") : ""
            }

            Binding {
                target: root
                property: "secondaryHeaderButton.visible"
                value: view.deployState === Constants.ContractTransactionStatus.Failed
            }

            Binding {
                target: root
                property: "secondaryHeaderButton.text"
                value: (view.deployState === Constants.ContractTransactionStatus.Failed) ? qsTr("Delete") : ""
            }

            Binding {
                target: d
                property: "tokenOwnersModel"
                value: view.tokenOwnersModel
            }

            Binding {
                target: d
                property: "remotelyDestruct"
                value: view.collectible.remotelyDestruct
            }

            Binding {
                target: d
                property: "burnVisible"
                value: !view.infiniteSupply
                restoreMode: Binding.RestoreBindingOrValue
            }

            Binding {
                target: d
                property: "remainingTokens"
                value: view.remainingTokens
            }

            Binding {
                target: d
                property: "artworkSource"
                value: view.artworkSource
            }

            Binding {
                target: d
                property: "isAssetView"
                value: view.tokenType === Constants.TokenType.ERC20
            }

            Binding {
                target: d
                property: "currentToken"
                value: view.isAssetView ? view.asset : view.collectible
            }

            Instantiator {
                id: instantiator

                model: SortFilterProxyModel {
                    sourceModel: root.tokensModel
                    filters: ValueFilter {
                        roleName: "contractUniqueKey"
                        value: d.tokenKey
                    }
                }
                delegate: QtObject {
                    component Bind: Binding { target: view }
                    readonly property list<Binding> bindings: [
                        Bind { property: "isAssetView"; value: model.tokenType === Constants.TokenType.ERC20 },
                        Bind { property: "tokenOwnersModel"; value: model.tokenOwnersModel },
                        Bind { property: "tokenType"; value: model.tokenType },
                        Bind { property: "airdropKey"; value: model.symbol } // TO BE REMOVED: When airdrop backend is ready to use token key instead of symbol
                    ]

                    component BindCollectible: Binding { target: view.collectible }
                    readonly property list<Binding> collectibleBindings: [
                        BindCollectible { property: "key"; value: model.contractUniqueKey },
                        BindCollectible { property: "deployState"; value: model.deployState },
                        BindCollectible { property: "burnState"; value: model.burnState },
                        BindCollectible { property: "name"; value: model.name },
                        BindCollectible { property: "artworkSource"; value: model.image },
                        BindCollectible { property: "symbol"; value: model.symbol },
                        BindCollectible { property: "description"; value: model.description },
                        BindCollectible { property: "supply"; value: model.supply },
                        BindCollectible { property: "infiniteSupply"; value: model.infiniteSupply },
                        BindCollectible { property: "remainingTokens"; value: model.remainingSupply },
                        BindCollectible { property: "chainId"; value: model.chainId },
                        BindCollectible { property: "chainName"; value: model.chainName },
                        BindCollectible { property: "chainIcon"; value: model.chainIcon },
                        BindCollectible { property: "accountName"; value: model.accountName },
                        BindCollectible { property: "accountAddress"; value: model.accountAddress }, // TODO: Backend
                        BindCollectible { property: "transferable"; value: model.transferable },
                        BindCollectible { property: "remotelyDestructState"; value: model.remotelyDestructState },
                        BindCollectible { property: "remotelyDestruct"; value: model.remoteSelfDestruct }
                    ]

                    component BindAsset: Binding { target: view.asset }
                    readonly property list<Binding> assetBindings: [
                        BindAsset { property: "key"; value: model.contractUniqueKey },
                        BindAsset { property: "deployState"; value: model.deployState },
                        BindAsset { property: "burnState"; value: model.burnState },
                        BindAsset { property: "name"; value: model.name },
                        BindAsset { property: "artworkSource"; value: model.image },
                        BindAsset { property: "symbol"; value: model.symbol },
                        BindAsset { property: "description"; value: model.description },
                        BindAsset { property: "supply"; value: model.supply },
                        BindAsset { property: "infiniteSupply"; value: model.infiniteSupply },
                        BindAsset { property: "remainingTokens"; value: model.remainingSupply },
                        BindAsset { property: "chainId"; value: model.chainId },
                        BindAsset { property: "chainName"; value: model.chainName },
                        BindAsset { property: "chainIcon"; value: model.chainIcon },
                        BindAsset { property: "accountName"; value: model.accountName },
                        BindCollectible { property: "accountAddress"; value: model.accountAddress }, // TODO: Backend
                        BindAsset { property: "decimals"; value: model.decimals }
                    ]
                }
            }

            onGeneralAirdropRequested: {
                root.airdropToken(view.airdropKey, view.tokenType, []) // d.tokenKey instead when backend airdrop ready to use key instead of symbol
            }

            onAirdropRequested: {
                root.airdropToken(view.airdropKey, view.tokenType, [address]) // d.tokenKey instead when backend airdrop ready to use key instead of symbol
            }

            onRemoteDestructRequested: {
                d.remoteDestructAddressClicked(address)
            }

            Connections {
                target: d

                // handle airdrop request from the footer
                function onAirdropClicked() {
                    root.airdropToken(view.airdropKey, // d.tokenKey instead when backend airdrop ready to use key instead of symbol
                                      view.tokenType, 
                                      [])
                }
            }
        }
    }

    AlertPopup {
        id: deleteTokenAlertPopup

        width: 521
        title: qsTr("Delete %1").arg(root.title)
        acceptBtnText: qsTr("Delete %1 token").arg(root.title)
        alertText: qsTr("%1 is not yet minted, are you sure you want to delete it? All data associated with this token including its icon and description will be permanently deleted.").arg(root.title)

        onAcceptClicked: {
            root.deleteToken(d.tokenKey)
            root.resetNavigation()
        }
        onCancelClicked: close()
    }
}
