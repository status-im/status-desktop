import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Utils 0.1

import utils 1.0
import shared.panels 1.0

import SortFilterProxyModel 0.2

import AppLayouts.Chat.helpers 1.0
import AppLayouts.Chat.panels.communities 1.0

import "../../../Chat/controls/community"

StatusScrollView {
    id: root

    property var rootStore
    property var store

    property int viewWidth: 560 // by design
    property bool isEditState: false

    readonly property bool dirty:
        !holdingsModelComparator.equal ||
        !channelsModelComparator.equal ||
        root.isPrivate !== d.dirtyValues.isPrivate ||
        root.permissionType !== d.dirtyValues.permissionType

    property int permissionType: PermissionTypes.Type.None
    property bool isPrivate: false

    // roles: type, key, name, amount, imageSource
    property var holdingsModel: ListModel {}

    // roles: itemId, text, emoji, color
    property var channelsModel: ListModel {}

    readonly property alias dirtyValues: d.dirtyValues

    property alias duplicationWarningVisible: duplicationPanel.visible

    signal createPermissionClicked

    function resetChanges() {
        d.loadInitValues()
    }

    ModelsComparator {
        id: holdingsModelComparator

        modelA: root.dirtyValues.holdingsModel
        modelB: root.holdingsModel

        roles: ["key", "name", "shortName", "amount"]
        mode: ModelsComparator.CompareMode.Set
    }

    ModelsComparator {
        id: channelsModelComparator

        modelA: root.dirtyValues.channelsModel
        modelB: root.channelsModel

        roles: ["itemId", "text", "emoji", "color"]
        mode: ModelsComparator.CompareMode.Set
    }

    QtObject {
        id: d

        readonly property int maxHoldingsItems: 5

        readonly property int dropdownHorizontalOffset: 4
        readonly property int dropdownVerticalOffset: 1

        readonly property bool isCommunityPermission:
            dirtyValues.permissionType === PermissionTypes.Type.Admin ||
            dirtyValues.permissionType === PermissionTypes.Type.Member

        onIsCommunityPermissionChanged: {
            if (isCommunityPermission) {
                d.dirtyValues.channelsModel.clear()
                inSelector.wholeCommunitySelected = true
                inSelector.itemsModel = inModelCommunity
            } else {
                inSelector.itemsModel = 0
                inSelector.wholeCommunitySelected = false
                inSelector.itemsModel = d.dirtyValues.channelsModel
            }
        }

        readonly property QtObject dirtyValues: QtObject {
            readonly property ListModel holdingsModel: ListModel {}
            readonly property ListModel channelsModel: ListModel {}

            property int permissionType: PermissionTypes.Type.None
            property bool isPrivate: false

            Binding on isPrivate {
                value: (d.dirtyValues.permissionType === PermissionTypes.Type.Admin) ||
                       (d.dirtyValues.permissionType === PermissionTypes.Type.Moderator)
            }

            function getHoldingIndex(key) {
                return ModelUtils.indexOf(holdingsModel, "key", key)
            }

            function getTokenKeysAndAmounts() {
                return ModelUtils.modelToArray(holdingsModel, ["type", "key", "amount"])
                    .filter(item => item.type !== HoldingTypes.Type.Ens)
                    .map(item => ({ key: item.key, amount: item.amount }))
            }

            function getEnsNames() {
                return ModelUtils.modelToArray(holdingsModel, ["type", "name"])
                    .filter(item => item.type === HoldingTypes.Type.Ens)
                    .map(item => item.name)
            }
        }

        function loadInitValues() {
            // Holdings:
            d.dirtyValues.holdingsModel.clear()

            d.dirtyValues.holdingsModel.append(
                        ModelUtils.modelToArray(root.holdingsModel, ["type", "key", "amount"]))

            // Permissions:
            d.dirtyValues.permissionType = root.permissionType

            // Channels
            d.dirtyValues.channelsModel.clear()

            d.dirtyValues.channelsModel.append(
                        ModelUtils.modelToArray(root.channelsModel,
                                                ["itemId", "text", "emoji", "color", "operator"]))

            if (root.channelsModel && (root.channelsModel.count || d.dirtyValues.permissionType === PermissionTypes.Type.None)) {
                inSelector.wholeCommunitySelected = false
                inSelector.itemsModel = d.dirtyValues.channelsModel
            } else {
                inSelector.wholeCommunitySelected = true
                inSelector.itemsModel = inModelCommunity
            }

            // Is private permission
            d.dirtyValues.isPrivate = root.isPrivate
        }
    }

    contentWidth: mainLayout.width
    contentHeight: mainLayout.height

    onPermissionTypeChanged: Qt.callLater(() => d.loadInitValues())

    ColumnLayout {
        id: mainLayout
        width: root.viewWidth
        spacing: 0

        CurveSeparatorWithText {
            Layout.alignment: Qt.AlignLeft
            Layout.leftMargin: 14
            text: qsTr("Anyone")
        }

        StatusItemSelector {
            id: tokensSelector

            property int editedIndex: -1

            Layout.fillWidth: true
            icon: Style.svg("contact_verified")
            title: qsTr("Who holds")
            defaultItemText: qsTr("Example: 10 SNT")
            tagLeftPadding: 2
            asset.height: 28
            asset.width: asset.height
            addButton.visible: itemsModel.count < d.maxHoldingsItems

            itemsModel: HoldingsSelectionModel {
                sourceModel: d.dirtyValues.holdingsModel

                assetsModel: root.store.assetsModel
                collectiblesModel: root.store.collectiblesModel
            }

            HoldingsDropdown {
                id: dropdown

                store: root.store

                function addItem(type, item, amount) {
                    const key = item.key

                    d.dirtyValues.holdingsModel.append({ type, key, amount })
                }

                function prepareUpdateIndex(key) {
                    const itemIndex = tokensSelector.editedIndex
                    const existingIndex = d.dirtyValues.getHoldingIndex(key)

                    if (itemIndex !== -1 && existingIndex !== -1 && itemIndex !== existingIndex) {
                        const previousKey = d.dirtyValues.holdingsModel.get(itemIndex).key
                        d.dirtyValues.holdingsModel.remove(existingIndex)
                        return d.dirtyValues.getHoldingIndex(previousKey)
                    }

                    if (itemIndex === -1) {
                        return existingIndex
                    }

                    return itemIndex
                }

                onOpened: {
                    usedTokens = d.dirtyValues.getTokenKeysAndAmounts()
                    usedEnsNames = d.dirtyValues.getEnsNames().filter(item => item !== ensDomainName)
                }

                onAddAsset: {
                    const modelItem = CommunityPermissionsHelpers.getTokenByKey(store.assetsModel, key)
                    addItem(HoldingTypes.Type.Asset, modelItem, amount)
                    dropdown.close()
                }

                onAddCollectible: {
                    const modelItem = CommunityPermissionsHelpers.getTokenByKey(store.collectiblesModel, key)
                    addItem(HoldingTypes.Type.Collectible, modelItem, amount)
                    dropdown.close()
                }

                onAddEns: {
                    d.dirtyValues.holdingsModel.append(
                                { type: HoldingTypes.Type.Ens, key: domain, amount: 1 })
                    dropdown.close()
                }

                onUpdateAsset: {
                    const itemIndex = prepareUpdateIndex(key)
                    const modelItem = CommunityPermissionsHelpers.getTokenByKey(store.assetsModel, key)

                    d.dirtyValues.holdingsModel.set(itemIndex,
                                                    { type: HoldingTypes.Type.Asset, key, amount })
                    dropdown.close()
                }

                onUpdateCollectible: {
                    const itemIndex = prepareUpdateIndex(key)
                    const modelItem = CommunityPermissionsHelpers.getTokenByKey(store.collectiblesModel, key)

                    d.dirtyValues.holdingsModel.set(itemIndex,
                                                    { type: HoldingTypes.Type.Collectible, key, amount })
                    dropdown.close()
                }

                onUpdateEns: {
                    d.dirtyValues.holdingsModel.set(tokensSelector.editedIndex,
                                                    { type: HoldingTypes.Type.Ens, key: domain, amount: 1 })
                    dropdown.close()
                }

                onRemoveClicked: {
                    d.dirtyValues.holdingsModel.remove(tokensSelector.editedIndex)
                    dropdown.close()
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

                const modelItem = tokensSelector.itemsModel.get(index)

                switch(modelItem.type) {
                    case HoldingTypes.Type.Asset:
                        dropdown.assetKey = modelItem.key
                        dropdown.assetAmount = modelItem.amount
                        break
                    case HoldingTypes.Type.Collectible:
                        dropdown.collectibleKey = modelItem.key
                        dropdown.collectibleAmount = modelItem.amount
                        break
                    case HoldingTypes.Type.Ens:
                        dropdown.ensDomainName = modelItem.key
                        break
                    default:
                        console.warn("Unsupported holdings type.")
                }

                dropdown.setActiveTab(modelItem.type)
                dropdown.openUpdateFlow()

                editedIndex = index
            }
        }
        Rectangle {
            Layout.leftMargin: 16
            Layout.preferredWidth: 2
            Layout.preferredHeight: 24
            color: Style.current.separator
        }
        StatusItemSelector {
            id: permissionsSelector

            Layout.fillWidth: true
            icon: Style.svg("profile/security")
            iconSize: 24
            useIcons: true
            title: qsTr("Is allowed to")
            defaultItemText: qsTr("Example: View and post")

            QtObject {
                id: permissionItemModelData

                readonly property int key: d.dirtyValues.permissionType
                readonly property string text: PermissionTypes.getName(key)
                readonly property string imageSource: PermissionTypes.getIcon(key)
            }

            itemsModel: d.dirtyValues.permissionType !== PermissionTypes.Type.None
                        ? permissionItemModelData : null

            addButton.visible: d.dirtyValues.permissionType === PermissionTypes.Type.None

            PermissionsDropdown {
                id: permissionsDropdown

                initialPermissionType: d.dirtyValues.permissionType
                enableAdminPermission: root.store.isOwner

                onDone: {
                    if (d.dirtyValues.permissionType === permissionType) {
                        permissionsDropdown.close()
                        return
                    }

                    d.dirtyValues.permissionType = permissionType
                    permissionsDropdown.close()
                }
            }

            addButton.onClicked: {
                permissionsDropdown.mode = PermissionsDropdown.Mode.Add
                permissionsDropdown.parent = permissionsSelector.addButton
                permissionsDropdown.x = permissionsSelector.addButton.width
                        + d.dropdownHorizontalOffset
                permissionsDropdown.y = 0
                permissionsDropdown.open()
            }

            onItemClicked: {
                if (mouse.button !== Qt.LeftButton)
                    return

                permissionsDropdown.mode = PermissionsDropdown.Mode.Update
                permissionsDropdown.parent = item
                permissionsDropdown.x = mouse.x + d.dropdownHorizontalOffset
                permissionsDropdown.y = d.dropdownVerticalOffset
                permissionsDropdown.open()
            }
        }
        Rectangle {
            Layout.leftMargin: 16
            Layout.preferredWidth: 2
            Layout.preferredHeight: 24
            color: Style.current.separator
        }
        StatusItemSelector {
            id: inSelector

            readonly property bool editable: !d.isCommunityPermission

            addButton.visible: editable
            itemsClickable: editable

            Layout.fillWidth: true
            icon: d.isCommunityPermission ? Style.svg("communities") : Style.svg("create-category")
            iconSize: 24
            title: qsTr("In")
            defaultItemText: qsTr("Example: `#general` channel")

            useLetterIdenticons: !wholeCommunitySelected || !inDropdown.communityImage

            tagLeftPadding: wholeCommunitySelected ? 2 : 6
            asset.width: wholeCommunitySelected ? 28 : 20
            asset.height: asset.width

            property bool wholeCommunitySelected: false

            function openInDropdown(parent, x, y) {
                inDropdown.parent = parent
                inDropdown.x = x
                inDropdown.y = y

                const selectedChannels = []

                if (!inSelector.wholeCommunitySelected)
                    for (let i = 0; i < d.dirtyValues.channelsModel.count; i++)
                        selectedChannels.push(d.dirtyValues.channelsModel.get(i).itemId)

                inDropdown.setSelectedChannels(selectedChannels)
                inDropdown.open()
            }

            ListModel {
                id: inModelCommunity

                readonly property string colorWorkaround: inDropdown.communityData.color

                Component.onCompleted: {
                    append({
                        imageSource: inDropdown.communityData.image,
                        text: inDropdown.communityData.name,
                        operator: OperatorsUtils.Operators.None,
                        color: ""
                    })

                    setProperty(0, "color", colorWorkaround)
                }
            }

            InDropdown {
                id: inDropdown

                model: root.rootStore.chatCommunitySectionModule.model

                readonly property var communityData: rootStore.mainModuleInst.activeSection

                communityName: communityData.name
                communityImage: communityData.image
                communityColor: communityData.color

                onChannelsSelected: {
                    d.dirtyValues.channelsModel.clear()
                    inSelector.itemsModel = 0
                    inSelector.wholeCommunitySelected = false

                    channels.forEach(channel => {
                        d.dirtyValues.channelsModel.append({
                            itemId: channel.itemId,
                            text: "#" + channel.name,
                            emoji: channel.emoji,
                            color: channel.color,
                            operator: OperatorsUtils.Operators.None
                        })
                    })

                    inSelector.itemsModel = d.dirtyValues.channelsModel
                    close()
                }

                onCommunitySelected: {
                    d.dirtyValues.channelsModel.clear()
                    inSelector.wholeCommunitySelected = true
                    inSelector.itemsModel = inModelCommunity
                    close()
                }
            }

            addButton.onClicked: {
                inDropdown.acceptMode = InDropdown.AcceptMode.Add
                openInDropdown(inSelector.addButton,
                               inSelector.addButton.width + d.dropdownHorizontalOffset, 0)
            }

            onItemClicked: {
                if (mouse.button !== Qt.LeftButton)
                    return

                inDropdown.acceptMode = InDropdown.AcceptMode.Update
                openInDropdown(item, mouse.x + d.dropdownHorizontalOffset,
                               d.dropdownVerticalOffset)
            }
        }
        Separator {
            Layout.topMargin: 24
        }

        HidePermissionPanel {
            Layout.topMargin: 12
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: Layout.leftMargin

            enabled: d.dirtyValues.permissionType !== PermissionTypes.Type.Admin
            checked: d.dirtyValues.isPrivate
            onToggled: d.dirtyValues.isPrivate = checked
        }

        PermissionConflictWarningPanel {
            id: conflictPanel

            visible: store.permissionConflict.exists
            Layout.fillWidth: true
            Layout.topMargin: 50 // by desing
            holdings: store.permissionConflict.holdings
            permissions: store.permissionConflict.permissions
            channels: store.permissionConflict.channels
        }

        PermissionDuplicationWarningPanel {
            id: duplicationPanel

            visible: false
            Layout.fillWidth: true
            Layout.topMargin: 50 // by desing
        }

        StatusButton {
            visible: !root.isEditState
            Layout.topMargin: conflictPanel.visible ? conflictPanel.Layout.topMargin : 24 // by design
            text: qsTr("Create permission")
            enabled: d.dirtyValues.holdingsModel.count > 0
                     && d.dirtyValues.permissionType !== PermissionTypes.Type.None
                     && (d.dirtyValues.channelsModel.count > 0 || d.isCommunityPermission)
                     && !root.duplicationWarningVisible
            Layout.preferredHeight: 44
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true

            onClicked: root.createPermissionClicked()
        }
    }
}
