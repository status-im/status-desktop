import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import Qt.labs.settings 1.1

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Models 0.1
import StatusQ.Internal 0.1
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

        readonly property bool hasCollectibles: regularCollectiblesView.count
        readonly property bool hasCommunityCollectibles: communityCollectiblesView.count

        readonly property var controller: ManageTokensController {
            settingsKey: "WalletCollectibles"
        }

        function hideAllCommunityTokens(communityId) {
            const tokenSymbols = ModelUtils.getAll(communityCollectiblesView.model, "symbol", "communityId", communityId)
            d.controller.settingsHideCommunityTokens(communityId, tokenSymbols)
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
            ExpressionFilter {
                expression: {
                    d.controller.settingsDirty
                    return d.controller.filterAcceptsSymbol(model.symbol) && (customFilter.isCommunity ? !!model.communityId : !model.communityId)
                }
            }
        ]
        sorters: [
            ExpressionSorter {
                expression: {
                    d.controller.settingsDirty
                    return d.controller.lessThan(modelLeft.symbol, modelRight.symbol)
                }
                enabled: d.isCustomView
            },
            RoleSorter {
                roleName: cmbTokenOrder.currentSortRoleName
                sortOrder: cmbTokenOrder.currentSortOrder
                enabled: !d.isCustomView
            }
        ]
    }

    Settings {
        category: "CollectiblesViewSortSettings"
        property alias currentSortField: cmbTokenOrder.currentIndex
        property alias currentSortOrder: cmbTokenOrder.currentSortOrder
    }

    ColumnLayout {
        Layout.fillWidth: true
        Layout.preferredHeight: root.filterVisible && (d.hasCollectibles || d.hasCommunityCollectibles) ? implicitHeight : 0
        spacing: 20
        opacity: Layout.preferredHeight < implicitHeight ? 0 : 1

        Behavior on Layout.preferredHeight { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }
        Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }

        StatusDialogDivider {
            Layout.fillWidth: true
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Style.current.halfPadding

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
        }

        StatusDialogDivider {
            Layout.fillWidth: true
        }
    }

    ShapeRectangle {
        Layout.fillWidth: true
        visible: !d.hasCollectibles && !d.hasCommunityCollectibles
        text: qsTr("Collectibles will appear here")
    }

    StatusScrollView {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.topMargin: Style.current.padding
        leftPadding: 0
        verticalPadding: 0
        contentWidth: availableWidth

        ColumnLayout {
            width: parent.width
            spacing: 0

            CustomGridView {
                id: regularCollectiblesView
                cellHeight: d.cellHeight
                model: CustomSFPM {}
            }

            StatusDialogDivider {
                Layout.fillWidth: true
                Layout.topMargin: Style.current.padding
                Layout.bottomMargin: Style.current.halfPadding
                visible: d.hasCommunityCollectibles
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin: Style.current.padding
                Layout.rightMargin: Style.current.smallPadding
                Layout.bottomMargin: 4
                visible: d.hasCommunityCollectibles
                StatusBaseText {
                    text: qsTr("Community collectibles")
                    color: Theme.palette.baseColor1
                }
                Item { Layout.fillWidth: true }
                StatusFlatButton {
                    Layout.preferredWidth: 32
                    Layout.preferredHeight: 32
                    icon.name: "info"
                    textColor: Theme.palette.baseColor1
                    horizontalPadding: 0
                    verticalPadding: 0
                    onClicked: Global.openPopup(communityInfoPopupCmp)
                }
            }

            CustomGridView {
                id: communityCollectiblesView
                cellHeight: d.communityCellHeight
                model: CustomSFPM { isCommunity: true }
            }
        }
    }

    component CustomGridView: StatusGridView {
        id: gridView

        Layout.fillWidth: true
        Layout.preferredHeight: contentHeight
        interactive: false

        cellWidth: d.cellWidth
        delegate: collectibleDelegate

        // For some reason fetchMore is not working properly.
        // Adding some logic here as a workaround.
        visibleArea.onYPositionChanged: checkLoadMore()
        visibleArea.onHeightRatioChanged: checkLoadMore()

        Connections {
            target: gridView
            function onVisibleChanged() {
                gridView.checkLoadMore()
            }
        }

        Connections {
            target: root.collectiblesModel
            function onHasMoreChanged() {
                gridView.checkLoadMore()
            }
            function onIsFetchingChanged() {
                gridView.checkLoadMore()
            }
        }

        function checkLoadMore() {
            // If there is no more items to load or we're already fetching, return
            if (!gridView.visible || !root.collectiblesModel.hasMore || root.collectiblesModel.isFetching)
                return
            // Only trigger if close to the bottom of the list
            if (visibleArea.yPosition + visibleArea.heightRatio > 0.9)
                root.collectiblesModel.loadMore()
        }
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
