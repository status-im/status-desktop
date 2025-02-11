import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as SQUtils
import StatusQ.Popups.Dialog 0.1
import StatusQ.Core.Backpressure 0.1

import shared.popups.send.views 1.0 as SendViews
import shared.controls 1.0

import AppLayouts.Wallet.panels 1.0
import AppLayouts.Wallet.controls 1.0
import AppLayouts.Wallet.views 1.0
import AppLayouts.Wallet 1.0

import utils 1.0

StatusDialog {
    id: root

    /**
    Expected model structure:
    - name: name of account
    - address: wallet address
    - color: color of the account
    - emoji: emoji selected for the account
    - currencyBalance: total currency balance in CurrencyAmount
    - accountBalance: balance of selected token + selected chain
    **/
    required property var accountsModel
    /**
    Expected model structure:
    - tokensKey: unique string ID of the token (asset); e.g. "ETH" or contract address
    - name: user visible token name (e.g. "Ethereum")
    - symbol: user visible token symbol (e.g. "ETH")
    - decimals: number of decimal places
    - communityId:optional; ID of the community this token belongs to, if any
    - marketDetails: object containing props like `currencyPrice` for the computed values below
    - balances: submodel[ chainId:int, account:string, balance:BigIntString, iconUrl:string ]
    - currentBalance: amount of tokens
    - currencyBalance: e.g. `1000.42` in user's fiat currency
    - currencyBalanceAsString: e.g. "1 000,42 CZK" formatted as a string according to the user's locale
    - balanceAsString: `1.42` formatted as e.g. "1,42" in user's locale
    - iconSource: string
    **/
    required property var assetsModel
    /**
    Expected model structure:
    - groupName: group name (from collection or community name)
    - icon: from imageUrl or mediaUrl
    - type: can be "community" or "other"
    - subitems: submodel of collectibles/collections of the group
    - key: key of collection (community type) or collectible (other type)
    - name: name of the subitem (of collectible or collection)
    - balance: balance of collection (in case of community collectibles)
               or collectible (in case of ERC-1155)
    - icon: icon of the subitem
    **/
    required property var collectiblesModel
    /**
      This model is needed here not to be used in any visual item but
      to evaluate the collectible selected by using the selectedTokenKey.
      To do this with the grouped and nested collectiblesModel is very
      complex and is adding unnecessary edge cases that need to be handled
      expicity.
      This model should be already filtered by account and chainId selected
      Expected model structure:

        symbol              [string] - unique identifier of a collectible
        chainId             [int] - unique identifier of a network
        collectionUid       [string] - unique identifier of a collection
        contractAddress     [string] - collectible's contract address
        name                [string] - collectible's name e.g. "Magicat"
        collectionName      [string] - collection name e.g. "Crypto Kitties"
        mediaUrl            [url]    - collectible's media url
        imageUrl            [url]    - collectible's image url
        communityId         [string] - unique identifier of a community for community collectible or empty
        ownership           [model]  - submodel of balances per chain/account
            balance         [int]    - balance (always 1 for ERC-721)
            accountAddress  [string] - unique identifier of an account
    **/
    required property var flatCollectiblesModel
    /**
    Expected model structure:
    - chainId: network chain id
    - chainName: name of network
    - iconUrl: network icon url
    Only networks valid as per mainnet/testnet selection
    **/
    required property var networksModel

    /**
    Expected model structure (both models):
    - addres: wallet unique address
    - name: (optional) wallet name
    - color: (optional) wallet icon color
    - colorId: (optional) wallet icon color id
    - emoji: (optional) wallet icon emoji
    - ens: (optional) wallet ens address
    **/
    required property var recipientsModel
    required property var recipientsFilterModel

    /** Input property holds currently selected Fiat currency **/
    required property string currentCurrency
    /** Input function to format currency amount to locale string **/
    required property var fnFormatCurrencyAmount

    /** input property to decide if send modal is interactive or prefilled **/
    property bool interactive: true
    /** input property to show only ERC20 assets and no collectibles **/
    property bool displayOnlyAssets

    /** input property true if a community owner token is being transferred **/
    property bool transferOwnership

    /** input property to decide if routes are being fetched **/
    property bool routesLoading

    /** input property to set estimated time **/
    property string estimatedTime
    /** input property to set estimated fees in fiat **/
    property string estimatedFiatFees
    /** input property to set estimated fees in crypto **/
    property string estimatedCryptoFees
    /** input property to set router error title **/
    property string routerError: ""
    /** input property to set router error details **/
    property string routerErrorDetails: ""
    /** input property to set router error code **/
    property string routerErrorCode

    /** property to set currently selected send type **/
    property int sendType: Constants.SendType.Transfer
    /** property to set and expose currently selected account **/
    property string selectedAccountAddress
    /** property to set and expose currently selected network **/
    property int selectedChainId
    /** property to set and expose currently selected token key **/
    property string selectedTokenKey
    /** property to set and expose the raw amount to send from outside without any localization
    Crypto value in a base unit as a string integer,
    e.g. 1000000000000000000 for 1 ETH **/
    property string selectedRawAmount

    /** Input / Output property to set and expose currently selected recipient address **/
    property alias selectedRecipientAddress: recipientsPanel.selectedRecipientAddress
    /** Output property to indicate currently selected recipient view tab **/
    readonly property alias selectedRecipientType: recipientsPanel.selectedRecipientType
    /** Output property to filter recipient model **/
    readonly property alias recipientSearchPattern: recipientsPanel.searchPattern

    /** input property holds the publicKey of the user for registering an ENS name **/
    property string publicKey
    /** input property holds the selected ens name to be registered **/
    property string ensName
    /** input property holds the selected sticker pack id to purchase **/
    property string stickersPackId

    /** property to check if the form is filled correctly **/
    readonly property bool allValuesFilledCorrectly: !!root.selectedAccountAddress &&
                                                     root.selectedChainId !== 0 &&
                                                     !!root.selectedTokenKey &&
                                                     !!root.selectedRecipientAddress &&
                                                     !!root.selectedRawAmount &&
                                                     !amountToSend.markAsInvalid &&
                                                     amountToSend.valid

    /** Input function to resolve Ens Name **/
    required property var fnResolveENS
    /** Output function to set resolved ens name values **/
    function ensNameResolved(resolvedPubKey, resolvedAddress, uuid) {
        recipientsPanel.ensNameResolved(resolvedPubKey, resolvedAddress, uuid)
    }

    /** Output signal to request signing of the transaction **/
    signal reviewSendClicked()
    /** Output signal to inform that the forms been updated **/
    signal formChanged()
    /** Output signal to launch buy flow **/
    signal launchBuyFlow()

    QtObject {
        id: d

        readonly property real scrollViewContentY: scrollView.flickable.contentY
        onScrollViewContentYChanged: {
            const buffer = sendModalHeader.height + scrollViewLayout.spacing
            if (scrollViewContentY > buffer) {
                d.stickyHeaderVisible = true
            } else if (scrollViewContentY === 0) {
                d.stickyHeaderVisible = false
            }
        }
        property bool stickyHeaderVisible: false

        // Used to get asset entry if selected token is an asset
        readonly property var selectedAssetEntry: ModelEntry {
            sourceModel: root.assetsModel
            key: "tokensKey"
            value: root.selectedTokenKey
            onItemChanged: d.setAssetInTokenSelector()
            onAvailableChanged: d.setAssetInTokenSelector()
        }

        // Holds if the asset entry is valid
        readonly property bool selectedAssetEntryValid: selectedAssetEntry.available &&
                                                        !!selectedAssetEntry.item

        // Used to set selected asset in token selector
        function setAssetInTokenSelector() {
            if(selectedAssetEntry.available && !!selectedAssetEntry.item) {
                d.setTokenOnBothHeaders(selectedAssetEntry.item.symbol,
                                        Constants.tokenIcon(selectedAssetEntry.item.symbol),
                                        selectedAssetEntry.item.tokensKey)
            }
        }

        // Used to get collectible entry if selected token is a collectible
        readonly property var selectedCollectibleEntry: ModelEntry {
            sourceModel: root.flatCollectiblesModel
            key: "symbol"
            value: root.selectedTokenKey
            onItemChanged: d.setCollectibleInTokenSelector()
            onAvailableChanged: d.setCollectibleInTokenSelector()
        }

        // Holds if the collectible entry is valid
        readonly property bool selectedCollectibleEntryValid: selectedCollectibleEntry.available &&
                                                              !!selectedCollectibleEntry.item

        /** Handling the case when an asset is selcted from dropdown
            to reset the harcoded "1" set for collectibles
        **/
        onSelectedCollectibleEntryValidChanged: {
            if(!selectedCollectibleEntryValid && root.selectedRawAmount === "1") {
                amountToSend.clear()
            }
        }

        // Used to set selected collectible in token selector
        function setCollectibleInTokenSelector() {
            if(selectedCollectibleEntry.available && !!selectedCollectibleEntry.item) {
                const id = selectedCollectibleEntry.item.communityId ?
                             selectedCollectibleEntry.item.collectionUid :
                             selectedCollectibleEntry.item.uid
                d.setTokenOnBothHeaders(selectedCollectibleEntry.item.name,
                                        selectedCollectibleEntry.item.imageUrl ||
                                        selectedCollectibleEntry.item.mediaUrl,
                                        id)
            }
        }

        // In case no token is found in the models, we reset the token selector
        readonly property bool noTokenSelected: !selectedAssetEntryValid && !selectedCollectibleEntryValid
        onNoTokenSelectedChanged: {
            if(noTokenSelected) {
                d.debounceResetTokenSelector()
            }
        }

        function setTokenOnBothHeaders(name, icon, key) {
            sendModalHeader.setToken(name, icon, key)
            stickySendModalHeader.setToken(name, icon, key)
        }

        readonly property var debounceResetTokenSelector: Backpressure.debounce(root, 200, function() {
            if(!selectedAssetEntryValid && !selectedCollectibleEntryValid) {
                // reset token selector in case selected tokens doesnt exist in either models
                d.setTokenOnBothHeaders("", "", "")
                root.selectedTokenKey = ""
            }
        })

        readonly property var debounceSetSelectedAmount: Backpressure.debounce(root, 1000, function() {
            if(amountToSend.amount !== "0" && amountToSend.amount !== root.selectedRawAmount)
                root.selectedRawAmount = amountToSend.amount
        })

        readonly property string selectedCryptoTokenSymbol: selectedAssetEntryValid ?
                                                                selectedAssetEntry.item.symbol:
                                                                selectedCollectibleEntryValid ?
                                                                    selectedCollectibleEntry.item.symbol: ""

        readonly property double maxSafeCryptoValue: {
            if (selectedCollectibleEntryValid) {
                let collectibleBalance =  SQUtils.ModelUtils.getByKey(selectedCollectibleEntry.item.ownership, "accountAddress", root.selectedAccountAddress, "balance")
                return !!collectibleBalance ? collectibleBalance: 0
            } else if (selectedAssetEntryValid) {
                const maxCryptoBalance = !!d.selectedAssetEntry.item.currentBalance ?
                                           d.selectedAssetEntry.item.currentBalance : 0
                return WalletUtils.calculateMaxSafeSendAmount(maxCryptoBalance, d.selectedCryptoTokenSymbol)
            }
            return 0
        }

        // handle multiple property changes from single changed signal
        property var combinedPropertyChangedHandler: [
            root.selectedAccountAddress,
            root.selectedChainId,
            root.selectedTokenKey,
            root.selectedRecipientAddress,
            root.selectedRawAmount,
            root.allValuesFilledCorrectly]
        onCombinedPropertyChangedHandlerChanged: Qt.callLater(() => root.formChanged())

        readonly property bool errNotEnoughGas: root.routerErrorCode === Constants.routerErrorCodes.router.errNotEnoughNativeBalance

        function setRawValue() {
            if(!!selectedRawAmount && (amountToSend.amount !== root.selectedRawAmount || amountToSend.empty)) {
                amountToSend.setRawValue(root.selectedRawAmount)
            }
        }

        function setSelectedCollectible(key) {
            const tokenType = SQUtils.ModelUtils.getByKey(root.flatCollectiblesModel, "symbol", key, "tokenType")
            if(tokenType === Constants.TokenType.ERC1155) {
                root.sendType =  Constants.SendType.ERC1155Transfer
            } else if(tokenType === Constants.TokenType.ERC721) {
                root.sendType =  Constants.SendType.ERC721Transfer
            }
            root.selectedRawAmount = "1"
            root.selectedTokenKey = key
            amountToSend.forceActiveFocus()
        }

        function setSelectedAsset(key) {
            root.sendType = Constants.SendType.Transfer
            root.selectedTokenKey = key
            amountToSend.forceActiveFocus()
        }
    }

    width: 556
    height: {
        if (!selectedRecipientAddress)
            return root.contentItem.Window.height - topMargin - margins
        let contentHeight = Math.max(sendModalHeader.height +
                                     amountToSend.height +
                                     recipientsPanelLayout.height +
                                     feesLayout.height +
                                     scrollViewLayout.spacing*3 +
                                     28,
                                     scrollView.implicitHeight) + footer.height

        if (!!footer.errorTags && !feesLayout.visible) {
            // Utilize empty space when fees are not visible and error is shown
            contentHeight -= feesLayout.height
        }
        return contentHeight
    }
    padding: 0
    horizontalPadding: Theme.xlPadding
    topMargin: margins + accountSelector.height + Theme.padding

    Behavior on height {
        enabled: !!root.selectedRecipientAddress
        NumberAnimation { duration: 100; easing: Easing.OutCurve }
    }

    background: StatusDialogBackground {
        color: Theme.palette.baseColor3
    }

    // Bindings needed for exposing and setting raw values from AmountToSend
    onSelectedRawAmountChanged: d.setRawValue()

    Item {
        id: sendModalcontentItem

        anchors.fill: parent
        anchors.top: parent.top

        implicitWidth: parent.width

        // Floating account Selector
        AccountSelectorHeader {
            id: accountSelector

            objectName: "accountSelector"

            anchors.top: parent.top
            anchors.topMargin: -accountSelector.height - Theme.padding
            anchors.left: parent.left
            anchors.leftMargin: -Theme.xlPadding

            model: root.accountsModel

            selectedAddress: root.selectedAccountAddress
            onCurrentAccountAddressChanged: {
                if(currentAccountAddress !== root.selectedAccountAddress) {
                    root.selectedAccountAddress = currentAccountAddress
                }
            }
        }

        // Sticky header only visible when scrolling
        Item {
            height: childrenRect.height + Theme.smallPadding
            anchors.top: accountSelector.bottom
            anchors.topMargin: Theme.padding
            anchors.left: parent.left
            anchors.leftMargin: -Theme.xlPadding
            anchors.right: parent.right
            anchors.rightMargin: -Theme.xlPadding

            clip: true
            z: 1

            StickySendModalHeader {
                id: stickySendModalHeader

                objectName: "stickySendModalHeader"

                width: parent.width
                blurSource: scrollView.contentItem

                stickyHeaderVisible: d.stickyHeaderVisible

                interactive: root.interactive && !root.transferOwnership
                displayOnlyAssets: root.displayOnlyAssets

                networksModel: root.networksModel
                assetsModel: root.assetsModel
                collectiblesModel: root.collectiblesModel

                selectedChainId: root.selectedChainId

                onCollectibleSelected: d.setSelectedCollectible(key)
                onCollectionSelected: d.setSelectedCollectible(key)
                onAssetSelected: d.setSelectedAsset(key)
                onNetworkSelected: root.selectedChainId = chainId
            }
        }

        // Main scrollable Layout
        StatusScrollView {
            id: scrollView

            objectName: "scrollView"

            anchors.fill: parent
            contentWidth: availableWidth

            padding: 0

            StatusScrollBar.vertical {
                id: verticalScrollbar

                parent: sendModalcontentItem
                x: sendModalcontentItem.width + root.rightPadding - verticalScrollbar.width
            }

            ColumnLayout {
                id: scrollViewLayout

                width: scrollView.availableWidth
                spacing: 20

                // Header that scrolls
                SendModalHeader {
                    id: sendModalHeader

                    objectName: "sendModalHeader"

                    Layout.fillWidth: true
                    Layout.topMargin: 28

                    isScrolling: d.stickyHeaderVisible
                    interactive: root.interactive && !root.transferOwnership
                    displayOnlyAssets: root.displayOnlyAssets

                    networksModel: root.networksModel
                    assetsModel: root.assetsModel
                    collectiblesModel: root.collectiblesModel

                    selectedChainId: root.selectedChainId

                    onCollectibleSelected: d.setSelectedCollectible(key)
                    onCollectionSelected: d.setSelectedCollectible(key)
                    onAssetSelected: d.setSelectedAsset(key)
                    onNetworkSelected: root.selectedChainId = chainId
                }

                // Amount to send entry
                SendViews.AmountToSend {
                    id: amountToSend

                    objectName: "amountToSend"

                    Layout.fillWidth: true

                    interactive: root.interactive
                    dividerVisible: true
                    bottomTextLoading: root.routesLoading

                    /** TODO: connect to max safe value for eth.
                        For now simply checking balance in case of both eth and other ERC20's **/
                    markAsInvalid: SQUtils.AmountsArithmetic.fromNumber(d.maxSafeCryptoValue, multiplierIndex).cmp(amount) === -1

                    selectedSymbol: amountToSend.fiatMode ?
                                        root.currentCurrency:
                                        d.selectedCryptoTokenSymbol
                    price: !!d.selectedAssetEntryValid &&
                           !!d.selectedAssetEntry.item.marketDetails ?
                               d.selectedAssetEntry.item.marketDetails.currencyPrice.amount : 1
                    multiplierIndex: !!d.selectedAssetEntryValid &&
                                     !!d.selectedAssetEntry.item.decimals ?
                                         d.selectedAssetEntry.item.decimals : 0
                    formatFiat: amount => root.fnFormatCurrencyAmount(
                                    amount, root.currentCurrency)
                    formatBalance: amount => root.fnFormatCurrencyAmount(
                                       amount, d.selectedCryptoTokenSymbol)

                    visible: d.selectedAssetEntryValid
                    onVisibleChanged: if(visible) forceActiveFocus()

                    onAmountChanged: d.debounceSetSelectedAmount()

                    bottomRightComponent: MaxSendButton {
                        id: maxButton

                        formattedValue: {
                            let maxSafeValue = amountToSend.fiatMode ? d.maxSafeCryptoValue * amountToSend.price : d.maxSafeCryptoValue
                            return root.fnFormatCurrencyAmount(
                                        maxSafeValue,
                                        amountToSend.selectedSymbol,
                                        { roundingMode: LocaleUtils.RoundingMode.Down
                                        })
                        }
                        markAsInvalid: amountToSend.markAsInvalid
                        /** TODO: Remove below customisations after
                        https://github.com/status-im/status-desktop/issues/15709
                        and make the button clickable **/
                        enabled: false
                        background: Rectangle {
                            radius: 20
                            color:  type === StatusBaseButton.Type.Danger ? Theme.palette.dangerColor3 : Theme.palette.primaryColor3
                        }
                        disabledTextColor: type === StatusBaseButton.Type.Danger ? Theme.palette.dangerColor1 : Theme.palette.primaryColor1
                    }
                }

                ColumnLayout {
                    id: recipientsPanelLayout

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    spacing: Theme.halfPadding

                    StatusBaseText {
                        elide: Text.ElideRight
                        text: qsTr("To")
                        Layout.alignment: Qt.AlignTop
                    }
                    Item {
                        Layout.alignment: Qt.AlignTop
                        Layout.fillWidth: true
                        Layout.bottomMargin: feesLayout.visible ? 0 : Theme.xlPadding
                        implicitHeight: recipientsPanel.height

                        Rectangle {
                            anchors {
                                top: recipientsPanel.top
                                left: recipientsPanel.left
                                right: recipientsPanel.right
                            }
                            // Imitate recipient background and overflow the rectangle under footer
                            height: recipientsPanel.emptyListVisible ? sendModalcontentItem.height : 0
                            color: recipientsPanel.color
                            radius: recipientsPanel.radius
                        }

                        RecipientSelectorPanel {
                            id: recipientsPanel

                            objectName: "recipientsPanel"

                            anchors {
                                top: parent.top
                                left: parent.left
                                right: parent.right
                            }

                            interactive: root.interactive

                            recipientsModel: root.recipientsModel
                            recipientsFilterModel: root.recipientsFilterModel

                            onResolveENS: root.fnResolveENS(ensName, uuid)
                        }
                    }
                }

                // Fees Component
                ColumnLayout {
                    id: feesLayout

                    objectName: "feesLayout"

                    Layout.fillWidth: true
                    Layout.bottomMargin: Theme.xlPadding

                    spacing: Theme.halfPadding

                    StatusBaseText {
                        elide: Text.ElideRight
                        text: qsTr("Fees")
                    }
                    SimpleTransactionsFees {
                        objectName: "signTransactionFees"

                        Layout.fillWidth: true

                        cryptoFees: root.estimatedCryptoFees
                        fiatFees: root.estimatedFiatFees
                        loading: root.routesLoading && root.allValuesFilledCorrectly
                        error: d.errNotEnoughGas
                    }
                    visible: root.allValuesFilledCorrectly
                }
            }
        }
    }

    footer: SendModalFooter {
        objectName: "sendModalFooter"

        width: root.width

        estimatedTime: root.estimatedTime
        estimatedFees: root.estimatedFiatFees

        blurSource: scrollView.contentItem
        blurSourceRect: Qt.rect(0, scrollView.height, width, height)

        error: d.errNotEnoughGas
        errorTags: amountToSend.markAsInvalid ||
                   !!root.routerErrorCode ||
                   !!root.routerError?
                       errorTagsModel: null

        loading: root.routesLoading && root.allValuesFilledCorrectly

        onReviewSendClicked: root.reviewSendClicked()
    }

    ObjectModel {
        id: errorTagsModel
        RouterErrorTag {
            errorTitle: qsTr("Insufficient funds for send transaction")
            buttonText: qsTr("Add assets")
            onButtonClicked: root.launchBuyFlow()

            visible: amountToSend.markAsInvalid
        }
        RouterErrorTag {
            errorTitle: root.routerError
            errorDetails: !d.errNotEnoughGas ?
                              root.routerErrorDetails: ""
            buttonText: qsTr("Add ETH")
            expandable: !d.errNotEnoughGas &&
                        !(!root.routerErrorCode &&
                          !!root.routerError)
            onButtonClicked: root.launchBuyFlow()

            visible: !!root.routerErrorCode || !!root.routerError
        }
    }
}
