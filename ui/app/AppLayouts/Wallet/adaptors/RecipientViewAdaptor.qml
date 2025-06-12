import QtQuick 2.15

import QtModelsToolkit 1.0
import SortFilterProxyModel 0.2

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1

import utils 1.0

QObject {
    id: root

    /**
        Output roles:

        address     [string] - unique wallet address
        name        [string] (optional)
        color       [string] (optional)
        colorId     [string] (optional)
        emoji       [string] (optional)
        ens         [string] (optional)
    */

    // input API
    /**
        Expected model structure:

        address     [string]
        name        [string]
        colorId     [string]
        emoji       [string]
        ens         [string]
    **/
    required property var savedAddressesModel
    /**
        Expected model structure:

        address     [string]
        name        [string]
        color       [string]
        colorId     [string]
        emoji       [string]
    **/
    required property var accountsModel
    /**
        Expected model structure:

        activityEntry:
            sender      [string] - sender wallet address
            recipient   [string] - recipient wallet address
            txType      [int]    - transaction type (Constants.TransactionType)
    **/
    required property var recentRecipientsModel

    /** Currently selected recipient type **/
    property int selectedRecipientType
    /** Search pattern for filtering recipients **/
    property string searchPattern
    /** Currently selected sender address **/
    property string selectedSenderAddress

    /** Maximum number of tab elements from all tabs in tab bar **/
    readonly property int highestTabElementCount: Math.max(accountsModelProxyModel.ModelCount.count, root.savedAddressesModel.ModelCount.count, recentsModel.ModelCount.count)

    readonly property SortFilterProxyModel recipientsModel: SortFilterProxyModel {
        objectName: "RecipientViewAdaptor_recipientsModel"

        sourceModel: concatModel

        function isSameModelType(selectedType, recipientType) {
            if (!selectedType || selectedType === Constants.RecipientAddressObjectType.Address)
                return true
            return selectedType === Number(recipientType)
        }

        filters: [
            FastExpressionFilter {
                expectedRoles: ["which_model"]
                expression: root.recipientsModel.isSameModelType(root.selectedRecipientType, model.which_model)
            }
        ]
    }

    readonly property SortFilterProxyModel recipientsFilterModel: SortFilterProxyModel {
        objectName: "RecipientViewAdaptor_recipientsFilterModel"

        sourceModel: concatModel

        filters: [
            ValueFilter {
                enabled: !!root.searchPattern
                // Ignore duplicates from recents model
                roleName: "cherrypicked"
                value: true
                inverted: true
            },
            AnyOf {
                enabled: !!root.searchPattern
                RegExpFilter {
                    roleName: "name"
                    caseSensitivity: Qt.CaseInsensitive
                    pattern: `^${root.searchPattern}.*`
                }
                RegExpFilter {
                    roleName: "address"
                    caseSensitivity: Qt.CaseInsensitive
                    pattern: `^${root.searchPattern}.*`
                }
                RegExpFilter {
                    roleName: "ens"
                    caseSensitivity: Qt.CaseInsensitive
                    pattern: `^${root.searchPattern}.*`
                }
            }
        ]
    }

    ConcatModel {
        id: concatModel
        objectName: "RecipientViewAdaptor_concatModel"

        sources: [
            SourceModel {
                model: accountsModelProxyModel
                markerRoleValue: Constants.RecipientAddressObjectType.Account
            },
            SourceModel {
                model: root.savedAddressesModel
                markerRoleValue: Constants.RecipientAddressObjectType.SavedAddress
            },
            SourceModel {
                model: recentsModel
                markerRoleValue: Constants.RecipientAddressObjectType.RecentsAddress
            }
        ]
        expectedRoles: ["name", "address", "color", "colorId", "emoji", "ens", "cherrypicked", "duplicate"]
        markerRoleName: "which_model"
    }

    SortFilterProxyModel {
        id: recentsModel
        objectName: "RecipientViewAdaptor_recentsModel"

        function isValidEntry(entry) {
            return entry && (entry.txType === Constants.TransactionType.Receive || entry.txType === Constants.TransactionType.Send)
        }

        function getAddressFromEntry(entry) {
            return entry.txType === Constants.TransactionType.Receive ? entry.sender : entry.recipient
        }

        function refreshRecentsModelFlatList() {
            let list = []
            for (let i = 0 ; i < recentRecipientsExtractModel.count ; i++) {
                const address = getAddressFromEntry(ModelUtils.get(recentRecipientsExtractModel, i, "activityEntry"))
                if (!!address)
                    list.push(address)
            }
            recentRecipientsAddressesFlatList = list
        }

        // NOTE Additional model is used to filter out duplicate entries later on
        readonly property SortFilterProxyModel recentRecipientsExtractModel: SortFilterProxyModel {
            sourceModel: root.recentRecipientsModel

            filters: [
                FastExpressionFilter {
                    expectedRoles: ["activityEntry"]
                    expression: recentsModel.isValidEntry(model.activityEntry)
                }
            ]
            onRowsInserted: recentsModel.refreshRecentsModelFlatList()
            onRowsRemoved: recentsModel.refreshRecentsModelFlatList()
            onRowsMoved: recentsModel.refreshRecentsModelFlatList()
        }

        property var recentRecipientsAddressesFlatList: []
        Component.onCompleted: refreshRecentsModelFlatList()

        sourceModel: ObjectProxyModel {
            sourceModel: recentsModel.recentRecipientsExtractModel

            delegate: QtObject {
                id: recentsDelegate

                readonly property bool duplicate: recentsModel.recentRecipientsAddressesFlatList.indexOf(address) < model.index
                readonly property string address: recentsModel.getAddressFromEntry(model.activityEntry)
                readonly property string name: {
                    if (recentsAccountsModelEntry.available)
                        return recentsAccountsModelEntry.item.name
                    if (recentsSavedAddressModelEntry.available)
                        return recentsSavedAddressModelEntry.item.name
                    return ""
                }
                readonly property string color: {
                    if (recentsAccountsModelEntry.available)
                        return recentsAccountsModelEntry.item.color
                    if (recentsSavedAddressModelEntry.available)
                        return recentsSavedAddressModelEntry.item.color
                    return ""
                }
                readonly property string colorId: {
                    if (recentsAccountsModelEntry.available)
                        return recentsAccountsModelEntry.item.colorId
                    if (recentsSavedAddressModelEntry.available)
                        return recentsSavedAddressModelEntry.item.colorId
                    return ""
                }
                readonly property string emoji: {
                    if (recentsAccountsModelEntry.available)
                        return recentsAccountsModelEntry.item.emoji
                    return ""
                }

                // Only used internally for filtering out duplicates in search. Recents can have same entries as in saved addresses or accounts.
                readonly property bool cherrypicked: recentsSavedAddressModelEntry.available || recentsAccountsModelEntry.available || duplicate

                readonly property ModelEntry recentsSavedAddressModelEntry: ModelEntry {
                    sourceModel: recentsDelegate.duplicate ? null : root.savedAddressesModel
                    key: "address"
                    value: recentsDelegate.address
                }

                readonly property ModelEntry recentsAccountsModelEntry: ModelEntry {
                    sourceModel: recentsDelegate.duplicate ? null : root.accountsModel
                    key: "address"
                    value: recentsDelegate.address
                }
            }

            expectedRoles: ["activityEntry"]
            exposedRoles: ["name", "address", "color", "colorId", "emoji", "cherrypicked", "duplicate"]
        }

        filters: [
            ValueFilter {
                // NOTE duplicate property was used instead of filter, becuase removal of row doesn't re-evaluate existing results
                roleName: "duplicate"
                value: false
            }
        ]
    }

    SortFilterProxyModel {
        id: accountsModelProxyModel

        objectName: "RecipientViewAdaptor_accountsModel"

        sourceModel: root.accountsModel

        filters: [
            ValueFilter {
                roleName: "walletType"
                value: Constants.watchWalletType
                inverted: true
            },
            SearchFilter {
                enabled: !!root.selectedSenderAddress
                roleName: "address"
                searchPhrase: root.selectedSenderAddress
                inverted: true
            }
        ]
    }
}
