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

import shared.controls 1.0

import utils 1.0
import shared.popups 1.0
import SortFilterProxyModel 0.2

StackView {
    id: root

    // General properties:
    property int viewWidth: 560 // by design
    property string previousPageName: depth > 1 ? qsTr("Back") : ""
    required property string communityName
    required property string communityLogo
    required property color communityColor

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
    property var tokensModelWallet
    property var accounts // Expected roles: address, name, color, emoji, walletType

    // Transaction related properties:
    property string feeText
    property string feeErrorText
    property bool isFeeLoading: true

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

    signal deployFeesRequested(int chainId, string accountAddress, int tokenType)
    signal burnFeesRequested(string tokenKey, string amount, string accountAddress)
    signal remotelyDestructFeesRequest(var walletsAndAmounts, // { [walletAddress (string), amount (int)] }
                                       string tokenKey,
                                       string accountAddress)
    signal remotelyDestructCollectibles(var walletsAndAmounts, // { [walletAddress (string), amount (int)] }
                                        string tokenKey,
                                        string accountAddress)
    signal signBurnTransactionOpened(string tokenKey, string amount, string accountAddress)
    signal burnToken(string tokenKey, string amount, string accountAddress)
    signal airdropToken(string tokenKey, string amount, int type, var addresses)
    signal deleteToken(string tokenKey)

    function setFeeLoading() {
        root.isFeeLoading = true
        root.feeText = ""
        root.feeErrorText = ""
    }

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

                onMintClicked: signMintPopup.open()

                onDeployFeesRequested: root.deployFeesRequested(
                                           ownerToken.chainId,
                                           ownerToken.accountAddress,
                                           Constants.TokenType.ERC721)

                feeText: root.feeText
                feeErrorText: root.feeErrorText
                isFeeLoading: root.isFeeLoading

                SignMultiTokenTransactionsPopup {
                    id: signMintPopup

                    title: qsTr("Sign transaction - Mint %1 tokens").arg(
                               editOwnerTokenView.communityName)
                    totalFeeText: root.isFeeLoading ?
                                      "" : root.feeText
                    errorText: root.feeErrorText
                    accountName: editOwnerTokenView.ownerToken.accountName

                    model: QtObject {
                        readonly property string title: editOwnerTokenView.feeLabel
                        readonly property string feeText: signMintPopup.totalFeeText
                        readonly property bool error: root.feeErrorText !== ""
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

            property TokenObject asset: TokenObject{
                type: Constants.TokenType.ERC20
                multiplierIndex: 18
            }

            property TokenObject collectible: TokenObject {
                type: Constants.TokenType.ERC721
            }

            property bool isAssetView: false
            property int validationMode: StatusInput.ValidationMode.OnlyWhenDirty
            property string referenceName: ""
            property string referenceSymbol: ""

            title: optionsTab.currentItem === assetsTab
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

                    currentIndex: optionsTab.currentItem === collectiblesTab ? 0 : 1

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
                        enabledNetworks: root.enabledNetworks
                        allNetworks: root.allNetworks
                        accounts: root.accounts
                        tokensModel: root.tokensModel
                        tokensModelWallet: root.tokensModelWallet

                        referenceName: newTokenPage.referenceName
                        referenceSymbol: newTokenPage.referenceSymbol

                        feeText: root.feeText
                        feeErrorText: root.feeErrorText
                        isFeeLoading: root.isFeeLoading

                        onPreviewClicked: {
                            const properties = {
                                token: isAssetView ? asset : collectible
                            }

                            root.push(previewTokenViewComponent, properties,
                                      StackView.Immediate)
                        }

                        onDeployFeesRequested: {
                            if (isAssetView)
                                root.deployFeesRequested(asset.chainId,
                                                         asset.accountAddress,
                                                         Constants.TokenType.ERC20)
                            else
                                root.deployFeesRequested(collectible.chainId,
                                                         collectible.accountAddress,
                                                         Constants.TokenType.ERC721)
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

                feeText: root.feeText
                feeErrorText: root.feeErrorText
                isFeeLoading: root.isFeeLoading
                accounts: root.accounts

                onDeployFeesRequested: root.deployFeesRequested(
                                           token.chainId, token.accountAddress,
                                           token.type)

                onMintClicked: signMintPopup.open()

                function signMintTransaction() {
                    root.setFeeLoading()

                    if(preview.isAssetView)
                        root.mintAsset(token)
                    else
                        root.mintCollectible(token)

                    root.resetNavigation()
                }

                SignMultiTokenTransactionsPopup {
                    id: signMintPopup

                    title: qsTr("Sign transaction - Mint %1 token").arg(
                               preview.token.name)
                    totalFeeText: root.isFeeLoading ? "" : root.feeText
                    accountName: preview.token.accountName

                    model: QtObject {
                        readonly property string title: preview.feeLabel
                        readonly property string feeText: signMintPopup.totalFeeText
                        readonly property bool error: root.feeErrorText !== ""
                    }

                    onSignTransactionClicked: preview.signMintTransaction()
                }
            }
        }
    }

    component TokenViewPage: SettingsPage {
        id: tokenViewPage

        readonly property alias token: view.token
        readonly property bool deploymentFailed: view.deployState === Constants.ContractTransactionStatus.Failed

        property alias tokenOwnersModel: view.tokenOwnersModel
        property alias airdropKey: view.airdropKey

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

            property string airdropKey // TO REMOVE: Temporal property until airdrop backend is not ready to use token key instead of symbol

            viewWidth: root.viewWidth

            token: TokenObject {}

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

            onRemoteDestructRequested: {
                if (token.isPrivilegedToken) {
                    tokenMasterActionPopup.openPopup(
                                TokenMasterActionPopup.ActionType.RemotelyDestruct, name)
                } else {
                    remotelyDestructPopup.open()
                    // TODO: set the address selected in the popup's list
                }
            }

            onViewProfileRequested: {
                Global.openProfilePopup(contactId)
            }
            onViewMessagesRequested: {
                // TODO: https://github.com/status-im/status-desktop/issues/11860
                console.warn("View Messages is not implemented yet")
            }

            onBanRequested: {
                if (token.isPrivilegedToken)
                    tokenMasterActionPopup.openPopup(
                                TokenMasterActionPopup.ActionType.Ban, name)
                else
                    kickBanPopup.openPopup(KickBanPopup.Mode.Ban, name, contactId)
            }

            onKickRequested: {
                if (token.isPrivilegedToken)
                    tokenMasterActionPopup.openPopup(
                                TokenMasterActionPopup.ActionType.Kick, name)
                else
                    kickBanPopup.openPopup(KickBanPopup.Mode.Kick, name, contactId)
            }

            TokenMasterActionPopup {
                id: tokenMasterActionPopup

                communityName: root.communityName
                networkName: view.token.chainName

                accountsModel: root.accounts

                function openPopup(type, userName) {
                    tokenMasterActionPopup.actionType = type
                    tokenMasterActionPopup.userName = userName
                    open()
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

            visible: {
                if(tokenViewPage.isOwnerTokenItem)
                    // Always hidden
                    return false
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

            remotelyDestructVisible: token.remotelyDestruct
            burnVisible: !token.infiniteSupply

            onAirdropClicked: root.airdropToken(
                                  view.airdropKey,
                                  "1" + "0".repeat(view.token.multiplierIndex),
                                  view.token.type, [])

            onRemotelyDestructClicked: remotelyDestructPopup.open()
            onBurnClicked: burnTokensPopup.open()

            // helper properties to pass data through popups
            property var walletsAndAmounts
            property string burnAmount
            property string accountAddress

            RemotelyDestructPopup {
                id: remotelyDestructPopup

                collectibleName: view.token.name
                model: view.tokenOwnersModel || null
                accounts: root.accounts
                chainName: view.token.chainName

                feeText: root.feeText                
                isFeeLoading: root.isFeeLoading
                feeErrorText: root.feeErrorText

                onRemotelyDestructFeesRequested: {
                    root.remotelyDestructFeesRequest(walletsAndAmounts,
                                                     view.token.key,
                                                     accountAddress)
                }

                onRemotelyDestructClicked: {
                    remotelyDestructPopup.close()
                    footer.accountAddress = accountAddress
                    footer.walletsAndAmounts = walletsAndAmounts
                    alertPopup.open()
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

            SignTokenTransactionsPopup {
                id: signTransactionPopup

                property bool isRemotelyDestructTransaction
                readonly property string tokenKey: tokenViewPage.token.key

                function signTransaction() {
                    root.setFeeLoading()

                    if(signTransactionPopup.isRemotelyDestructTransaction)
                        root.remotelyDestructCollectibles(footer.walletsAndAmounts,
                                                          tokenKey, footer.accountAddress)
                    else
                        root.burnToken(tokenKey, footer.burnAmount, footer.accountAddress)

                    footer.closePopups()
                }

                title: signTransactionPopup.isRemotelyDestructTransaction
                       ? qsTr("Sign transaction - Self-destruct %1 tokens").arg(tokenName)
                       : qsTr("Sign transaction - Burn %1 tokens").arg(tokenName)

                tokenName: footer.token.name
                accountName: footer.token.accountName
                networkName: footer.token.chainName
                feeText: root.feeText
                isFeeLoading: root.isFeeLoading
                errorText: root.feeErrorText

                onOpened: {
                    root.setFeeLoading()

                    signTransactionPopup.isRemotelyDestructTransaction
                            ? root.remotelyDestructFeesRequest(footer.walletsAndAmounts, tokenKey, footer.accountAddress)
                            : root.signBurnTransactionOpened(tokenKey, footer.burnAmount, footer.accountAddress)
                }
                onSignTransactionClicked: signTransaction()
            }

            BurnTokensPopup {
                id: burnTokensPopup

                communityName: root.communityName
                tokenName: footer.token.name
                remainingTokens: footer.token.remainingTokens
                multiplierIndex: footer.token.multiplierIndex
                tokenSource: footer.token.artworkSource
                chainName: footer.token.chainName

                feeText: root.feeText
                feeErrorText: root.feeErrorText
                isFeeLoading: root.isFeeLoading
                accounts: root.accounts

                onBurnFeesRequested: root.burnFeesRequested(footer.token.key, burnAmount, accountAddress)

                onBurnClicked: {
                    burnTokensPopup.close()
                    footer.burnAmount = burnAmount
                    footer.accountAddress = accountAddress
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
                }

                onCountChanged: {
                    if (count === 0)
                        root.navigateBack()
                }
            }
        }
    }
}
