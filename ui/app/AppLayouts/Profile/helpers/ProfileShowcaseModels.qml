import QtQml 2.15

import StatusQ 0.1
import StatusQ.Core.Utils 0.1

import SortFilterProxyModel 0.2

QObject {
    id: root

    // COMMUNITIES

    // Input models
    property alias communitiesSourceModel: communities.sourceModel
    property alias communitiesShowcaseModel: communities.showcaseModel

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
    property alias accountsSourceModel: accounts.sourceModel
    property alias accountsShowcaseModel: accounts.showcaseModel

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
    property alias collectiblesSourceModel: collectiblesFilter.sourceModel
    property alias collectiblesShowcaseModel: collectibles.showcaseModel

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

    ProfileShowcaseDirtyState {
        id: communities
    }

    ProfileShowcaseDirtyState {
        id: accounts
    }

    ProfileShowcaseDirtyState {
        id: collectibles

        sourceModel: collectiblesFilter
    }

    SortFilterProxyModel {
        id: collectiblesFilter

        delayed: true

        proxyRoles: FastExpressionRole {
            name: "maxVisibility"

            expression: {
                const m = root.accountsVisibilityMap
                const accounts = model.accounts.split(":")
                const visibilities = accounts.map(e => m[e]).filter(e => e)

                return visibilities.length ? Math.min(...visibilities) : 0
            }

            expectedRoles: ["accounts"]
        }

        filters: RangeFilter {
            roleName: "maxVisibility"
            minimumValue: 1
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
