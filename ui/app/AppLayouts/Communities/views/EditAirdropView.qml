import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1

import utils 1.0
import shared.panels 1.0

import AppLayouts.Communities.controls 1.0
import AppLayouts.Communities.helpers 1.0
import AppLayouts.Communities.panels 1.0
import AppLayouts.Communities.popups 1.0

import SortFilterProxyModel 0.2


StatusScrollView {
    id: root

    // id, name, image, color, owner properties expected
    required property var communityDetails

    // Token models:
    required property var assetsModel
    required property var collectiblesModel

    // Community members model:
    required property var membersModel

    // A model containing accounts from which the fee can be paid:
    required property var accountsModel
 
    // Text to display as total fee
    required property string totalFeeText
    // Text to display in case of error
    required property string feeErrorText
    // Array containing the fees for each token
    // [{contractUniqueKey: string, feeText: string}]
    required property var feesPerSelectedContract
    // Bool property indicating whether the fees are available
    required property bool feesAvailable

    property int viewWidth: 560 // by design

    readonly property var selectedHoldingsModel: ListModel {}
    // Array containing the contract keys and amounts of the tokens to be airdropped
    readonly property alias selectedContractKeysAndAmounts: d.selectedContractKeysAndAmounts
    // Array containing the addresses to which the tokens will be airdropped
    readonly property alias selectedAddressesToAirdrop: d.selectedAddressesToAirdrop
    // The address of the account from which the fee will be paid
    readonly property alias selectedFeeAccount: d.selectedFeeAccount
    // Bool property indicating whether the fees are shown
    readonly property bool showingFees: d.showFees

    onFeesPerSelectedContractChanged: {
        feesModel.clear()
        
        let feeSource = feesPerSelectedContract
        if(!feeSource || feeSource.length === 0) // if no fees are available, show the placeholder text based on selection
            feeSource = ModelUtils.modelToArray(root.selectedHoldingsModel, ["contractUniqueKey"])

        feeSource.forEach(entry => {
            feesModel.append({
                contractUniqueKey: entry.contractUniqueKey,
                title: qsTr("Airdrop %1 on %2")
                                    .arg(ModelUtils.getByKey(root.selectedHoldingsModel, "contractUniqueKey", entry.contractUniqueKey, "symbol"))
                                    .arg(ModelUtils.getByKey(root.selectedHoldingsModel, "contractUniqueKey", entry.contractUniqueKey, "networkText")),
                feeText: entry.feeText ?? ""
            })
        })
    }

    ModelChangeTracker {
        id: holdingsModelTracker

        model: selectedHoldingsModel
    }

    ModelChangeTracker {
        id: addressesModelTracker

        model: addresses
    }

    ModelChangeTracker {
        id: membersModelTracker

        model: selectedMembersModel
    }

    readonly property bool isFullyFilled: tokensSelector.count > 0 &&
                                          airdropRecipientsSelector.count > 0 &&
                                          airdropRecipientsSelector.valid

    signal airdropClicked(var airdropTokens, var addresses, string feeAccountAddress)

    signal navigateToMintTokenSettings(bool isAssetType)

    function selectToken(key, amount, type) {
        if(selectedHoldingsModel)
            selectedHoldingsModel.clear()

        const entry = d.prepareEntry(key, amount, type)
        entry.valid = true
        selectedHoldingsModel.append(entry)
    }

    function addAddresses(_addresses) {
        addresses.addAddresses(_addresses)
    }

    QtObject {
        id: d

        readonly property int maxAirdropTokens: 5
        readonly property int dropdownHorizontalOffset: 4
        readonly property int dropdownVerticalOffset: 1

        readonly property bool showFees: root.selectedHoldingsModel.count > 0
                                         && airdropRecipientsSelector.valid
                                         && airdropRecipientsSelector.count > 0

        readonly property var selectedContractKeysAndAmounts: {
            //Depedencies:
            root.selectedHoldingsModel
            holdingsModelTracker.revision

            return ModelUtils.modelToArray(
                                    root.selectedHoldingsModel,
                                    ["contractUniqueKey", "amount"])
        }

        readonly property var selectedAddressesToAirdrop: {
            //Dependecies:
            addresses
            addressesModelTracker.revision

            return ModelUtils.modelToArray(
                                 addresses, ["address"]).map(e => e.address)
                                 .concat([...selectedKeysFilter.keys])
        }

        readonly property string selectedFeeAccount: ModelUtils.get(root.accountsModel,
                                                        feesBox.accountIndex).address

        function prepareEntry(key, amount, type) {
            const tokenModel = type === Constants.TokenType.ERC20
                             ? root.assetsModel : root.collectiblesModel
            const modelItem = PermissionsHelpers.getTokenByKey(
                                tokenModel, key)
            const multiplierIndex = modelItem.multiplierIndex
            const amountNumber = AmountsArithmetic.toNumber(
                                   amount, multiplierIndex)
            const amountLocalized = LocaleUtils.numberToLocaleString(
                                      amountNumber, -1)
            return {
                key, amount, type,
                tokenText: amountLocalized + " " + modelItem.name,
                tokenImage: modelItem.iconSource,
                networkText: modelItem.chainName,
                networkImage: Style.svg(modelItem.chainIcon),
                remainingSupply: modelItem.remainingSupply,
                multiplierIndex: modelItem.multiplierIndex,
                infiniteSupply: modelItem.infiniteSupply,
                contractUniqueKey: modelItem.contractUniqueKey,
                accountName: modelItem.accountName,
                symbol: modelItem.symbol
            }
        }
    }

    ListModel {
        id: feesModel
    }

    Instantiator {
        id: recipientsCountInstantiator

        model: selectedHoldingsModel

        property bool infinity: true
        property int maximumRecipientsCount

        function findRecipientsCount() {
            let min = Number.MAX_SAFE_INTEGER

            for (let i = 0; i < count; i++) {
                const item = objectAt(i)

                if (!item || item.infiniteSupply)
                    continue

                const dividient = AmountsArithmetic.fromString(item.remainingSupply)
                const divisor = AmountsArithmetic.fromString(item.amount)

                const quotient = AmountsArithmetic.toNumber(
                                   AmountsArithmetic.div(dividient, divisor))

                min = Math.min(quotient, min)
            }

            infinity = min === Number.MAX_SAFE_INTEGER
            maximumRecipientsCount = infinity ? 0 : min
        }

        delegate: QtObject {
            readonly property string remainingSupply: model.remainingSupply
            readonly property string amount: model.amount
            readonly property bool infiniteSupply: model.infiniteSupply

            readonly property bool valid: {
                if (infiniteSupply)
                    return true

                const recipientsCount = airdropRecipientsSelector.count
                const demand = AmountsArithmetic.times(
                                 AmountsArithmetic.fromString(amount),
                                 recipientsCount)

                const available = AmountsArithmetic.fromString(remainingSupply)

                return AmountsArithmetic.cmp(demand, available) <= 0
            }


            onRemainingSupplyChanged: recipientsCountInstantiator.findRecipientsCount()
            onAmountChanged: recipientsCountInstantiator.findRecipientsCount()
            onInfiniteSupplyChanged: recipientsCountInstantiator.findRecipientsCount()

            onValidChanged: model.valid = valid
            Component.onCompleted: model.valid = valid
        }

        onCountChanged: findRecipientsCount()
    }

    SequenceColumnLayout {
        id: mainLayout
        width: root.viewWidth
        spacing: 0

        AirdropTokensSelector {
            id: tokensSelector

            property int editedIndex: -1

            Layout.fillWidth: true
            icon: Style.svg("token")
            title: qsTr("What")
            placeholderText: qsTr("Example: 1 SOCK")
            addButton.visible: model.count < d.maxAirdropTokens

            model: root.selectedHoldingsModel

            HoldingsDropdown {
                id: dropdown

                communityId: communityDetails.id
                assetsModel: root.assetsModel
                collectiblesModel: root.collectiblesModel
                isENSTab: false
                noDataTextForAssets: qsTr("First you need to mint or import an asset before you can perform an airdrop")
                noDataTextForCollectibles: qsTr("First you need to mint or import a collectible before you can perform an airdrop")

                function getHoldingIndex(key) {
                    return ModelUtils.indexOf(root.selectedHoldingsModel, "key", key)
                }

                function prepareUpdateIndex(key) {
                    const itemIndex = tokensSelector.editedIndex
                    const existingIndex = getHoldingIndex(key)

                    if (itemIndex !== -1 && existingIndex !== -1 && itemIndex !== existingIndex) {
                        const previousKey = root.selectedHoldingsModel.get(itemIndex).key
                        root.selectedHoldingsModel.remove(existingIndex)
                        return getHoldingIndex(previousKey)
                    }

                    if (itemIndex === -1) {
                        return existingIndex
                    }

                    return itemIndex
                }

                onOpened: {
                    usedTokens = ModelUtils.modelToArray(
                                root.selectedHoldingsModel, ["key", "amount"])
                }

                onAddAsset: {
                    const entry = d.prepareEntry(key, amount, Constants.TokenType.ERC20)
                    entry.valid = true

                    selectedHoldingsModel.append(entry)
                    dropdown.close()
                }

                onAddCollectible: {
                    const entry = d.prepareEntry(key, amount, Constants.TokenType.ERC721)
                    entry.valid = true

                    selectedHoldingsModel.append(entry)
                    dropdown.close()
                }

                onUpdateAsset: {
                    const itemIndex = prepareUpdateIndex(key)

                    const entry = d.prepareEntry(key, amount, Constants.TokenType.ERC20)

                    root.selectedHoldingsModel.set(itemIndex, entry)
                    dropdown.close()
                }

                onUpdateCollectible: {
                    const itemIndex = prepareUpdateIndex(key)

                    const entry = d.prepareEntry(key, amount, Constants.TokenType.ERC721)

                    root.selectedHoldingsModel.set(itemIndex, entry)
                    dropdown.close()
                }

                onRemoveClicked: {
                    root.selectedHoldingsModel.remove(tokensSelector.editedIndex)
                    dropdown.close()
                }

                onNavigateToMintTokenSettings: {
                    root.navigateToMintTokenSettings(isAssetType)
                    close()
                }
            }

            addButton.onClicked: {
                dropdown.parent = tokensSelector.addButton
                dropdown.x = tokensSelector.addButton.width + d.dropdownHorizontalOffset
                dropdown.y = 0
                dropdown.open()

                editedIndex = -1
            }

            onItemClicked: {
                if (mouse.button !== Qt.LeftButton)
                    return

                dropdown.parent = item
                dropdown.x = mouse.x + d.dropdownHorizontalOffset
                dropdown.y = d.dropdownVerticalOffset

                const modelItem = selectedHoldingsModel.get(index)

                switch(modelItem.type) {
                    case Constants.TokenType.ERC20:
                        dropdown.assetKey = modelItem.key
                        dropdown.assetAmount = modelItem.amount
                        dropdown.assetMultiplierIndex = modelItem.multiplierIndex
                        dropdown.setActiveTab(Constants.TokenType.ERC20)
                        break
                    case Constants.TokenType.ERC721:
                        dropdown.collectibleKey = modelItem.key
                        dropdown.collectibleAmount = modelItem.amount
                        dropdown.setActiveTab(Constants.TokenType.ERC721)
                        break
                    default:
                        console.warn("Unsupported token type.")
                }

                dropdown.openUpdateFlow()

                editedIndex = index
            }
        }

        SequenceColumnLayout.Separator {}

        AirdropRecipientsSelector {
            id: airdropRecipientsSelector

            addressesModel: addresses

            infiniteMaxNumberOfRecipients:
                recipientsCountInstantiator.infinity

            maxNumberOfRecipients:
                recipientsCountInstantiator.maximumRecipientsCount

            membersModel: SortFilterProxyModel {
                id: selectedMembersModel

                sourceModel: membersModel

                filters: ExpressionFilter {
                    id: selectedKeysFilter

                    property var keys: new Set()

                    expression: keys.has(model.airdropAddress) && model.airdropAddress !== ""
                }
            }

            onRemoveMemberRequested: {
                const airdropAddress = ModelUtils.get(membersModel, index, "airdropAddress")

                selectedKeysFilter.keys.delete(airdropAddress)
                selectedKeysFilter.keys = new Set([...selectedKeysFilter.keys])
            }

            onAddAddressesRequested: (addresses_) => {
                addresses.addAddressesFromString(addresses_)
                airdropRecipientsSelector.clearAddressesInput()
                airdropRecipientsSelector.positionAddressesListAtEnd()
            }

            onRemoveAddressRequested: addresses.remove(index)

            ListModel {
                id: addresses

                function addAddresses(_addresses) {
                    const existing = new Set()

                    for (let i = 0; i < count; i++)
                        existing.add(get(i).address)

                    _addresses.forEach(address => {
                        if (existing.has(address))
                            return

                        const valid = Utils.isValidAddress(address)
                        append({ valid, address })
                    })
                }

                function addAddressesFromString(addressesString) {
                    const words = addressesString.trim().split(/[\s+,]/)
                    const wordsNonEmpty = words.filter(word => !!word)

                    addAddresses(wordsNonEmpty)
                }
            }

            function openPopup(popup) {
                popup.parent = addButton
                popup.x = addButton.width + d.dropdownHorizontalOffset
                popup.y = 0

                popup.open()
            }

            addButton.onClicked: openPopup(recipientTypeSelectionDropdown)

            RecipientTypeSelectionDropdown {
                id: recipientTypeSelectionDropdown

                onEthAddressesSelected: {
                    airdropRecipientsSelector.showAddressesInputWhenEmpty = true
                    airdropRecipientsSelector.forceInputFocus()
                    recipientTypeSelectionDropdown.close()
                }

                onCommunityMembersSelected: {
                    recipientTypeSelectionDropdown.close()
                    membersDropdown.selectedKeys = selectedKeysFilter.keys

                    const hasSelection =  selectedKeysFilter.keys.size !== 0

                    membersDropdown.mode = hasSelection
                            ? MembersDropdown.Mode.Update
                            : MembersDropdown.Mode.Add

                    airdropRecipientsSelector.openPopup(membersDropdown)
                }
            }

            MembersDropdown {
                id: membersDropdown

                forceButtonDisabled:
                    mode === MembersDropdown.Mode.Update &&
                    [...selectedKeys].sort().join() === [...selectedKeysFilter.keys].sort().join()

                model: SortFilterProxyModel {
                    sourceModel: membersModel

                    filters: [
                        ExpressionFilter {
                            enabled: membersDropdown.searchText !== ""

                            function matchesAlias(name, filter) {
                                return name.split(" ").some(p => p.startsWith(filter))
                            }

                            expression: {
                                membersDropdown.searchText

                                const filter = membersDropdown.searchText.toLowerCase()
                                return matchesAlias(model.alias.toLowerCase(), filter)
                                         || model.displayName.toLowerCase().includes(filter)
                                         || model.ensName.toLowerCase().includes(filter)
                                         || model.localNickname.toLowerCase().includes(filter)
                                         || model.pubKey.toLowerCase().includes(filter)
                            }
                        },
                        ExpressionFilter {
                            expression: !!model.airdropAddress
                        }
                    ]
                }

                onBackButtonClicked: {
                    close()
                    airdropRecipientsSelector.openPopup(
                                recipientTypeSelectionDropdown)
                }

                onAddButtonClicked: {
                    selectedKeysFilter.keys = selectedKeys
                    close()
                }
            }
        }

        SequenceColumnLayout.Separator {}

        FeesBox {
            id: feesBox

            readonly property int accountIndex: accountsSelector.currentIndex

            Layout.fillWidth: true

            model: feesModel
            accountsSelector.model: root.accountsModel

            totalFeeText: root.totalFeeText
            placeholderText: qsTr("Add valid “What” and “To” values to see fees")

            accountErrorText: root.feeErrorText
        }

        WarningPanel {
            id: notEnoughTokensWarning

            Layout.fillWidth: true
            Layout.topMargin: Style.current.padding

            text: qsTr("Not enough tokens to send to all recipients. Reduce the number of recipients or change the number of tokens sent to each recipient.")

            visible: !recipientsCountInstantiator.infinity &&
                     recipientsCountInstantiator.maximumRecipientsCount < airdropRecipientsSelector.count
        }

        StatusButton {
            Layout.preferredHeight: 44
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            Layout.topMargin: Style.current.bigPadding
            text: qsTr("Create airdrop")
            enabled: root.isFullyFilled && root.feesAvailable && root.feeErrorText === ""

            onClicked: {
                const accountItem = ModelUtils.get(root.accountsModel,
                                                   feesBox.accountIndex)
                feesPopup.accountAddress = accountItem.address
                feesPopup.accountName = accountItem.name
                feesPopup.open()
            }
        }

        SignTransactionsPopup {
            id: feesPopup

            property string accountAddress

            destroyOnClose: false

            model: feesModel

            totalFeeText: root.totalFeeText
            errorText: root.feeErrorText

            onOpened: {
                const title1 = qsTr("Sign transaction - Airdrop %n token(s)", "",
                                    selectedHoldingsModel.rowCount())
                const title2 = qsTr("to %n recipient(s)", "",
                                    addresses.count + airdropRecipientsSelector.membersModel.count)

                title = `${title1} ${title2}`
            }

            onSignTransactionClicked: {
                const airdropTokens = ModelUtils.modelToArray(
                                        root.selectedHoldingsModel,
                                        ["contractUniqueKey", "amount"])

                const addresses_ = ModelUtils.modelToArray(
                                    addresses, ["address"]).map(e => e.address)

                const airdropAddresses = [...selectedKeysFilter.keys]

                root.airdropClicked(airdropTokens, addresses_.concat(airdropAddresses),
                                    accountAddress)
            }
        }
    }
}
