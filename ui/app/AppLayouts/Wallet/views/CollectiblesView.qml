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

    required property var collectiblesModel
    required property string addressFilters
    required property string networkFilters
    property bool sendEnabled: true
    property bool filterVisible

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

        readonly property var renamedModel: RolesRenamingModel {
            sourceModel: root.collectiblesModel

            mapping: [
                RoleRename {
                    from: "uid"
                    to: "symbol"
                }
            ]
        }

        readonly property bool hasCollectibles: nonCommunityModel.count
        readonly property bool hasCommunityCollectibles: communityModel.count

        readonly property bool onlyOneType: !hasCollectibles || !hasCommunityCollectibles

        readonly property var controller: ManageTokensController {
            settingsKey: "WalletCollectibles"
            sourceModel: d.renamedModel
        }

        readonly property var nwFilters: root.networkFilters.split(":")
        readonly property var addrFilters: root.addressFilters.split(":").map((addr) => addr.toLowerCase())

        function hideAllCommunityTokens(communityId) {
            const tokenSymbols = ModelUtils.getAll(communityCollectiblesView.model, "symbol", "communityId", communityId)
            d.controller.settingsHideGroupTokens(communityId, tokenSymbols)
        }

        function containsAny(list, filterList) {
            for (let i = 0; i < list.length; i++) {
                if (filterList.includes(list[i].toLowerCase())) {
                    return true
                }
            }
            return false
        }
    }

    component CustomSFPM: SortFilterProxyModel {
        id: customFilter
        property bool isCommunity

        sourceModel: d.renamedModel
        proxyRoles: JoinRole {
            name: "groupName"
            roleNames: ["collectionName", "communityName"]
        }
        filters: [
            FastExpressionFilter {
                expression: {
                    d.addrFilters
                    return d.nwFilters.includes(model.chainId+"") && d.containsAny(model.ownershipAddresses.split(":"), d.addrFilters)
                }
                expectedRoles: ["chainId", "ownershipAddresses"]
            },
            FastExpressionFilter {
                expression: {
                    d.controller.settingsDirty
                    return d.controller.filterAcceptsSymbol(model.symbol) && (customFilter.isCommunity ? !!model.communityId : !model.communityId)
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
                    d.controller.settingsDirty
                    return d.controller.lessThan(modelLeft.symbol, modelRight.symbol)
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

    CustomSFPM {
        id: communityModel

        isCommunity: true
    }

    CustomSFPM {
        id: nonCommunityModel
    }

    Settings {
        category: "CollectiblesViewSortSettings"
        property alias currentSortField: cmbTokenOrder.currentIndex
        property alias currentSortOrder: cmbTokenOrder.currentSortOrder
        property alias selectedFilterGroupIds: cmbFilter.selectedFilterGroupIds
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
                regularTokensModel: d.controller.regularTokensModel
                collectionGroupsModel: d.controller.collectionGroupsModel
                communityTokenGroupsModel: d.controller.communityTokenGroupsModel
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
                hasCustomOrderDefined: d.controller.hasSettings
                model: [
                    { value: SortOrderComboBox.TokenOrderDateAdded, text: qsTr("Date added"), icon: "calendar", sortRoleName: "dateAdded" }, // FIXME sortRoleName #12942
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

            header: Item {
                id: communityHeader

                height: d.headerHeight
                width: doubleFlickable.width

                HeaderDelegate {
                    width: communityHeader.width
                    height: communityHeader.height

                    parent: doubleFlickable.contentItem
                    y: doubleFlickable.gridHeader1YInContentItem
                    z: 1

                    text: qsTr("Community minted")

                    scrolled: !doubleFlickable.atYBeginning
                    checked: doubleFlickable.flickable1Folded

                    onToggleClicked: doubleFlickable.flip1Folding()
                    onInfoClicked: Global.openPopup(communityInfoPopupCmp)
                }
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

            model: communityModel
        }

        flickable2: CustomGridView {
            id: regularCollectiblesView

            header: Item {
                id: nonCommunityHeader

                height: d.headerHeight
                width: doubleFlickable.width

                HeaderDelegate {
                    width: nonCommunityHeader.width
                    height: nonCommunityHeader.height

                    parent: doubleFlickable.contentItem
                    y: doubleFlickable.gridHeader2YInContentItem
                    z: 1

                    text: qsTr("Others")

                    checked: doubleFlickable.flickable2Folded
                    scrolled: (doubleFlickable.contentY >
                               communityCollectiblesView.contentHeight
                               - d.headerHeight)
                    showInfoButton: false

                    onToggleClicked: doubleFlickable.flip2Folding()
                }
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

            model: nonCommunityModel
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
                icon.name: checked ? "chevron-down" : "next"
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
                enabled: symbol !== "ETH"
                type: StatusAction.Type.Danger
                icon.name: "hide"
                text: qsTr("Hide collectible")
                onTriggered: Global.openPopup(confirmHideCollectiblePopup, {symbol, tokenName, tokenImage, communityId})
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
        id: confirmHideCollectiblePopup
        ConfirmationDialog {
            property string symbol
            property string tokenName
            property string tokenImage
            property string communityId

            readonly property string formattedName: tokenName + (communityId ? " (" + qsTr("community collectible") + ")" : "")

            width: 520
            destroyOnClose: true
            confirmButtonLabel: qsTr("Hide %1").arg(tokenName)
            cancelBtnType: ""
            showCancelButton: true
            headerSettings.title: qsTr("Hide %1").arg(formattedName)
            headerSettings.asset.name: tokenImage
            confirmationText: qsTr("Are you sure you want to hide %1? You will no longer see or be able to interact with this collectible anywhere inside Status.").arg(formattedName)
            onCancelButtonClicked: close()
            onConfirmButtonClicked: {
                d.controller.settingsHideToken(symbol)
                close()
                Global.displayToastMessage(
                    qsTr("%1 was successfully hidden. You can toggle collectible visibility via %2.").arg(formattedName)
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

    Component {
        id: confirmHideCommunityCollectiblesPopup
        ConfirmationDialog {
            property string communityId
            property string communityName
            property string communityImage

            width: 520
            destroyOnClose: true
            confirmButtonLabel: qsTr("Hide all collectibles minted by this community")
            cancelBtnType: ""
            showCancelButton: true
            headerSettings.title: qsTr("Hide %1 community collectibles").arg(communityName)
            headerSettings.asset.name: communityImage
            confirmationText: qsTr("Are you sure you want to hide all community collectibles minted by %1? You will no longer see or be able to interact with these collectibles anywhere inside Status.").arg(communityName)
            onCancelButtonClicked: close()
            onConfirmButtonClicked: {
                d.hideAllCommunityTokens(communityId)
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
