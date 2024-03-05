import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import Qt.labs.settings 1.1
import QtQml 2.15

import StatusQ 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Internal 0.1
import StatusQ.Models 0.1
import StatusQ.Popups 0.1
import StatusQ.Popups.Dialog 0.1

import shared.controls 1.0
import shared.panels 1.0
import shared.popups 1.0

import utils 1.0

import AppLayouts.Wallet.views.collectibles 1.0
import AppLayouts.Wallet.controls 1.0

import SortFilterProxyModel 0.2

ColumnLayout {
    id: root

    required property var controller
    required property string addressFilters
    required property string networkFilters
    property bool sendEnabled: true
    property bool filterVisible
    property bool isFetching: false // Indicates if a collectibles page is being loaded from the backend
    property bool isUpdating: false // Indicates if the collectibles list is being updated
    property bool isError: false // Indicates an error occurred while updating/fetching the collectibles list

    signal collectibleClicked(int chainId, string contractAddress, string tokenId, string uid)
    signal sendRequested(string symbol)
    signal receiveRequested(string symbol)
    signal switchToCommunityRequested(string communityId)
    signal manageTokensRequested()

    spacing: 0

    QtObject {
        id: d

        readonly property int cellHeight: 225
        readonly property int communityCellHeight: 242
        readonly property int cellWidth: 176
        readonly property int headerHeight: 56

        readonly property bool isCustomView: cmbTokenOrder.currentValue === SortOrderComboBox.TokenOrderCustom

        readonly property var sourceModel: root.controller.sourceModel
        readonly property bool isLoading: root.isUpdating || root.isFetching

        onIsLoadingChanged: {
            d.loadingItemsModel.refresh()
        }

        readonly property var loadingItemsModel: ListModel {
            Component.onCompleted: {
                refresh()
            }

            function refresh() {
                clear()
                if (d.isLoading) {
                    for (let i = 0; i < 10; i++) {
                        append({ isLoading: true })
                    }
                }
            }
        }

        readonly property var communityModel: CustomSFPM {
            isCommunity: true
        }

        readonly property var communityModelWithLoadingItems: ConcatModel {
            sources: [
                SourceModel {
                    model: d.communityModel
                    markerRoleValue: "communityModel"
                },
                SourceModel {
                    model: d.loadingItemsModel
                    markerRoleValue: "loadingItemsModel"
                }
            ]

            markerRoleName: "sourceGroup"
        }

        readonly property var nonCommunityModel: CustomSFPM {
            isCommunity: false
        }

        readonly property var nonCommunityModelWithLoadingItems: ConcatModel {
            sources: [
                SourceModel {
                    model: d.nonCommunityModel
                    markerRoleValue: "nonCommunityModel"
                },
                SourceModel {
                    model: d.loadingItemsModel
                    markerRoleValue: "loadingItemsModel"
                }
            ]

            markerRoleName: "sourceGroup"
        }

        readonly property bool hasCollectibles: d.nonCommunityModel.count || d.loadingItemsModel.count
        readonly property bool hasCommunityCollectibles: d.communityModel.count || d.loadingItemsModel.count

        readonly property bool onlyOneType: !hasCollectibles || !hasCommunityCollectibles

        readonly property var nwFilters: root.networkFilters.split(":")
        readonly property var addrFilters: root.addressFilters.split(":").map((addr) => addr.toLowerCase())

        function containsAnyAddress(ownership, filterList) {
            for (let i = 0; i < ownership.count; i++) {
                let accountAddress = ModelUtils.get(ownership, i, "accountAddress").toLowerCase()
                if (filterList.includes(accountAddress)) {
                    return true
                }
            }
            return false
        }

        function getLatestTimestmap(ownership, filterList) {
            let latest = 0
            for (let i = 0; i < ownership.count; i++) {
                let accountAddress = ModelUtils.get(ownership, i, "accountAddress").toLowerCase()
                if (filterList.includes(accountAddress)) {
                    let txTimestamp = ModelUtils.get(ownership, i, "txTimestamp")
                    latest = Math.max(latest, txTimestamp)
                }
            }
            return latest
        }
    }

    component CustomSFPM: SortFilterProxyModel {
        id: customFilter
        property bool isCommunity

        sourceModel: d.sourceModel
        proxyRoles: [
            JoinRole {
                name: "groupName"
                roleNames: ["collectionName", "communityName"]
            },
            FastExpressionRole {
                name: "lastTxTimestamp"
                expression: d.addrFilters, d.getLatestTimestmap(model.ownership, d.addrFilters)
                expectedRoles: ["ownership"]
            }
        ]
        filters: [
            FastExpressionFilter {
                expression: {
                    d.addrFilters
                    return d.nwFilters.includes(model.chainId+"") && d.containsAnyAddress(model.ownership, d.addrFilters)
                }
                expectedRoles: ["chainId", "ownership"]
            },
            FastExpressionFilter {
                expression: {
                    root.controller.revision
                    return root.controller.filterAcceptsSymbol(model.symbol) && (customFilter.isCommunity ? !!model.communityId : !model.communityId)
                }
                expectedRoles: ["symbol", "communityId"]
            },
            FastExpressionFilter {
                enabled: customFilter.isCommunity && cmbFilter.hasEnabledFilters
                expression: cmbFilter.selectedFilterGroupIds.includes(model.communityId) ||
                            (!model.communityId && cmbFilter.selectedFilterGroupIds.includes(""))
                expectedRoles: ["communityId"]
            },
            FastExpressionFilter {
                enabled: !customFilter.isCommunity && cmbFilter.hasEnabledFilters
                expression: cmbFilter.selectedFilterGroupIds.includes(model.collectionUid) ||
                            (!model.collectionUid && cmbFilter.selectedFilterGroupIds.includes(""))
                expectedRoles: ["collectionUid"]
            }
        ]
        sorters: [
            FastExpressionSorter {
                expression: {
                    root.controller.revision
                    return root.controller.compareTokens(modelLeft.symbol, modelRight.symbol)
                }
                enabled: d.isCustomView
                expectedRoles: ["symbol"]
            },
            RoleSorter {
                roleName: cmbTokenOrder.currentSortRoleName
                sortOrder: cmbTokenOrder.currentSortOrder
                enabled: !d.isCustomView
            }
        ]
    }

    Settings {
        id: settings
        category: "CollectiblesViewSortSettings"
        property int currentSortValue: SortOrderComboBox.TokenOrderDateAdded
        property alias currentSortOrder: cmbTokenOrder.currentSortOrder
        property alias selectedFilterGroupIds: cmbFilter.selectedFilterGroupIds
    }

    Component.onCompleted: {
        settings.sync()
        cmbTokenOrder.currentIndex = cmbTokenOrder.indexOfValue(settings.currentSortValue)
    }

    Component.onDestruction: {
        settings.currentSortValue = cmbTokenOrder.currentValue
    }

    ColumnLayout {
        Layout.fillWidth: true
        Layout.fillHeight: false
        Layout.preferredHeight: root.filterVisible ? implicitHeight : 0
        spacing: 20
        opacity: root.filterVisible ? 1 : 0

        Behavior on Layout.preferredHeight { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
        Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }

        StatusDialogDivider {
            Layout.fillWidth: true
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Style.current.halfPadding

            FilterComboBox {
                id: cmbFilter
                regularTokensModel: root.controller.regularTokensModel
                collectionGroupsModel: root.controller.collectionGroupsModel
                communityTokenGroupsModel: root.controller.communityTokenGroupsModel
                hasCommunityGroups: d.hasCommunityCollectibles
            }

            Rectangle {
                Layout.preferredHeight: 34
                Layout.preferredWidth: 1
                Layout.leftMargin: 12
                Layout.rightMargin: 12
                color: Theme.palette.baseColor2
            }

            StatusBaseText {
                color: Theme.palette.baseColor1
                font.pixelSize: Style.current.additionalTextSize
                text: qsTr("Sort by:")
            }

            SortOrderComboBox {
                id: cmbTokenOrder
                hasCustomOrderDefined: root.controller.hasSettings
                model: [
                    { value: SortOrderComboBox.TokenOrderDateAdded, text: qsTr("Date added"), icon: "calendar", sortRoleName: "lastTxTimestamp" }, // Custom SFPM role
                    { value: SortOrderComboBox.TokenOrderAlpha, text: qsTr("Collectible name"), icon: "bold", sortRoleName: "name" },
                    { value: SortOrderComboBox.TokenOrderGroupName, text: qsTr("Collection/community name"), icon: "group", sortRoleName: "groupName" }, // Custom SFPM role communityName || collectionName
                    { value: SortOrderComboBox.TokenOrderCustom, text: qsTr("Custom order"), icon: "exchange", sortRoleName: "" },
                    { value: SortOrderComboBox.TokenOrderNone, text: "---", icon: "", sortRoleName: "" }, // separator
                    { value: SortOrderComboBox.TokenOrderCreateCustom, text: hasCustomOrderDefined ? qsTr("Edit custom order →") : qsTr("Create custom order →"),
                        icon: "", sortRoleName: "" }
                ]
                onCreateOrEditRequested: {
                    root.manageTokensRequested()
                }
            }

            Item { Layout.fillWidth: true }

            StatusLinkText {
                visible: cmbFilter.hasEnabledFilters
                normalColor: Theme.palette.primaryColor1
                text: qsTr("Clear filter")
                onClicked: cmbFilter.clearFilter()
            }
        }

        StatusDialogDivider {
            Layout.fillWidth: true
        }
    }

    ShapeRectangle {
        Layout.fillWidth: true
        Layout.topMargin: Style.current.padding
        visible: !d.hasCollectibles && !d.hasCommunityCollectibles
        text: qsTr("Collectibles will appear here")
    }

    DoubleFlickableWithFolding {
        id: doubleFlickable

        Layout.fillWidth: true
        Layout.fillHeight: true

        clip: true

        flickable1: CustomGridView {
            id: communityCollectiblesView

            header: HeaderDelegate {
                height: d.headerHeight
                width: doubleFlickable.width
                z: 1

                text: qsTr("Community minted")

                scrolled: !doubleFlickable.atYBeginning
                checked: doubleFlickable.flickable1Folded

                onToggleClicked: doubleFlickable.flip1Folding()
                onInfoClicked: Global.openPopup(communityInfoPopupCmp)
            }

            Binding {
                target: communityCollectiblesView
                property: "header"
                when: d.onlyOneType
                value: null

                restoreMode: Binding.RestoreBindingOrValue
            }

            width: doubleFlickable.width
            cellHeight: d.communityCellHeight

            model: d.communityModelWithLoadingItems
        }

        flickable2: CustomGridView {
            id: regularCollectiblesView

            header: HeaderDelegate {
                height: d.headerHeight
                width: doubleFlickable.width
                z: 1

                text: qsTr("Others")

                checked: doubleFlickable.flickable2Folded
                scrolled: (doubleFlickable.contentY >
                           communityCollectiblesView.contentHeight
                           - d.headerHeight)
                showInfoButton: false

                onToggleClicked: doubleFlickable.flip2Folding()
            }

            Binding {
                target: regularCollectiblesView
                property: "header"
                when: d.onlyOneType
                value: null

                restoreMode: Binding.RestoreBindingOrValue
            }

            width: doubleFlickable.width
            cellHeight: d.cellHeight

            model: d.nonCommunityModelWithLoadingItems
        }
    }

    component HeaderDelegate: Rectangle {
        id: sectionDelegate

        property alias text: headerLabel.text
        property alias checked: toggleButton.checked
        property bool scrolled: false
        property alias showInfoButton: infoButton.visible

        signal toggleClicked
        signal infoClicked

        color: Theme.palette.statusListItem.backgroundColor

        RowLayout {
            anchors.fill: parent

            StatusFlatButton {
                id: toggleButton

                checkable: true
                size: StatusBaseButton.Size.Small
                icon.name: checked ? "next" : "chevron-down"
                textColor: Theme.palette.baseColor1
                textHoverColor: Theme.palette.directColor1

                onToggled: sectionDelegate.toggleClicked()
            }
            StatusBaseText {
                id: headerLabel

                Layout.fillWidth: true

                color: Theme.palette.baseColor1
                elide: Text.ElideRight
            }

            StatusFlatButton {
                id: infoButton

                icon.name: "info"
                textColor: Theme.palette.baseColor1

                onClicked: sectionDelegate.infoClicked()
            }
        }

        Rectangle {
            width: parent.width
            height: 4
            anchors.top: parent.bottom

            color: Theme.palette.directColor8
            visible: !sectionDelegate.checked && sectionDelegate.scrolled
        }
    }

    component CustomGridView: StatusGridView {
        id: gridView

        interactive: false

        cellWidth: d.cellWidth
        delegate: collectibleDelegate
    }

    Component {
        id: collectibleDelegate
        CollectibleView {
            width: d.cellWidth
            height: isCommunityCollectible ? d.communityCellHeight : d.cellHeight
            title: model.name ? model.name : "..."
            subTitle: model.collectionName ? model.collectionName : model.collectionUid ? model.collectionUid : ""
            mediaUrl: model.mediaUrl ?? ""
            mediaType: model.mediaType ?? ""
            fallbackImageUrl: model.imageUrl ?? ""
            backgroundColor: model.backgroundColor ? model.backgroundColor : "transparent"
            isLoading: !!model.isLoading
            privilegesLevel: model.communityPrivilegesLevel ?? Constants.TokenPrivilegesLevel.Community
            ornamentColor: model.communityColor ?? "transparent"
            communityId: model.communityId ?? ""
            communityName: model.communityName ?? ""
            communityImage: model.communityImage ?? ""

            onClicked: root.collectibleClicked(model.chainId, model.contractAddress, model.tokenId, model.symbol)
            onRightClicked: {
                Global.openMenu(tokenContextMenu, this,
                                {symbol: model.symbol, tokenName: model.name, tokenImage: model.imageUrl,
                                    communityId: model.communityId, communityName: model.communityName, communityImage: model.communityImage})
            }
            onSwitchToCommunityRequested: (communityId) => root.switchToCommunityRequested(communityId)
        }
    }

    Component {
        id: tokenContextMenu
        StatusMenu {
            onClosed: destroy()

            property string symbol
            property string tokenName
            property string tokenImage
            property string communityId
            property string communityName
            property string communityImage

            StatusAction {
                enabled: root.sendEnabled
                visibleOnDisabled: true
                icon.name: "send"
                text: qsTr("Send")
                onTriggered: root.sendRequested(symbol)
            }
            StatusAction {
                icon.name: "receive"
                text: qsTr("Receive")
                onTriggered: root.receiveRequested(symbol)
            }
            StatusMenuSeparator {}
            StatusAction {
                icon.name: "settings"
                text: qsTr("Manage tokens")
                onTriggered: root.manageTokensRequested()
            }
            StatusAction {
                enabled: symbol !== Constants.ethToken
                type: StatusAction.Type.Danger
                icon.name: "hide"
                text: qsTr("Hide collectible")
                onTriggered: Global.openConfirmHideCollectiblePopup(symbol, tokenName, tokenImage, !!communityId)
            }
            StatusAction {
                enabled: !!communityId
                type: StatusAction.Type.Danger
                icon.name: "hide"
                text: qsTr("Hide all collectibles from this community")
                onTriggered: Global.openPopup(confirmHideCommunityCollectiblesPopup, {communityId, communityName, communityImage})
            }
        }
    }

    Component {
        id: communityInfoPopupCmp
        StatusDialog {
            destroyOnClose: true
            title: qsTr("What are community collectibles?")
            standardButtons: Dialog.Ok
            width: 520
            contentItem: StatusBaseText {
                wrapMode: Text.Wrap
                text: qsTr("Community collectibles are collectibles that have been minted by a community. As these collectibles cannot be verified, always double check their origin and validity before interacting with them. If in doubt, ask a trusted member or admin of the relevant community.")
            }
        }
    }

    Component {
        id: confirmHideCommunityCollectiblesPopup
        ConfirmationDialog {
            property string communityId
            property string communityName
            property string communityImage

            width: 520
            destroyOnClose: true
            confirmButtonLabel: qsTr("Hide '%1' collectibles").arg(communityName)
            cancelBtnType: ""
            showCancelButton: true
            headerSettings.title: qsTr("Hide %1 community collectibles").arg(communityName)
            headerSettings.asset.name: communityImage
            confirmationText: qsTr("Are you sure you want to hide all community collectibles minted by %1? You will no longer see or be able to interact with these collectibles anywhere inside Status.").arg(communityName)
            onCancelButtonClicked: close()
            onConfirmButtonClicked: {
                root.controller.showHideGroup(communityId, false)
                close()
                Global.displayToastMessage(
                    qsTr("%1 community collectibles were successfully hidden. You can toggle collectible visibility via %2.").arg(communityName)
                            .arg(`<a style="text-decoration:none" href="#${Constants.appSection.profile}/${Constants.settingsSubsection.wallet}/${Constants.walletSettingsSubsection.manageCollectibles}">` + qsTr("Settings", "Go to Settings") + "</a>"),
                    "",
                    "checkmark-circle",
                    false,
                    Constants.ephemeralNotificationType.success,
                    ""
                )
            }
        }
    }
}
