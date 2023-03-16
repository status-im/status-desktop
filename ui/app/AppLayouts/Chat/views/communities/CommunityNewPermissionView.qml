import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Utils 0.1

import AppLayouts.Chat.helpers 1.0
import utils 1.0
import shared.panels 1.0

import SortFilterProxyModel 0.2

import AppLayouts.Chat.panels.communities 1.0

import "../../../Chat/controls/community"

StatusScrollView {
    id: root

    property var rootStore
    property var store

    property int viewWidth: 560 // by design
    property bool isEditState: false
    property bool dirty: {

        const trick = d.triggerDirtyTool // Trick: Used to force the reevaluation of dirty when an item of the list is updated

        // Holdings:
        if (d.checkIfHoldingsDirty())
            return true

        // Channels
        if (d.checkIfInDirty())
            return true

        // Permissions:
        let dirtyPermissionObj = false
        if(root.permissionObject && d.dirtyValues.permissionObject.key !== null) {
            dirtyPermissionObj = (d.dirtyValues.permissionObject.key !== root.permissionObject.key) ||
                    (d.dirtyValues.permissionObject.text !== root.permissionObject.text) ||
                    (d.dirtyValues.permissionObject.imageSource !== root.permissionObject.imageSource)
        } else {
            dirtyPermissionObj = d.dirtyValues.permissionObject.key !== null
        }


        return dirtyPermissionObj || d.dirtyValues.isPrivateDirty
    }
    property bool saveChanges: false
    property bool resetChanges: false

    property int permissionIndex

    // roles: type, key, name, amount, imageSource
    property var holdingsModel: ListModel {}

    // roles: key, text, imageSource
    property var permissionObject

    // roles: itemId, text, emoji, color
    property var channelsModel: ListModel {}

    property bool isPrivate

    signal permissionCreated()

    QtObject {
        id: d

        readonly property int maxHoldingsItems: 5

        readonly property int dropdownHorizontalOffset: 4
        readonly property int dropdownVerticalOffset: 1

        property int permissionType: PermissionTypes.Type.None

        readonly property bool isCommunityPermission:
            permissionType === PermissionTypes.Type.Admin ||
            permissionType === PermissionTypes.Type.Member

        onPermissionTypeChanged: {
            if (permissionType === PermissionTypes.Type.Admin) {
                d.dirtyValues.isPrivateDirty = (root.isPrivate === false)
            } else {
                if (permissionType === PermissionTypes.Type.Moderator) {
                    d.dirtyValues.isPrivateDirty = (root.isPrivate === false)
                } else {
                    d.dirtyValues.isPrivateDirty = (root.isPrivate === true)
                }
            }
        }

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

        // Trick: Used to force the reevaluation of dirty when an item of the list is updated
        property int triggerDirtyTool: 0

        property QtObject dirtyValues: QtObject {
            property ListModel holdingsModel: ListModel {}
            property ListModel channelsModel: ListModel {}

            property QtObject permissionObject: QtObject {
               property var key: null
               property string text: ""
               property string imageSource: ""
            }
            property bool isPrivateDirty: false

            function getIndexOfKey(key) {
                const count = holdingsModel.count

                for (let i = 0; i < count; i++)
                    if (holdingsModel.get(i).key === key)
                        return i

                return -1
            }

            function getTokenKeysAndAmounts() {
                const keysAndAmounts = []
                const count = holdingsModel.count

                for (let i = 0; i < count; i++) {
                    const item = holdingsModel.get(i)

                    if (item.type === HoldingTypes.Type.Ens)
                        continue

                    keysAndAmounts.push({ key: item.key, amount: item.amount })
                }

                return keysAndAmounts
            }

            function getEnsNames() {
                const names = []
                const count = holdingsModel.count

                for (let i = 0; i < count; i++) {
                    const item = holdingsModel.get(i)

                    if (item.type !== HoldingTypes.Type.Ens)
                        continue

                    names.push(item.name)
                }

                return names
            }

            // TODO: Channels
        }

        function saveChanges() {

            root.store.editPermission(root.permissionIndex,
                                      d.dirtyValues.holdingsModel,
                                      d.dirtyValues.permissionObject,
                                      d.dirtyValues.channelsModel,
                                      d.dirtyValues.isPrivateDirty ? !root.isPrivate : root.isPrivate)
        }

        function loadInitValues() {
            // Holdings:
            d.dirtyValues.holdingsModel.clear()

            if (root.holdingsModel) {
                for (let i = 0; i < root.holdingsModel.count; i++) {
                    const item = root.holdingsModel.get(i)

                    const initItem = {
                        type: item.type,
                        key: item.key,
                        name: item.name,
                        amount: item.amount,
                        imageSource: item.imageSource
                    }

                    if (item.shortName)
                        initItem.shortName = item.shortName

                    d.dirtyValues.holdingsModel.append(initItem)
                }
            }

            // Permissions:
            d.dirtyValues.permissionObject.key = root.permissionObject ? root.permissionObject.key : null
            d.dirtyValues.permissionObject.text = root.permissionObject ? root.permissionObject.text : ""
            d.dirtyValues.permissionObject.imageSource = root.permissionObject ? root.permissionObject.imageSource : ""

            d.permissionType = root.permissionObject ? root.permissionObject.key : PermissionTypes.Type.None

            // Channels
            d.dirtyValues.channelsModel.clear()

            if (root.channelsModel) {
                for (let c = 0; c < root.channelsModel.count; c++) {
                    const item = root.channelsModel.get(c)

                    const initItem = {
                        itemId: item.itemId,
                        text: item.text,
                        emoji: item.emoji,
                        color: item.color,
                        operator: OperatorsUtils.Operators.None
                    }

                    d.dirtyValues.channelsModel.append(initItem)
                }
            }

            if (root.channelsModel && (root.channelsModel.count || d.dirtyValues.permissionObject.key === null)) {
                inSelector.wholeCommunitySelected = false
                inSelector.itemsModel = d.dirtyValues.channelsModel
            } else {
                inSelector.wholeCommunitySelected = true
                inSelector.itemsModel = inModelCommunity
            }

            // Is private permission
            d.dirtyValues.isPrivateDirty = false
        }

        function checkIfHoldingsDirty() {
            if (!root.holdingsModel)
                return d.dirtyValues.holdingsModel.count !== 0

            if (root.holdingsModel.count !== d.dirtyValues.holdingsModel.count)
                return true

            // Check element by element
            const count = root.holdingsModel.count
            let equals = 0

            for (let i = 0; i < count; i++) {
                const item1 = root.holdingsModel.get(i)

                for (let j = 0; j < count; j++) {
                    const item2 = d.dirtyValues.holdingsModel.get(j)

                    if (item1.key === item2.key
                            && item1.name === item2.name
                            && item1.shortName === item2.shortName
                            && item1.amount === item2.amount) {
                        equals++
                    }
                }
            }

            return equals !== count
        }

        function checkIfInDirty() {
            if (!root.channelsModel)
                return d.dirtyValues.channelsModel.count !== 0

            if (root.channelsModel.count !== d.dirtyValues.channelsModel.count)
                return true

            const count = root.channelsModel.count
            let equals = 0

            for (let i = 0; i < count; i++) {
                const item1 = root.channelsModel.get(i)

                for (let j = 0; j < count; j++) {
                    const item2 = d.dirtyValues.channelsModel.get(j)

                    if (item1.itemId === item2.itemId
                            && item1.text === item2.text
                            && item1.emoji === item2.emoji
                            && item1.color === item2.color) {
                        equals++
                    }
                }
            }

            return equals !== count
        }

        function holdingsTextFormat(type, name, amount) {
            return CommunityPermissionsHelpers.setHoldingsTextFormat(type, name, amount)
        }
    }

    contentWidth: mainLayout.width
    contentHeight: mainLayout.height

    onSaveChangesChanged: if(saveChanges) d.saveChanges()
    onResetChangesChanged: if(resetChanges)  d.loadInitValues()
    onPermissionObjectChanged: d.loadInitValues()

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
            itemsModel: SortFilterProxyModel {
                sourceModel: d.dirtyValues.holdingsModel

                proxyRoles: [
                    ExpressionRole {
                        name: "text"
                         // Direct call for singleton function is not handled properly by SortFilterProxyModel that's why `holdingsTextFormat` is used instead.
                        expression: d.holdingsTextFormat(model.type, model.name, model.amount)
                    },
                    ExpressionRole {
                        name: "operator"

                        // Direct call for singleton enum is not handled properly by SortFilterProxyModel.
                        readonly property int none: OperatorsUtils.Operators.None

                        expression: none
                    }
                ]
            }

            HoldingsDropdown {
                id: dropdown

                store: root.store

                function addItem(type, item, amount) {
                    const key = item.key
                    const name = item.shortName ? item.shortName : item.name
                    const imageSource = item.iconSource.toString()

                    d.dirtyValues.holdingsModel.append({ type, key, name, amount, imageSource })
                }

                function prepareUpdateIndex(key) {
                    const itemIndex = tokensSelector.editedIndex
                    const existingIndex = d.dirtyValues.getIndexOfKey(key)

                    if (itemIndex !== -1 && existingIndex !== -1 && itemIndex !== existingIndex) {
                        const previousKey = d.dirtyValues.holdingsModel.get(itemIndex).key
                        d.dirtyValues.holdingsModel.remove(existingIndex)
                        return d.dirtyValues.getIndexOfKey(previousKey)
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
                    const key = "ENS_" + domain
                    const icon = Style.svg("profile/ensUsernames")

                    d.dirtyValues.holdingsModel.append({type: HoldingTypes.Type.Ens, key, name: domain, amount: 1, imageSource: icon })
                    dropdown.close()
                }

                onUpdateAsset: {
                    const itemIndex = prepareUpdateIndex(key)

                    const modelItem = CommunityPermissionsHelpers.getTokenByKey(store.assetsModel, key)
                    const name = modelItem.shortName ? modelItem.shortName : modelItem.name
                    const imageSource = modelItem.iconSource.toString()

                    d.dirtyValues.holdingsModel.set(itemIndex, { type: HoldingTypes.Type.Asset, key, name, amount, imageSource })
                    d.triggerDirtyTool++
                    dropdown.close()
                }

                onUpdateCollectible: {
                    const itemIndex = prepareUpdateIndex(key)

                    const modelItem = CommunityPermissionsHelpers.getTokenByKey(store.collectiblesModel, key)
                    const name = modelItem.name
                    const imageSource = modelItem.iconSource.toString()

                    d.dirtyValues.holdingsModel.set(itemIndex, { type: HoldingTypes.Type.Collectible, key, name, amount, imageSource })
                    d.triggerDirtyTool++
                    dropdown.close()
                }

                onUpdateEns: {
                    const key = "ENS_" + domain
                    const icon = Style.svg("profile/ensUsernames")

                    d.dirtyValues.holdingsModel.set(tokensSelector.editedIndex, { type: HoldingTypes.Type.Ens, key, name: domain, amount: 1, imageSource: icon })
                    d.triggerDirtyTool++
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
                        dropdown.ensDomainName = modelItem.name
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
            itemsModel: d.dirtyValues.permissionObject.key ? d.dirtyValues.permissionObject : null

            addButton.visible: !root.permissionObject

            PermissionsDropdown {
                id: permissionsDropdown

                initialPermissionType: d.permissionType
                enableAdminPermission: root.store.isOwner

                onDone: {
                    if (d.permissionType === permissionType) {
                        permissionsDropdown.close()
                        return
                    }

                    d.permissionType = permissionType
                    d.dirtyValues.permissionObject.key = permissionType
                    d.dirtyValues.permissionObject.text = title
                    d.dirtyValues.permissionObject.imageSource = asset
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
        RowLayout {
            Layout.topMargin: 12
            Layout.fillWidth: true
            Layout.leftMargin: 16
            Layout.rightMargin: Layout.leftMargin
            spacing: 16
            StatusRoundIcon {
                asset.name: "hide"
            }
            ColumnLayout {
                Layout.fillWidth: true
                StatusBaseText {
                    text: qsTr("Hide permission")
                    color: Theme.palette.directColor1
                    font.pixelSize: 15
                }
                StatusBaseText {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    text: qsTr("Make this permission hidden from members who don’t meet it’s requirements")
                    color: Theme.palette.baseColor1
                    font.pixelSize: 15
                    lineHeight: 1.2
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                    clip: true
                }
            }
            StatusSwitch {
                enabled: d.permissionType !== PermissionTypes.Type.Admin
                checked: d.dirtyValues.isPrivateDirty ? !root.isPrivate : root.isPrivate
                onToggled: d.dirtyValues.isPrivateDirty = (root.isPrivate !== checked)
            }
        }

        PermissionConflictWarningPanel{
            id: conflictPanel

            visible: store.permissionConflict.exists
            Layout.fillWidth: true
            Layout.topMargin: 50 // by desing
            holdings: store.permissionConflict.holdings
            permissions: store.permissionConflict.permissions
            channels: store.permissionConflict.channels
        }

        StatusButton {
            visible: !root.isEditState
            Layout.topMargin: conflictPanel.visible ? conflictPanel.Layout.topMargin : 24 // by design
            text: qsTr("Create permission")
            enabled: d.dirtyValues.holdingsModel.count > 0
                     && d.dirtyValues.permissionObject.key !== null
                     && (d.dirtyValues.channelsModel.count > 0 || d.isCommunityPermission)
            Layout.preferredHeight: 44
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            onClicked: {
                root.store.createPermission(d.dirtyValues.holdingsModel,
                                            d.dirtyValues.permissionObject,
                                            d.dirtyValues.isPrivateDirty ? !root.isPrivate : root.isPrivate,
                                            d.dirtyValues.channelsModel)
                root.permissionCreated()
            }
        }
    }
}
