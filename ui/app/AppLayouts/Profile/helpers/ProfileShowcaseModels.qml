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

    function changeCollectiblePosition(key, to) {
        collectibles.changePosition(key, to)
    }

    ProfileShowcaseModelAdapter {
        id: modelAdapter
    }

    ProfileShowcaseDirtyState {
        id: communities

        sourceModel: modelAdapter.adaptedCommunitiesSourceModel
        showcaseModel: modelAdapter.adaptedCommunitiesShowcaseModel
    }

    ProfileShowcaseDirtyState {
        id: accounts

        sourceModel: modelAdapter.adaptedAccountsSourceModel
        showcaseModel: modelAdapter.adaptedAccountsShowcaseModel
    }

    ProfileShowcaseDirtyState {
        id: collectibles

        sourceModel: collectiblesFilter
        showcaseModel: modelAdapter.adaptedCollectiblesShowcaseModel
    }

    SortFilterProxyModel {
        id: collectiblesFilter

        delayed: true
        sourceModel: modelAdapter.adaptedCollectiblesSourceModel
        proxyRoles: FastExpressionRole {
            name: "maxVisibility"

            // singletons cannot be used in expressions
            readonly property int hidden: Constants.ShowcaseVisibility.NoOne

            expression: {
                const visibilityMap = root.accountsVisibilityMap
                const accounts = model.accounts.split(":")
                const visibilities = accounts.map(a => visibilityMap[a]).filter(
                                       v => v !== undefined)

                return visibilities.length ? Math.min(...visibilities) : hidden
            }

            expectedRoles: ["accounts"]
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
                        accounts.visibleModel, ["key", "visibility"])

            visibleAccountsList = keysAndVisibility.map(e => e.key)

            accountsVisibilityMap = keysAndVisibility.reduce(
                        (acc, val) => Object.assign(
                            acc, {[val.key]: val.visibility}), {})
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
