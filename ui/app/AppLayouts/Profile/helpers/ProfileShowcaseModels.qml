import QtQml 2.15

import StatusQ 0.1
import StatusQ.Core.Utils 0.1

import SortFilterProxyModel 0.2

import utils 1.0

QObject {
    id: root

    // GENERAL
    readonly property bool dirty: communities.dirty || accounts.dirty || collectibles.dirty

    function revert() {
        communities.revert()
        accounts.revert()
        collectibles.revert()
    }

    // COMMUNITIES

    // Input models
    property alias communitiesSourceModel: modelAdapter.communitiesSourceModel
    property alias communitiesShowcaseModel: modelAdapter.communitiesShowcaseModel
    property string communitiesSearcherText

    // Output models
    readonly property alias communitiesVisibleModel: communities.visibleModel
    readonly property alias communitiesHiddenModel: communities.hiddenModel

    // Methods
    function communitiesCurrentState() {
        return communities.currentState()
    }

    function setCommunityVisibility(key, visibility) {
        communities.setVisibility(key, visibility)
    }

    function changeCommunityPosition(key, to) {
        communities.changePosition(key, to)
    }

    // ACCOUNTS

    // Input models
    property alias accountsSourceModel: modelAdapter.accountsSourceModel
    property alias accountsShowcaseModel: modelAdapter.accountsShowcaseModel
    property string accountsSearcherText

    // Output models
    readonly property alias accountsVisibleModel: accounts.visibleModel
    readonly property alias accountsHiddenModel: accounts.hiddenModel

    // Methods
    function accountsCurrentState() {
        return accounts.currentState()
    }

    function setAccountVisibility(key, visibility) {
        accounts.setVisibility(key, visibility)
    }

    function changeAccountPosition(key, to) {
        accounts.changePosition(key, to)
    }

    // Other
    readonly property alias visibleAccountsList:
        visibleAccountsConnections.visibleAccountsList

    readonly property alias accountsVisibilityMap:
        visibleAccountsConnections.accountsVisibilityMap

    // COLLECTIBLES

    // Input models
    property alias collectiblesSourceModel: modelAdapter.collectiblesSourceModel
    property alias collectiblesShowcaseModel: modelAdapter.collectiblesShowcaseModel
    property string collectiblesSearcherText

    // Output models
    readonly property alias collectiblesVisibleModel: collectibles.visibleModel
    readonly property alias collectiblesHiddenModel: collectibles.hiddenModel

    // Methods
    function collectiblesCurrentState() {
        return collectibles.currentState()
    }

    function setCollectibleVisibility(key, visibility) {
        collectibles.setVisibility(key, visibility)
    }

    function changeCollectiblePosition(from, to) {
        collectibles.changePosition(from, to)
    }

    ProfileShowcaseModelAdapter {
        id: modelAdapter
    }

    ProfileShowcaseDirtyState {
        id: communities

        function getMemberRole(memberRole) {
            return ProfileUtils.getMemberRoleText(memberRole)
        }

        sourceModel: modelAdapter.adaptedCommunitiesSourceModel
        showcaseModel: modelAdapter.adaptedCommunitiesShowcaseModel
        searcherFilter: FastExpressionFilter {
            expression: {
                root.communitiesSearcherText
                return (name.toLowerCase().includes(root.communitiesSearcherText.toLowerCase()) ||
                        communities.getMemberRole(memberRole).toLowerCase().includes(root.communitiesSearcherText.toLowerCase()))
            }
            expectedRoles: ["name", "memberRole"]
        }
    }

    ProfileShowcaseDirtyState {
        id: accounts

        sourceModel: modelAdapter.adaptedAccountsSourceModel
        showcaseModel: modelAdapter.adaptedAccountsShowcaseModel
        searcherFilter: FastExpressionFilter {
            expression: {
                root.accountsSearcherText
                return (address.toLowerCase().includes(root.accountsSearcherText.toLowerCase()) ||
                        name.toLowerCase().includes( root.accountsSearcherText.toLowerCase()))
            }
            expectedRoles: ["address", "name"]
        }
    }

    ProfileShowcaseDirtyState {
        id: collectibles

        sourceModel: collectiblesFilter
        showcaseModel: modelAdapter.adaptedCollectiblesShowcaseModel
        searcherFilter: FastExpressionFilter {
            expression: {
                root.collectiblesSearcherText
                return (name.toLowerCase().includes(root.collectiblesSearcherText.toLowerCase()) ||
                        uid.toLowerCase().includes(root.collectiblesSearcherText.toLowerCase()) ||
                        communityName.toLowerCase().includes(root.collectiblesSearcherText.toLowerCase()) ||
                        collectionName.toLowerCase().includes(root.collectiblesSearcherText.toLowerCase()))
            }
            expectedRoles: ["name", "uid", "collectionName", "communityName"]
        }
    }

    SortFilterProxyModel {
        id: collectiblesFilter

        delayed: true
        sourceModel: modelAdapter.adaptedCollectiblesSourceModel
        proxyRoles: FastExpressionRole {
            name: "maxVisibility"

            // singletons cannot be used in expressions
            readonly property int hidden: Constants.ShowcaseVisibility.NoOne

            function getMaxVisibility(ownershipModel) {
                const visibilityMap = root.accountsVisibilityMap
                const accounts = ModelUtils.modelToFlatArray(ownershipModel, "accountAddress")
                const visibilities = accounts.map(a => visibilityMap[a.toLowerCase()]).filter(
                                       v => v !== undefined)

                return visibilities.length ? Math.min(...visibilities) : hidden
            }

            expression: {
                return getMaxVisibility(model.ownership)
            }

            expectedRoles: ["ownership"]
        }

        filters: ValueFilter {
            roleName: "maxVisibility"
            value: Constants.ShowcaseVisibility.NoOne
            inverted: true
        }
    }

    Connections {
        id: visibleAccountsConnections

        target: accounts.visibleModel

        property var visibleAccountsList: []
        property var accountsVisibilityMap: ({})

        function updateAccountsList() {
            const keysAndVisibility = ModelUtils.modelToArray(
                        accounts.visibleModel, ["showcaseKey", "showcaseVisibility"])

            visibleAccountsList = keysAndVisibility.map(e => e.showcaseKey)

            accountsVisibilityMap = keysAndVisibility.reduce(
                        (acc, val) => Object.assign(
                            acc, {[val.showcaseKey]: val.showcaseVisibility}), {})
        }

        function onDataChanged() {
            updateAccountsList()
        }

        function onRowsInserted() {
            updateAccountsList()
        }

        function onRowsRemoved() {
            updateAccountsList()
        }

        function onModelReset() {
            updateAccountsList()
        }

        Component.onCompleted: updateAccountsList()
    }
}
