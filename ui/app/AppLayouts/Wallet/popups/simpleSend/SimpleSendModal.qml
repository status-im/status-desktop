import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as SQUtils
import StatusQ.Popups.Dialog 0.1
import StatusQ.Core.Backpressure 0.1

import shared.popups.send.views 1.0
import shared.controls 1.0

import AppLayouts.Wallet.panels 1.0
import AppLayouts.Wallet.controls 1.0
import AppLayouts.Wallet.views 1.0
import AppLayouts.Wallet 1.0

import utils 1.0

StatusDialog {
    id: root

    /**
    TODO: use the newly defined WalletAccountsSelectorAdaptor
    in https://github.com/status-im/status-desktop/pull/16834
    This will also remove watch only accounts from the list
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
    Expected model structure:
    - chainId: network chain id
    - chainName: name of network
    - iconUrl: network icon url
    Only networks valid as per mainnet/testnet selection
    **/
    required property var networksModel

    /** Input property holds currently selected Fiat currency **/
    required property string currentCurrency
    /** Input function to format currency amount to locale string **/
    required property var fnFormatCurrencyAmount

    /** input property to decide if send modal is interactive or prefilled **/
    property bool interactive: true

    /** input property to decide if routes are being fetched **/
    property bool routesLoading

    /** input property to set estimated time **/
    property string estimatedTime
    /** input property to set estimated fees in fiat **/
    property string estimatedFiatFees
    /** input property to set estimated fees in crypto **/
    property string estimatedCryptoFees

    /** property to set currently selected send type **/
    property int sendType: Constants.SendType.Transfer
    /** property to set and expose currently selected account **/
    property string selectedAccountAddress
    /** property to set and expose currently selected network **/
    property int selectedChainId
    /** property to set and expose currently selected token key **/
    property string selectedTokenKey
    /** property to set and expose the amount to send from outside without any localization **/
    property string selectedAmount
    /** output property to set currently set amount to send
    Crypto value in a base unit as a string integer,
    e.g. 1000000000000000000 for 1 ETH **/
    readonly property string selectedAmountInBaseUnit: amountToSend.amount

    /** property to check if the form is filled correctly **/
    readonly property bool allValuesFilledCorrectly: !!root.selectedAccountAddress &&
                root.selectedChainId !== 0 &&
                !!root.selectedTokenKey &&
                !!root.selectedRecipientAddress &&
                !!root.selectedAmount &&
                !amountToSend.markAsInvalid &&
                amountToSend.valid

    /** TODO: replace with new and improved recipient selector StatusDateRangePicker
    TBD under https://github.com/status-im/status-desktop/issues/16916 **/
    required property var savedAddressesModel
    required property var recentRecipientsModel
    property alias selectedRecipientAddress: recipientsPanel.selectedRecipientAddress
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
        }

        // Used to get collectible entry if selected token is a collectible
        readonly property var selectedCollectibleEntry: ModelEntry {
            sourceModel: root.collectiblesModel
            key: "symbol"
            value: root.selectedTokenKey
        }

        /** exposes the currently selected token entry **/
        readonly property var selectedTokenEntry: selectedAssetEntry.available ?
                                             selectedAssetEntry.item :
                                             selectedCollectibleEntry.available ?
                                                 selectedCollectibleEntry.item: null
        onSelectedTokenEntryChanged: {
            if(!selectedAssetEntry.available && !selectedCollectibleEntry.available) {
                d.debounceResetTokenSelector()
            }
            if(selectedAssetEntry.available && !!selectedTokenEntry) {
                d.setTokenOnBothHeaders(selectedTokenEntry.symbol,
                                         Constants.tokenIcon(selectedTokenEntry.symbol),
                                         selectedTokenEntry.tokensKey)
            }
            else if(selectedCollectibleEntry.available && !!selectedTokenEntry) {
                const id = selectedTokenEntry.communityId ?
                             selectedTokenEntry.collectionUid :
                             selectedTokenEntry.uid
                d.setTokenOnBothHeaders(selectedTokenEntry.name,
                                         selectedTokenEntry.imageUrl || selectedTokenEntry.mediaUrl,
                                         id)
            }
        }

        function setTokenOnBothHeaders(name, icon, key) {
            sendModalHeader.setToken(name, icon, key)
            stickySendModalHeader.setToken(name, icon, key)
        }

        readonly property var debounceResetTokenSelector: Backpressure.debounce(root, 0, function() {
            if(!selectedAssetEntry.available && !selectedCollectibleEntry.available) {
                // reset token selector in case selected tokens doesnt exist in either models
                d.setTokenOnBothHeaders("", "", "")
                root.selectedTokenKey = ""
            }
        })

        readonly property var debounceSetSelectedAmount: Backpressure.debounce(root, 1500, function() {
            root.selectedAmount = amountToSend.text
        })

        readonly property bool isCollectibleSelected: {
            if(!selectedTokenEntry)
                return false
            const type = selectedAssetEntry.available ? selectedAssetEntry.item.type :
                    selectedCollectibleEntry.available ? selectedCollectibleEntry.item.tokenType :
                        Constants.TokenType.Unknown
            return (type === Constants.TokenType.ERC721 || type === Constants.TokenType.ERC1155)
        }

        readonly property string selectedCryptoTokenSymbol: !!d.selectedTokenEntry ?
                                                                d.selectedTokenEntry.symbol: ""

        readonly property double maxSafeCryptoValue: {
            const maxCryptoBalance = !!d.selectedTokenEntry && !!d.selectedTokenEntry.currentBalance ?
                                       d.selectedTokenEntry.currentBalance : 0
            return WalletUtils.calculateMaxSafeSendAmount(maxCryptoBalance, d.selectedCryptoTokenSymbol)
        }

        // handle multiple property changes from single changed signal
        property var combinedPropertyChangedHandler: [
            root.selectedAccountAddress,
            root.selectedChainId,
            root.selectedTokenKey,
            root.selectedRecipientAddress,
            root.selectedAmount]
        onCombinedPropertyChangedHandlerChanged: Qt.callLater(() => root.formChanged())
    }

    width: 556
    padding: 0
    horizontalPadding: Theme.xlPadding
    topMargin: margins + accountSelector.height + Theme.padding

    background: StatusDialogBackground {
        color: Theme.palette.baseColor3
    }

    // Bindings needed for exposing and setting raw values from AmountToSend
    onSelectedAmountChanged: {
        if(!!selectedAmount && amountToSend.text !== root.selectedAmount) {
            amountToSend.setValue(root.selectedAmount)
        }
    }

    Item {
        id: sendModalcontentItem

        anchors.fill: parent
        anchors.top: parent.top

        implicitWidth: parent.width
        implicitHeight: Math.max(sendModalHeader.height +
                                 amountToSend.height +
                                 recipientsPanelLayout.height +
                                 feesLayout.height +
                                 scrollViewLayout.spacing*3 +
                                 28,
                                 scrollView.implicitHeight)

        // Floating account Selector
        AccountSelectorHeader {
            id: accountSelector

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

                width: parent.width

                stickyHeaderVisible: d.stickyHeaderVisible

                networksModel: root.networksModel
                assetsModel: root.assetsModel
                collectiblesModel: root.collectiblesModel

                selectedChainId: root.selectedChainId

                onCollectibleSelected: root.selectedTokenKey = key
                onCollectionSelected: root.selectedTokenKey = key
                onAssetSelected: root.selectedTokenKey = key
                onNetworkSelected: root.selectedChainId = chainId
            }
        }

        // Main scrollable Layout
        StatusScrollView {
            id: scrollView

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

                    Layout.fillWidth: true
                    Layout.topMargin: 28

                    isScrolling: d.stickyHeaderVisible

                    networksModel: root.networksModel
                    assetsModel: root.assetsModel
                    collectiblesModel: root.collectiblesModel

                    selectedChainId: root.selectedChainId

                    onCollectibleSelected: root.selectedTokenKey = key
                    onCollectionSelected: root.selectedTokenKey = key
                    onAssetSelected: root.selectedTokenKey = key
                    onNetworkSelected: root.selectedChainId = chainId
                }

                // Amount to send entry
                AmountToSend {
                    id: amountToSend

                    Layout.fillWidth: true

                    interactive: root.interactive
                    dividerVisible: true
                    progressivePixelReduction: false
                    /** TODO: connect this with suggested routes being fetched as price
                        gets updated each time a new proposal is fetched
                        bottomTextLoading: root.suggestedRoutesLoading **/

                    /** TODO: connect to max safe value for eth.
                        For now simply checking balance in case of both eth and other ERC20's **/
                    markAsInvalid: SQUtils.AmountsArithmetic.fromNumber(d.maxSafeCryptoValue, multiplierIndex).cmp(amount) === -1

                    selectedSymbol: amountToSend.fiatMode ?
                                        root.currentCurrency:
                                        d.selectedCryptoTokenSymbol
                    price: !!d.selectedTokenEntry &&
                           !!d.selectedTokenEntry.marketDetails ?
                               d.selectedTokenEntry.marketDetails.currencyPrice.amount : 1
                    multiplierIndex: !!d.selectedTokenEntry &&
                                     !!d.selectedTokenEntry.decimals ?
                                         d.selectedTokenEntry.decimals : 0
                    formatFiat: amount => root.fnFormatCurrencyAmount(
                                    amount, root.currentCurrency)
                    formatBalance: amount => root.fnFormatCurrencyAmount(
                                       amount, d.selectedCryptoTokenSymbol)

                    visible: !!root.selectedTokenKey && !d.isCollectibleSelected
                    onVisibleChanged: if(visible) forceActiveFocus()

                    onTextChanged: d.debounceSetSelectedAmount()

                    bottomRightComponent: MaxSendButton {
                        id: maxButton

                        formattedValue: {
                            const price = !!d.selectedTokenEntry && !!d.selectedTokenEntry.marketDetails ?
                                            d.selectedTokenEntry.marketDetails.currencyPrice.amount : 0
                            let maxSafeValue = amountToSend.fiatMode ? d.maxSafeCryptoValue * price : d.maxSafeCryptoValue
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

                /** TODO: replace with new and improved recipient selector TBD under
                https://github.com/status-im/status-desktop/issues/16916 **/
                ColumnLayout {
                    id: recipientsPanelLayout

                    Layout.fillWidth: true

                    spacing: Theme.halfPadding

                    StatusBaseText {
                        elide: Text.ElideRight
                        text: qsTr("To")
                    }
                    RecipientSelectorPanel {
                        id: recipientsPanel

                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.bottomMargin: feesLayout.visible ? 0 : Theme.xlPadding

                        savedAddressesModel: root.savedAddressesModel
                        myAccountsModel: root.accountsModel
                        recentRecipientsModel: root.recentRecipientsModel

                        onResolveENS: root.fnResolveENS(ensName, uuid)
                    }
                }

                // Fees Component
                ColumnLayout {
                    id: feesLayout

                    Layout.fillWidth: true
                    Layout.bottomMargin: Theme.xlPadding

                    spacing: Theme.halfPadding

                    StatusBaseText {
                        elide: Text.ElideRight
                        text: qsTr("Fees")
                    }
                    SimpleTransactionsFees {
                        Layout.fillWidth: true

                        cryptoFees: root.estimatedCryptoFees
                        fiatFees: root.estimatedFiatFees
                        loading: root.routesLoading && root.allValuesFilledCorrectly
                    }
                    visible: root.allValuesFilledCorrectly
                }
            }
        }
    }

    footer: SendModalFooter {
        width: root.width

        estimatedTime: root.estimatedTime
        estimatedFees: root.estimatedFiatFees

        loading: root.routesLoading && root.allValuesFilledCorrectly

        onReviewSendClicked: root.reviewSendClicked()
    }
}
