import QtQml

import StatusQ
import StatusQ.Core.Utils

import SortFilterProxyModel

import utils

QObject {
    id: root

    // GENERAL
    readonly property bool dirty: communities.dirty || accounts.dirty || collectibles.dirty || socialLinks.dirty

    function revert() {
        communities.revert()
        accounts.revert()
        collectibles.revert()
        socialLinks.revert()
    }

    // COMMUNITIES

    // Input models
    property alias communitiesSourceModel: communities.sourceModel

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

    function changeCommunityPosition(from, to) {
        communities.changePosition(from, to)
    }

    // ACCOUNTS

    // Input models
    property alias accountsSourceModel: accounts.sourceModel

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

    function changeAccountPosition(from, to) {
        accounts.changePosition(from, to)
    }

    // Other
    readonly property alias visibleAccountsList:
        visibleAccountsConnections.visibleAccountsList

    readonly property alias accountsVisibilityMap:
        visibleAccountsConnections.accountsVisibilityMap

    // COLLECTIBLES

    // Input models
    property alias collectiblesSourceModel: collectiblesFilter.sourceModel

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

    // SOCIAL LINKS

    // Input models
    property alias socialLinksSourceModel: socialLinks.sourceModel

    // Output models
    readonly property alias socialLinksVisibleModel: socialLinks.visibleModel

    // Methods
    function appendSocialLink(obj) {
        socialLinks.append(obj)
    }

    function updateSocialLink(index, obj) {
        socialLinks.update(index, obj)
    }

    function removeSocialLink(index) {
        socialLinks.remove(index)
    }

    function changeSocialLinkPosition(from, to) {
        socialLinks.changePosition(from, to)
    }

    function socialLinksCurrentState(roleNames) {
        return socialLinks.currentState(roleNames)
    }

    // The complete preferences models json current state:
    function buildJSONModelsCurrentState() {
        return JSON.stringify({
            "communities": communitiesCurrentState(),
            "accounts": accountsCurrentState(),
            "collectibles": collectiblesCurrentState(),
            "socialLinks": socialLinksCurrentState(["url", "text", "showcaseVisibility", "showcasePosition"])
            // TODO: Assets --> Issue #13492
        })
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

    ProfileShowcaseDirtyState {
        id: socialLinks
    }


    SortFilterProxyModel {
        id: collectiblesFilter

        delayed: true
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
