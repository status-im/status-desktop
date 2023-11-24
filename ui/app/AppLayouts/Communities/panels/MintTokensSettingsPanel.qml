import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml 2.15

import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Utils 0.1 as SQUtils

import AppLayouts.Communities.controls 1.0
import AppLayouts.Communities.helpers 1.0
import AppLayouts.Communities.layouts 1.0
import AppLayouts.Communities.popups 1.0
import AppLayouts.Communities.views 1.0
import AppLayouts.Wallet.helpers 1.0

import shared.controls 1.0

import utils 1.0
import shared.popups 1.0
import SortFilterProxyModel 0.2

StackView {
    id: root

    // General properties:
    property int viewWidth: 560 // by design
    property string previousPageName: depth > 1 ? qsTr("Back") : ""
    required property string communityId
    required property string communityName
    required property string communityLogo
    required property color communityColor
    property var sendModalPopup

    // User profile props:
    required property bool isOwner
    required property bool isTokenMasterOwner
    required property bool isAdmin
    readonly property bool isAdminOnly: root.isAdmin && !root.isPrivilegedTokenOwnerProfile
    readonly property bool isPrivilegedTokenOwnerProfile: root.isOwner || root.isTokenMasterOwner

    // Owner and TMaster token related properties:
    readonly property bool arePrivilegedTokensDeployed: root.isOwnerTokenDeployed && root.isTMasterTokenDeployed
    property bool isOwnerTokenDeployed: false
    property bool isTMasterTokenDeployed: false
    property bool anyPrivilegedTokenFailed: false

    // It will monitorize if Owner and/or TMaster token items are included in the `tokensModel` despite the deployment state
    property bool ownerOrTMasterTokenItemsExist: false

    // Models:
    property var tokensModel
    property var accounts // Expected roles: address, name, color, emoji, walletType
    required property var referenceAssetsBySymbolModel


    // Network related properties:
    property var layer1Networks
    property var layer2Networks
    property var enabledNetworks
    property var allNetworks

    signal mintCollectible(var collectibleItem)
    signal mintAsset(var assetItem)
    signal mintOwnerToken(var ownerToken, var tMasterToken)

    signal kickUserRequested(string contactId)
    signal banUserRequested(string contactId)
    signal remotelyDestructCollectibles(var walletsAndAmounts, // { [walletAddress (string), amount (int)] }
                                        string tokenKey,
                                        string accountAddress)

    signal remotelyDestructAndBan(string contactId, string tokenKey, string accountAddress,
                                  bool removeMessages)
    signal remotelyDestructAndKick(string contactId, string tokenKey, string accountAddress)

    signal burnToken(string tokenKey, string amount, string accountAddress)
    signal airdropToken(string tokenKey, string amount, int type, var addresses)
    signal deleteToken(string tokenKey)
    signal registerDeployFeesSubscriber(var feeSubscriber)
    signal registerSelfDestructFeesSubscriber(var feeSubscriber)
    signal registerBurnTokenFeesSubscriber(var feeSubscriber)

    function navigateBack() {
        pop(StackView.Immediate)
    }

    function resetNavigation() {
        pop(initialItem, StackView.Immediate)
    }

    // This method will be called from the outsite from a different section like Airdrop or Permissions
    function openNewTokenForm(isAssetView) {
        resetNavigation()

        if(root.isAdminOnly) {
            // Admins can only see the initial tokens page. They cannot mint. Initial view.
            return
        }

        if(root.arePrivilegedTokensDeployed) {
            // Regular minting flow for Owner and TMaster owner, selecting the specific tab
            const properties = { isAssetView }
            root.push(newTokenViewComponent, properties, StackView.Immediate)
            return
        }

        if(root.ownerOrTMasterTokenItemsExist) {
            // Owner and TMaster tokens deployment action has been started at least ones but still without success. Initial view.
            return
        }

        if(root.isOwner) {
            // Owner and TMaster tokens to be deployed. Never tried.
            root.push(ownerTokenViewComponent, StackView.Immediate)
            return
        }
    }

    QtObject {
        id: d

        // Owner or TMaster token retry navigation
        function retryPrivilegedToken(key, chainId, accountName, accountAddress) {
            var properties = {
                key: key,
                chainId: chainId,
                accountName: accountName,
                accountAddress: accountAddress,
            }

            root.push(ownerTokenEditViewComponent, properties,
                      StackView.Immediate)
        }
    }

    initialItem: SettingsPage {
        implicitWidth: 0
        title: qsTr("Tokens")

        buttons: [
            DisabledTooltipButton {
                readonly property bool buttonEnabled: root.isPrivilegedTokenOwnerProfile && root.arePrivilegedTokensDeployed

                buttonType: DisabledTooltipButton.Normal
                aliasedObjectName: "addNewItemButton"
                text: qsTr("Mint token")
                enabled: root.isAdminOnly || buttonEnabled
                interactive: buttonEnabled
                onClicked: root.push(newTokenViewComponent, StackView.Immediate)
                tooltipText: qsTr("In order to mint, you must hodl the TokenMaster token for %1").arg(root.communityName)
            }
        ]

        contentItem: MintedTokensView {
            model: SortFilterProxyModel {
                sourceModel: root.tokensModel
                proxyRoles: ExpressionRole {
                    name: "color"
                    expression: root.communityColor
                }
            }
            isOwner: root.isOwner
            isAdmin: root.isAdmin
            communityName: root.communityName
            communityId: root.communityId
            anyPrivilegedTokenFailed: root.anyPrivilegedTokenFailed

            onItemClicked: root.push(tokenViewComponent, { tokenKey }, StackView.Immediate)
            onMintOwnerTokenClicked: root.push(ownerTokenViewComponent, StackView.Immediate)
            onRetryOwnerTokenClicked: d.retryPrivilegedToken(tokenKey, chainId, accountName, accountAddress)
        }
    }

    Component {
        id: tokenObjectComponent

        TokenObject {}
    }

    // Mint tokens possible view contents:
    Component {
        id: ownerTokenViewComponent

        SettingsPage {
            id: ownerTokenPage

            title: qsTr("Mint Owner token")

            contentItem: OwnerTokenWelcomeView {
                viewWidth: root.viewWidth
                communityLogo: root.communityLogo
                communityColor: root.communityColor
                communityName: root.communityName

                onNextClicked: root.push(ownerTokenEditViewComponent, StackView.Immediate)
            }
        }
    }

    Component {
        id: ownerTokenEditViewComponent

        SettingsPage {
            id: ownerTokenPage

            property int chainId
            property string accountName
            property string accountAddress

            title: qsTr("Mint Owner token")

            contentItem: EditOwnerTokenView {
                id: editOwnerTokenView

                function signMintTransaction() {
                    root.mintOwnerToken(ownerToken, tMasterToken)
                    root.resetNavigation()
                }

                viewWidth: root.viewWidth

                communityLogo: root.communityLogo
                communityColor: root.communityColor
                communityName: root.communityName

                ownerToken.chainId: ownerTokenPage.chainId
                ownerToken.accountName: ownerTokenPage.accountName
                ownerToken.accountAddress: ownerTokenPage.accountAddress
                tMasterToken.chainId: ownerTokenPage.chainId
                tMasterToken.accountName: ownerTokenPage.accountName
                tMasterToken.accountAddress: ownerTokenPage.accountAddress

                layer1Networks: root.layer1Networks
                layer2Networks: root.layer2Networks
                enabledNetworks: root.enabledNetworks
                allNetworks: root.allNetworks
                accounts: root.accounts

                feeText: feeSubscriber.feeText
                feeErrorText: feeSubscriber.feeErrorText
                isFeeLoading: !feeSubscriber.feesResponse

                onMintClicked: signMintPopup.open()
                
                DeployFeesSubscriber {
                    id: feeSubscriber
                    communityId: root.communityId
                    chainId: editOwnerTokenView.ownerToken.chainId
                    tokenType: editOwnerTokenView.ownerToken.type
                    isOwnerDeployment: editOwnerTokenView.ownerToken.isPrivilegedToken
                    accountAddress: editOwnerTokenView.ownerToken.accountAddress
                    enabled: editOwnerTokenView.visible || signMintPopup.visible
                    Component.onCompleted: root.registerDeployFeesSubscriber(feeSubscriber)
                }

                SignTransactionsPopup {
                    id: signMintPopup

                    title: qsTr("Sign transaction - Mint %1 tokens").arg(
                               editOwnerTokenView.communityName)
                    totalFeeText: editOwnerTokenView.isFeeLoading ?
                                      "" : editOwnerTokenView.feeText
                    errorText: editOwnerTokenView.feeErrorText
                    accountName: editOwnerTokenView.ownerToken.accountName

                    model: QtObject {
                        readonly property string title: editOwnerTokenView.feeLabel
                        readonly property string feeText: signMintPopup.totalFeeText
                        readonly property bool error: editOwnerTokenView.feeErrorText !== ""
                    }

                    onSignTransactionClicked: editOwnerTokenView.signMintTransaction()
                }
            }
        }
    }

    Component {
        id: newTokenViewComponent

        SettingsPage {
            id: newTokenPage

            readonly property int ownerTokenChainId: SQUtils.ModelUtils.get(root.tokensModel, "privilegesLevel", Constants.TokenPrivilegesLevel.Owner).chainId ?? 0
            readonly property var chainModel: NetworkModelHelpers.getLayerNetworkModelByChainId(root.layer1Networks,
                                                                                                root.layer2Networks,
                                                                                                ownerTokenChainId) ?? root.layer2Networks
            readonly property int chainIndex: NetworkModelHelpers.getChainIndexByChainId(root.layer1Networks,
                                                                                         root.layer2Networks,
                                                                                         ownerTokenChainId)
            readonly property string chainName: NetworkModelHelpers.getChainName(chainModel, chainIndex)
            readonly property string chainIcon: NetworkModelHelpers.getChainIconUrl(chainModel, chainIndex)

            property TokenObject asset: TokenObject{
                type: Constants.TokenType.ERC20
                multiplierIndex: 18

                // Minted tokens will use ALWAYS the same chain where the owner token was deployed.
                chainId: newTokenPage.ownerTokenChainId
                chainName: newTokenPage.chainName
                chainIcon: newTokenPage.chainIcon
            }

            property TokenObject collectible: TokenObject {
                type: Constants.TokenType.ERC721

                // Minted tokens will use ALWAYS the same chain where the owner token was deployed.
                chainId: newTokenPage.ownerTokenChainId
                chainName: newTokenPage.chainName
                chainIcon: newTokenPage.chainIcon
            }



            property bool isAssetView: false
            property int validationMode: StatusInput.ValidationMode.OnlyWhenDirty
            property string referenceName: ""
            property string referenceSymbol: ""

            title: qsTr("Mint token")

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

                    currentIndex: optionsTab.currentItem === collectiblesTab ? 0 : 1

                    CustomEditCommunityTokenView {
                        id: newCollectibleView

                        isAssetView: false
                        validationMode: !newTokenPage.isAssetView
                                        ? newTokenPage.validationMode
                                        : StatusInput.ValidationMode.OnlyWhenDirty
                        token: newTokenPage.collectible
                    }

                    CustomEditCommunityTokenView {
                        id: newAssetView

                        isAssetView: true
                        validationMode: newTokenPage.isAssetView
                                        ? newTokenPage.validationMode
                                        : StatusInput.ValidationMode.OnlyWhenDirty
                        token: newTokenPage.asset
                    }

                    component CustomEditCommunityTokenView: EditCommunityTokenView {
                        id: editView

                        viewWidth: root.viewWidth
                        layer1Networks: root.layer1Networks
                        layer2Networks: root.layer2Networks
                        accounts: root.accounts
                        tokensModel: root.tokensModel
                        referenceAssetsBySymbolModel: root.referenceAssetsBySymbolModel

                        referenceName: newTokenPage.referenceName
                        referenceSymbol: newTokenPage.referenceSymbol

                        feeText: deployFeeSubscriber.feeText
                        feeErrorText: deployFeeSubscriber.feeErrorText
                        isFeeLoading: !deployFeeSubscriber.feesResponse

                        onPreviewClicked: {
                            const properties = {
                                token: token
                            }

                            root.push(previewTokenViewComponent, properties,
                                      StackView.Immediate)
                        }

                        DeployFeesSubscriber {
                            id: deployFeeSubscriber
                            communityId: root.communityId
                            chainId: editView.token.chainId
                            tokenType: editView.token.type
                            isOwnerDeployment: editView.token.isPrivilegedToken
                            accountAddress: editView.token.accountAddress
                            enabled: editView.visible
                            Component.onCompleted: root.registerDeployFeesSubscriber(deployFeeSubscriber)
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

                viewWidth: root.viewWidth
                preview: true

                accounts: root.accounts
                feeText: feeSubscriber.feeText
                feeErrorText: feeSubscriber.feeErrorText
                isFeeLoading: !feeSubscriber.feesResponse

                onMintClicked: signMintPopup.open()

                function signMintTransaction() {
                    if(preview.isAssetView)
                        root.mintAsset(token)
                    else
                        root.mintCollectible(token)

                    root.resetNavigation()
                }

                DeployFeesSubscriber {
                    id: feeSubscriber
                    communityId: root.communityId
                    chainId: preview.token.chainId
                    tokenType: preview.token.type
                    isOwnerDeployment: preview.token.isPrivilegedToken
                    accountAddress: preview.token.accountAddress
                    enabled: preview.visible || signMintPopup.visible
                    Component.onCompleted: root.registerDeployFeesSubscriber(feeSubscriber)
                }

                SignTransactionsPopup {
                    id: signMintPopup

                    title: qsTr("Sign transaction - Mint %1 token").arg(
                               preview.token.name)
                    totalFeeText: preview.isFeeLoading ? "" : preview.feeText
                    accountName: preview.token.accountName

                    model: QtObject {
                        readonly property string title: preview.feeLabel
                        readonly property string feeText: signMintPopup.totalFeeText
                        readonly property bool error: preview.feeErrorText !== ""
                    }

                    onSignTransactionClicked: preview.signMintTransaction()
                }
            }
        }
    }

    component TokenViewPage: SettingsPage {
        id: tokenViewPage

        property TokenObject token: TokenObject {}
        readonly property bool deploymentFailed: view.deployState === Constants.ContractTransactionStatus.Failed

        property var tokenOwnersModel
        property string airdropKey
        // Owner and TMaster related props
        readonly property bool isPrivilegedTokenItem: isOwnerTokenItem || isTMasterTokenItem
        readonly property bool isOwnerTokenItem: token.privilegesLevel === Constants.TokenPrivilegesLevel.Owner
        readonly property bool isTMasterTokenItem: token.privilegesLevel === Constants.TokenPrivilegesLevel.TMaster

        title: view.name
        subtitle: view.symbol

        buttons: [
            StatusButton {
                text: qsTr("Delete")
                type: StatusBaseButton.Type.Danger

                visible: (!tokenViewPage.isPrivilegedTokenItem) && !root.isAdminOnly && tokenViewPage.deploymentFailed

                onClicked: deleteTokenAlertPopup.open()
            },
            StatusButton {
                function retryAssetOrCollectible() {
                    // https://bugreports.qt.io/browse/QTBUG-91917
                    var isAssetView = tokenViewPage.token.type === Constants.TokenType.ERC20

                    // Copy TokenObject
                    var tokenObject = tokenObjectComponent.createObject(null, view.token)

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

                    // Cleanup dynamically created TokenObject
                    tokenView.Component.destruction.connect(() => tokenObject.destroy())
                }

                text: qsTr("Retry mint")

                visible: (tokenViewPage.isPrivilegedTokenItem && root.isOwner && tokenViewPage.deploymentFailed) ||
                         (!tokenViewPage.isPrivilegedTokenItem && !root.isAdminOnly && tokenViewPage.deploymentFailed)

                onClicked: {
                    if(tokenViewPage.isPrivilegedTokenItem) {
                        d.retryPrivilegedToken(view.token.key, view.token.chainId, view.token.accountName, view.token.accountAddress)
                    } else {
                        retryAssetOrCollectible()
                    }
                }
            }
        ]

        contentItem: CommunityTokenView {
            id: view

            property string airdropKey: tokenViewPage.airdropKey // TO REMOVE: Temporal property until airdrop backend is not ready to use token key instead of symbol

            viewWidth: root.viewWidth

            token: tokenViewPage.token
            tokenOwnersModel: tokenViewPage.tokenOwnersModel

            onGeneralAirdropRequested: {
                root.airdropToken(view.airdropKey,
                                  "1" + "0".repeat(view.token.multiplierIndex),
                                  view.token.type, []) // tokenKey instead when backend airdrop ready to use key instead of symbol
            }

            onAirdropRequested: {
                root.airdropToken(view.airdropKey,
                                  "1" + "0".repeat(view.token.multiplierIndex),
                                  view.token.type, [address]) // tokenKey instead when backend airdrop ready to use key instead of symbol
            }

            onViewProfileRequested: {
                Global.openProfilePopup(contactId)
            }

            onViewMessagesRequested: {
                // TODO: https://github.com/status-im/status-desktop/issues/11860
                console.warn("View Messages is not implemented yet")
            }

            onRemoteDestructRequested: {
                if (token.isPrivilegedToken) {
                    tokenMasterActionPopup.openPopup(
                                TokenMasterActionPopup.ActionType.RemotelyDestruct,
                                name, address, "")
                } else {
                    remotelyDestructPopup.open()
                    // TODO: set the address selected in the popup's list
                }
            }

            onBanRequested: {
                if (token.isPrivilegedToken)
                    tokenMasterActionPopup.openPopup(
                                TokenMasterActionPopup.ActionType.Ban, name,
                                address, contactId)
                else
                    kickBanPopup.openPopup(KickBanPopup.Mode.Ban, name, contactId)
            }

            onKickRequested: {
                if (token.isPrivilegedToken)
                    tokenMasterActionPopup.openPopup(
                                TokenMasterActionPopup.ActionType.Kick, name,
                                address, contactId)
                else
                    kickBanPopup.openPopup(KickBanPopup.Mode.Kick, name, contactId)
            }

            TokenMasterActionPopup {
                id: tokenMasterActionPopup

                property string address: ""
                property string contactId: ""

                communityName: root.communityName
                networkName: view.token.chainName

                accountsModel: root.accounts
                feeText: selfDestructFeesSubscriber.feeText
                feeErrorText: selfDestructFeesSubscriber.feeErrorText
                isFeeLoading: !selfDestructFeesSubscriber.feesResponse

                function openPopup(type, userName, address, contactId) {
                    tokenMasterActionPopup.actionType = type
                    tokenMasterActionPopup.userName = userName ||
                            SQUtils.Utils.elideAndFormatWalletAddress(address)
                    tokenMasterActionPopup.address = address
                    tokenMasterActionPopup.contactId = contactId
                    open()
                }

                onRemotelyDestructClicked: signPopup.open()
                onKickClicked: signPopup.open()
                onBanClicked: signPopup.open()

                SelfDestructFeesSubscriber {
                    id: selfDestructFeesSubscriber

                    walletsAndAmounts: [{ 
                        walletAddress: tokenMasterActionPopup.address, 
                        amount: 1
                    }]
                    accountAddress: tokenMasterActionPopup.selectedAccount
                    tokenKey: view.token.key
                    enabled: tokenMasterActionPopup.opened
                    Component.onCompleted: root.registerSelfDestructFeesSubscriber(
                                               selfDestructFeesSubscriber)
                }

                SignTransactionsPopup {
                    id: signPopup

                    title: qsTr("Sign transaction - Remotely-destruct TokenMaster token")

                    totalFeeText: tokenMasterActionPopup.feeText
                    errorText: tokenMasterActionPopup.feeErrorText

                    accountName: tokenMasterActionPopup.selectedAccountName

                    model: QtObject {
                        readonly property string title: tokenMasterActionPopup.feeLabel
                        readonly property string feeText: tokenMasterActionPopup.feeText
                        readonly property bool error: tokenMasterActionPopup.feeErrorText !== ""
                    }

                    onSignTransactionClicked: {
                        // https://bugreports.qt.io/browse/QTBUG-91917
                        var contactId = tokenMasterActionPopup.contactId
                        var tokenKey = tokenViewPage.token.key
                        var accountAddress = tokenMasterActionPopup.selectedAccount

                        switch (tokenMasterActionPopup.actionType) {
                        case TokenMasterActionPopup.ActionType.RemotelyDestruct:
                            var tokenToDestruct = {
                                walletAddress: tokenMasterActionPopup.address,
                                amount: 1
                            }

                            root.remotelyDestructCollectibles(
                                        [tokenToDestruct],
                                        tokenKey, accountAddress)
                            break
                        case TokenMasterActionPopup.ActionType.Kick:
                            root.remotelyDestructAndKick(contactId, tokenKey,
                                                         accountAddress)
                            break
                        case TokenMasterActionPopup.ActionType.Ban:
                            root.remotelyDestructAndBan(contactId, tokenKey,
                                                        accountAddress,
                                                        tokenMasterActionPopup.deleteMessages)
                            break
                        }

                        tokenMasterActionPopup.close()
                    }
                }
            }

            KickBanPopup {
                id: kickBanPopup

                property string contactId

                communityName: root.communityName

                onAccepted: {
                    if (mode === KickBanPopup.Mode.Kick)
                        root.kickUserRequested(contactId)
                    else
                        root.banUserRequested(contactId)
                }

                function openPopup(mode, userName, contactId) {
                    kickBanPopup.mode = mode
                    kickBanPopup.username = userName
                    kickBanPopup.contactId = contactId
                    open()
                }
            }
        }

        footer: MintTokensFooterPanel {
            id: footer

            readonly property TokenObject token: view.token
            readonly property bool isAssetView: view.isAssetView

            readonly property bool deployStateCompleted: token.deployState === Constants.ContractTransactionStatus.Completed

            function closePopups() {
                remotelyDestructPopup.close()
                alertPopup.close()
                signTransactionPopup.close()
                burnTokensPopup.close()
            }

            communityName: root.communityName
            visible: {
                if(tokenViewPage.isTMasterTokenItem)
                    // Only footer if owner profile
                    return root.isOwner
                // Always present
                return true
            }
            airdropEnabled: deployStateCompleted &&
                            (token.infiniteSupply ||
                             token.remainingTokens > 0)

            remotelyDestructEnabled: deployStateCompleted &&
                                     !!view.tokenOwnersModel &&
                                     view.tokenOwnersModel.count > 0

            burnEnabled: deployStateCompleted            
            sendOwnershipEnabled: deployStateCompleted

            sendOwnershipVisible: tokenViewPage.isOwnerTokenItem
            airdropVisible: !tokenViewPage.isOwnerTokenItem
            remotelyDestructVisible: !tokenViewPage.isOwnerTokenItem && token.remotelyDestruct
            burnVisible: !tokenViewPage.isOwnerTokenItem && !token.infiniteSupply

            onAirdropClicked: root.airdropToken(
                                  view.airdropKey,
                                  "1" + "0".repeat(view.token.multiplierIndex),
                                  view.token.type, [])

            onRemotelyDestructClicked: remotelyDestructPopup.open()
            onBurnClicked: burnTokensPopup.open()
            onSendOwnershipClicked: Global.openTransferOwnershipPopup(root.communityId,
                                                                      root.communityName,
                                                                      root.communityLogo,
                                                                      tokenViewPage.token,
                                                                      root.accounts,
                                                                      root.sendModalPopup)

            // helper properties to pass data through popups
            property var walletsAndAmounts
            property string burnAmount
            property string accountAddress

            RemotelyDestructPopup {
                id: remotelyDestructPopup

                property alias feeSubscriber: remotelyDestructFeeSubscriber

                collectibleName: view.token.name
                model: view.tokenOwnersModel || null
                accounts: root.accounts
                chainName: view.token.chainName   

                feeText: remotelyDestructFeeSubscriber.feeText
                feeErrorText: remotelyDestructFeeSubscriber.feeErrorText
                isFeeLoading: !remotelyDestructFeeSubscriber.feesResponse          
                
                onRemotelyDestructClicked: {
                    remotelyDestructPopup.close()
                    footer.accountAddress = accountAddress
                    footer.walletsAndAmounts = walletsAndAmounts
                    alertPopup.open()
                }

                SelfDestructFeesSubscriber {
                    id: remotelyDestructFeeSubscriber

                    walletsAndAmounts: remotelyDestructPopup.selectedWalletsAndAmounts
                    accountAddress: remotelyDestructPopup.selectedAccount
                    tokenKey: view.token.key
                    enabled: remotelyDestructPopup.tokenCount > 0 && accountAddress !== "" && (remotelyDestructPopup.opened || signTransactionPopup.opened)
                    Component.onCompleted: root.registerSelfDestructFeesSubscriber(remotelyDestructFeeSubscriber)
                }
            }

            BurnTokensPopup {
                id: burnTokensPopup

                property alias feeSubscriber: burnTokensFeeSubscriber

                communityName: root.communityName
                tokenName: footer.token.name
                remainingTokens: footer.token.remainingTokens
                multiplierIndex: footer.token.multiplierIndex
                tokenSource: footer.token.artworkSource
                chainName: footer.token.chainName

                onAmountToBurnChanged: burnTokensFeeSubscriber.updateAmount()

                feeText: burnTokensFeeSubscriber.feeText
                feeErrorText: burnTokensFeeSubscriber.feeErrorText
                isFeeLoading: burnTokensFeeSubscriber.feeText === "" && burnTokensFeeSubscriber.feeErrorText === ""
                accounts: root.accounts

                onBurnClicked: {
                    burnTokensPopup.close()
                    footer.burnAmount = burnAmount
                    footer.accountAddress = accountAddress
                    signTransactionPopup.isRemotelyDestructTransaction = false
                    signTransactionPopup.open()
                }

                BurnTokenFeesSubscriber {
                    id: burnTokensFeeSubscriber

                    readonly property var updateAmount: Backpressure.debounce(burnTokensFeeSubscriber, 500, () => {
                        burnTokensFeeSubscriber.amount = burnTokensPopup.amountToBurn
                    })
                    amount: ""
                    tokenKey: tokenViewPage.token.key
                    accountAddress: burnTokensPopup.selectedAccountAddress
                    enabled: burnTokensPopup.visible || signTransactionPopup.visible
                    Component.onCompleted: root.registerBurnTokenFeesSubscriber(burnTokensFeeSubscriber)
                }
            }

            AlertPopup {
                id: alertPopup

                title: qsTr("Remotely destruct %n token(s)", "",
                            remotelyDestructPopup.tokenCount)
                acceptBtnText: qsTr("Remotely destruct")
                alertText: qsTr("Continuing will destroy tokens held by members and revoke any permissions they are given. To undo you will have to issue them new tokens.")

                onAcceptClicked: {
                    signTransactionPopup.isRemotelyDestructTransaction = true
                    signTransactionPopup.open()
                }
            }

            SignTransactionsPopup {
                id: signTransactionPopup

                property bool isRemotelyDestructTransaction

                readonly property string tokenName: footer.token.name

                title: isRemotelyDestructTransaction
                       ? qsTr("Sign transaction - Remotely destruct %1 token").arg(tokenName)
                       : qsTr("Sign transaction - Burn %1 tokens").arg(tokenName)

                accountName: footer.token.accountName

                totalFeeText: isRemotelyDestructTransaction
                              ? remotelyDestructPopup.feeText
                              : burnTokensPopup.feeText

                errorText: isRemotelyDestructTransaction
                           ? remotelyDestructPopup.feeErrorText
                           : burnTokensPopup.feeErrorText

                model: QtObject {
                    readonly property string title:
                        signTransactionPopup.isRemotelyDestructTransaction
                        ? qsTr("Remotely destruct %Ln %1 token(s) on %2", "",
                               remotelyDestructPopup.tokenCount)
                          .arg(remotelyDestructPopup.collectibleName)
                          .arg(remotelyDestructPopup.chainName)
                        : burnTokensPopup.feeLabel
                    readonly property string feeText: signTransactionPopup.totalFeeText
                    readonly property bool error: signTransactionPopup.errorText !== ""
                }

                onSignTransactionClicked: {
                    if(signTransactionPopup.isRemotelyDestructTransaction)
                        root.remotelyDestructCollectibles(footer.walletsAndAmounts,
                                                          tokenKey, footer.accountAddress)
                    else
                        root.burnToken(tokenKey, footer.burnAmount, footer.accountAddress)

                    footer.closePopups()
                }
            }
        }

        AlertPopup {
            id: deleteTokenAlertPopup

            readonly property string tokenName: view.token.name

            width: 521
            title: qsTr("Delete %1").arg(tokenName)
            acceptBtnText: qsTr("Delete %1 token").arg(tokenName)
            alertText: qsTr("%1 is not yet minted, are you sure you want to delete it? All data associated with this token including its icon and description will be permanently deleted.").arg(tokenName)

            onAcceptClicked: {
                root.deleteToken(tokenViewPage.token.key)
                root.navigateBack()
            }
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
                    required property var model
                    implicitWidth: 0
                    anchors.fill: parent

                    tokenOwnersModel: model.tokenOwnersModel
                    airdropKey: model.symbol // TO BE REMOVED: When airdrop backend is ready to use token key instead of symbol

                    token.privilegesLevel: model.privilegesLevel
                    token.color: root.communityColor
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
                    token.burnState: model.burnState
                    token.remotelyDestructState: model.remotelyDestructState
                    token.accountAddress: model.accountAddress
                    token.multiplierIndex: model.multiplierIndex
                    token.tokenAddress: model.tokenAddress
                }

                onCountChanged: {
                    if (count === 0)
                        root.navigateBack()
                }
            }
        }
    }
}
