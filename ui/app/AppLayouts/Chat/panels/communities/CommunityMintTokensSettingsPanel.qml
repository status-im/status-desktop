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

import utils 1.0
import SortFilterProxyModel 0.2

SettingsPageLayout {
    id: root

    // Models:
    property var tokensModel

    property string feeText
    property string errorText
    property bool isFeeLoading: true

    // Network related properties:
    property var layer1Networks
    property var layer2Networks
    property var testNetworks
    property var enabledNetworks
    property var allNetworks

    // Account expected roles: address, name, color, emoji
    property var accounts

    property string communityName

    property int viewWidth: 560 // by design

    signal mintCollectible(url artworkSource,
                           string name,
                           string symbol,
                           string description,
                           int supply,
                           bool infiniteSupply,
                           bool transferable,
                           bool selfDestruct,
                           int chainId,
                           string accountName,
                           string accountAddress,
                           var artworkCropRect)

    signal mintAsset(url artworkSource,
                     string name,
                     string symbol,
                     string description,
                     int supply,
                     bool infiniteSupply,
                     int decimals,
                     int chainId,
                     string accountName,
                     string accountAddress,
                     var artworkCropRect)

    signal signMintTransactionOpened(int chainId, string accountAddress)

    signal signSelfDestructTransactionOpened(var selfDestructTokensList, // [key , amount]
                                             string tokenKey)

    signal remoteSelfDestructCollectibles(var selfDestructTokensList, // [key , amount]
                                          string tokenKey)

    signal signBurnTransactionOpened(int chainId)

    signal burnCollectibles(string tokenKey,
                            int amount)

    signal airdropCollectible(string tokenKey)

    signal deleteToken(string tokenKey)

    signal retryMintToken(string tokenKey)

    function setFeeLoading() {
        root.isFeeLoading = true
        root.feeText = ""
        root.errorText = ""
    }

    function navigateBack() {
        stackManager.pop(StackView.Immediate)
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

        property string accountAddress
        property string accountName
        property int chainId
        property string chainName
        property string contractUniqueKey

        property var tokenOwnersModel
        property var selfDestructTokensList
        property bool selfDestruct
        property bool burnEnabled
        property string tokenKey
        property int burnAmount
        property int remainingTokens
        property url artworkSource

        readonly property var initialItem: (root.tokensModel && root.tokensModel.count > 0) ? mintedTokensView : welcomeView
        onInitialItemChanged: updateInitialStackView()

        signal airdropClicked()

        signal retryMintClicked()

        function updateInitialStackView() {
            if(stackManager.stackView) {
                if(initialItem === welcomeView)
                    stackManager.stackView.replace(mintedTokensView, welcomeView, StackView.Immediate)
                if(initialItem === mintedTokensView)
                    stackManager.stackView.replace(welcomeView, mintedTokensView, StackView.Immediate)
            }
        }
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
        if(root.state == d.initialViewState)
            stackManager.push(d.newTokenViewState, newTokenView, null, StackView.Immediate)
        if(root.state == d.tokenViewState)
            d.retryMintClicked()
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
            width: root.viewWidth
            spacing: Style.current.padding

            StatusSwitchTabBar {
                id: optionsTab

                Layout.preferredWidth: root.viewWidth

                StatusSwitchTabButton {
                    id: collectiblesTab

                    text: qsTr("Collectibles")
                }

                StatusSwitchTabButton {
                    id: assetsTab

                    text: qsTr("Assets")
                }

                Binding {
                    target: root
                    property: "title"
                    value: optionsTab.currentItem === collectiblesTab ? d.newCollectiblePageTitle : d.newAssetPageTitle
                }
            }

            StackLayout {
                Layout.preferredWidth: root.viewWidth
                Layout.fillHeight: true

                currentIndex: optionsTab.currentItem === collectiblesTab ? 0 : 1

                CommunityNewTokenView {
                    viewWidth: root.viewWidth
                    layer1Networks: root.layer1Networks
                    layer2Networks: root.layer2Networks
                    testNetworks: root.testNetworks
                    enabledNetworks: root.testNetworks
                    allNetworks: root.allNetworks
                    accounts: root.accounts
                    tokensModel: root.tokensModel

                    onPreviewClicked: {
                        d.accountAddress = accountAddress
                        stackManager.push(d.previewTokenViewState,
                                          previewTokenView,
                                          {
                                              preview: true,
                                              isAssetView: false,
                                              name,
                                              artworkSource,
                                              artworkCropRect,
                                              symbol,
                                              description,
                                              supplyAmount,
                                              infiniteSupply,
                                              transferable: !notTransferable,
                                              selfDestruct,
                                              chainId,
                                              chainName,
                                              chainIcon,
                                              accountName
                                          },
                                          StackView.Immediate)
                    }
                }

                CommunityNewTokenView {
                    viewWidth: root.viewWidth
                    layer1Networks: root.layer1Networks
                    layer2Networks: root.layer2Networks
                    testNetworks: root.testNetworks
                    enabledNetworks: root.testNetworks
                    allNetworks: root.allNetworks
                    accounts: root.accounts
                    tokensModel: root.tokensModel
                    isAssetView: true

                    onPreviewClicked: {
                        d.accountAddress = accountAddress
                        stackManager.push(d.previewTokenViewState,
                                          previewTokenView,
                                          {
                                              preview: true,
                                              isAssetView: true,
                                              name,
                                              artworkSource,
                                              artworkCropRect,
                                              symbol,
                                              description,
                                              supplyAmount,
                                              infiniteSupply,
                                              assetDecimals,
                                              chainId,
                                              chainName,
                                              chainIcon,
                                              accountName
                                          },
                                          StackView.Immediate)
                    }
                }
            }
        }
    }

    Component {
        id: previewTokenView

        CommunityTokenView {
            id: preview

            function signMintTransaction() {
                root.setFeeLoading()
                if(preview.isAssetView) {
                    root.mintAsset(artworkSource,
                                   name,
                                   symbol,
                                   description,
                                   supplyAmount,
                                   infiniteSupply,
                                   assetDecimals,
                                   chainId,
                                   accountName,
                                   d.accountAddress,
                                   artworkCropRect)
                } else {
                    root.mintCollectible(artworkSource,
                                         name,
                                         symbol,
                                         description,
                                         supplyAmount,
                                         infiniteSupply,
                                         transferable,
                                         selfDestruct,
                                         chainId,
                                         accountName,
                                         d.accountAddress,
                                         artworkCropRect)
                }

                stackManager.clear(d.initialViewState, StackView.Immediate)
            }

            viewWidth: root.viewWidth

            onMintCollectible: popup.open()
            onMintAsset: popup.open()

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
                id: popup

                anchors.centerIn: Overlay.overlay
                title: qsTr("Sign transaction - Mint %1 token").arg(popup.tokenName)
                tokenName: preview.name
                accountName: preview.accountName
                networkName: preview.chainName
                feeText: root.feeText
                errorText: root.errorText
                isFeeLoading: root.isFeeLoading

                onOpened: {
                    root.setFeeLoading()
                    root.signMintTransactionOpened(preview.chainId, d.accountAddress)
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

            function closePopups() {
                remotelyDestructPopup.close()
                alertPopup.close()
                signTransactionPopup.close()
            }

            airdropEnabled: true
            retailEnabled: false
            remotelySelfDestructVisible: d.selfDestruct
            burnVisible: d.burnEnabled

            onAirdropClicked: d.airdropClicked()
            onRemotelyDestructClicked: remotelyDestructPopup.open()
            onBurnClicked: burnTokensPopup.open()

            RemotelyDestructPopup {
                id: remotelyDestructPopup

                collectibleName: root.title
                model: d.tokenOwnersModel

                onRemotelyDestructClicked: {
                    d.selfDestructTokensList = selfDestructTokensList
                    alertPopup.tokenCount = tokenCount
                    alertPopup.open()
                }
            }

            AlertPopup {
                id: alertPopup

                property int tokenCount

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
                        root.remoteSelfDestructCollectibles(d.selfDestructTokensList, d.tokenKey)
                    } else {
                        root.burnCollectibles(d.tokenKey, d.burnAmount)
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
                    signTransactionPopup.isRemotelyDestructTransaction ? root.signSelfDestructTransactionOpened(d.selfDestructTokensList, d.tokenKey) :
                                                                         root.signBurnTransactionOpened(d.chainId)
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
        }
    }

    Component {
        id: mintedTokensView

        CommunityMintedTokensView {
            viewWidth: root.viewWidth
            model: root.tokensModel
            onItemClicked: {
                d.accountAddress = accountAddress
                d.chainId = chainId
                d.chainName = chainName
                d.accountName = accountName
                d.tokenKey = contractUniqueKey
                stackManager.push(d.tokenViewState,
                                  tokenView,
                                  {
                                      preview: false,
                                      contractUniqueKey
                                  },
                                  StackView.Immediate)
            }

            Connections {
                target: d

                function onRetryMintClicked() {
                    root.retryMintToken(d.tokenKey)
                    stackManager.clear(d.initialViewState, StackView.Immediate)
                }
            }
        }
    }

    Component {
        id: tokenView

        CommunityTokenView {
            id: view

            property string contractUniqueKey

            viewWidth: root.viewWidth

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
                property: "selfDestruct"
                value: view.selfDestruct
            }

            Binding {
                target: d
                property: "burnEnabled"
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

            Instantiator {
                id: instantiator

                model: SortFilterProxyModel {
                    sourceModel: root.tokensModel
                    filters: ValueFilter {
                        roleName: "contractUniqueKey"
                        value: view.contractUniqueKey
                    }
                }
                delegate: QtObject {
                    component Bind: Binding { target: view }
                    readonly property list<Binding> bindings: [
                        Bind { property: "isAssetView"; value: model.tokenType === Constants.TokenType.ERC20 },
                        Bind { property: "deployState"; value: model.deployState },
                        Bind { property: "remotelyDestructState"; value: model.remotelyDestructState },
                        Bind { property: "burnState"; value: model.burnState },
                        Bind { property: "name"; value: model.name },
                        Bind { property: "artworkSource"; value: model.image },
                        Bind { property: "symbol"; value: model.symbol },
                        Bind { property: "description"; value: model.description },
                        Bind { property: "supplyAmount"; value: model.supply },
                        Bind { property: "infiniteSupply"; value: model.infiniteSupply },
                        Bind { property: "remainingTokens"; value: model.remainingTokens },
                        Bind { property: "selfDestruct"; value: model.remoteSelfDestruct },
                        Bind { property: "chainId"; value: model.chainId },
                        Bind { property: "chainName"; value: model.chainName },
                        Bind { property: "chainIcon"; value: model.chainIcon },
                        Bind { property: "accountName"; value: model.accountName },
                        Bind { property: "tokenOwnersModel"; value: model.tokenOwnersModel },
                        Bind { property: "assetDecimals"; value: model.decimals }
                    ]
                }
            }

            Connections {
                target: d

                function onAirdropClicked() {
                    root.airdropCollectible(view.symbol) // TODO: Backend. It should just be the key (hash(chainId + contractAddress)
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
            stackManager.clear(d.initialViewState, StackView.Immediate)
        }
        onCancelClicked: close()
    }
}
