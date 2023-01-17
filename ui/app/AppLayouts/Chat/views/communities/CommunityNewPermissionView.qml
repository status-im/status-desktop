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

        let trick = d.triggerDirtyTool // Trick: Used to force the reevaluation of dirty when an item of the list is updated

        // Holdings:
        const dirtyHoldingsList = d.checkIfHoldingsDirty()

        // Permissions:
        let dirtyPermissionObj = false
        if(root.permissionObject && d.dirtyValues.permissionObject.key !== null) {
            dirtyPermissionObj = (d.dirtyValues.permissionObject.key !== root.permissionObject.key) ||
                    (d.dirtyValues.permissionObject.text !== root.permissionObject.text) ||
                    (d.dirtyValues.permissionObject.imageSource !== root.permissionObject.imageSource)
        }
        else {
            dirtyPermissionObj = d.dirtyValues.permissionObject.key !== null
        }

        // TODO: Channels:
        let dirtyChannelsList = false

        return dirtyHoldingsList || dirtyPermissionObj || dirtyChannelsList || d.dirtyValues.isPrivateDirty
    }
    property bool saveChanges: false
    property bool resetChanges: false

    property int permissionIndex

    // roles: type, key, name, amount, imageSource
    property var holdingsModel: ListModel {}

    // roles: key, text, imageSource
    property var permissionObject

    // TODO roles:
    property var channelsModel: ListModel {}

    property bool isPrivate

    signal permissionCreated()

    QtObject {
        id: d

        readonly property int dropdownHorizontalOffset: 4
        readonly property int dropdownVerticalOffset: 1

        property int permissionType: PermissionTypes.Type.None
        property bool triggerDirtyTool: false // Trick: Used to force the reevaluation of dirty when an item of the list is updated

        property QtObject dirtyValues: QtObject {
            property ListModel holdingsModel: ListModel {}
            property QtObject permissionObject: QtObject {
               property var key: null
               property string text: ""
               property string imageSource: ""
            }
            property bool isPrivateDirty: false

            // TODO: Channels
        }

        function saveChanges() {

            root.store.editPermission(root.permissionIndex,
                                      d.dirtyValues.holdingsModel,
                                      d.dirtyValues.permissionObject,
                                      root.channelsModel,
                                      d.dirtyValues.isPrivateDirty ? !root.isPrivate : root.isPrivate)
        }

        function loadInitValues() {
            // Holdings:
            d.dirtyValues.holdingsModel.clear()
            if(root.holdingsModel) {
                for(let i = 0; i < root.holdingsModel.count; i++) {
                    let item = root.holdingsModel.get(i)
                    let initItem = null
                    if(item.shortName) {
                        initItem =  {
                            type: item.type,
                            key: item.key,
                            name: item.name,
                            shortName: item.shortName,
                            amount: item.amount,
                            imageSource: item.imageSource
                        }
                    }
                    else {
                        initItem =  {
                            type: item.type,
                            key: item.key,
                            name: item.name,
                            amount: item.amount,
                            imageSource: item.imageSource
                        }
                    }
                    d.dirtyValues.holdingsModel.append(initItem)
                }
            }

            // Permissions:
            d.dirtyValues.permissionObject.key = root.permissionObject ? root.permissionObject.key : null
            d.dirtyValues.permissionObject.text = root.permissionObject ? root.permissionObject.text : ""
            d.dirtyValues.permissionObject.imageSource = root.permissionObject ? root.permissionObject.imageSource : ""

            // TODO: Channels

            // Is private permission
            d.dirtyValues.isPrivateDirty = false
        }

        function checkIfHoldingsDirty() {
            let dirty = false
            if(root.holdingsModel) {
                if(root.holdingsModel.count !== d.dirtyValues.holdingsModel.count) {
                    dirty = true
                }
                else {
                    // Check element by element
                    let equals = 0
                    for(let i = 0; i < root.holdingsModel.count; i++) {
                        const item1 = root.holdingsModel.get(i)
                        for(let j = 0; j < d.dirtyValues.holdingsModel.count; j++) {
                            let item2 = d.dirtyValues.holdingsModel.get(j)
                            // key, name, shortName, amount
                            if((item1.key === item2.key) &&
                               (item1.name === item2.name) &&
                               (item1.shortName === item2.shortName) &&
                               (item1.amount === item2.amount)) {
                                equals = equals + 1
                            }
                        }
                    }
                    dirty = (equals !== root.holdingsModel.count)
                }
            }
            else {
                dirty = (d.dirtyValues.holdingsModel.count !== 0)
            }
            return dirty
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
            Layout.fillWidth: true
            icon: Style.svg("contact_verified")
            title: qsTr("Who holds")
            defaultItemText: qsTr("Example: 10 SNT")
            tagLeftPadding: 2
            asset.height: 28
            asset.width: asset.height

            property int editedIndex
            itemsModel: SortFilterProxyModel {
                sourceModel: d.dirtyValues.holdingsModel

                proxyRoles: ExpressionRole {
                    name: "text"
                    expression: root.store.setHoldingsTextFormat(model.type, model.name, model.amount)
               }
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

                onAddAsset: {
                    const modelItem = CommunityPermissionsHelpers.getAssetByKey(
                                        store.assetsModel, key)
                    addItem(HoldingTypes.Type.Asset, modelItem, amount)
                    dropdown.close()
                }

                onAddCollectible: {
                    const modelItem = CommunityPermissionsHelpers.getCollectibleByKey(
                                        store.collectiblesModel, key)
                    addItem(HoldingTypes.Type.Collectible, modelItem, amount)
                    dropdown.close()
                }

                onAddEns: {
                    const key = any ? "EnsAny" : "EnsCustom"
                    const name = any ? "" : customDomain
                    const icon = Style.svg("profile/ensUsernames")

                    d.dirtyValues.holdingsModel.append({type: HoldingTypes.Type.Ens, key, name, amount: 1, imageSource: icon })
                    dropdown.close()
                }

                onUpdateAsset: {
                    const modelItem = CommunityPermissionsHelpers.getAssetByKey(
                                        store.assetsModel, key)
                    const name = modelItem.shortName ? modelItem.shortName : modelItem.name
                    const imageSource = modelItem.iconSource.toString()

                    d.dirtyValues.holdingsModel.set(tokensSelector.editedIndex, { type: HoldingTypes.Type.Asset, key, name, amount, imageSource })
                    d.triggerDirtyTool = !d.triggerDirtyTool
                    dropdown.close()
                }

                onUpdateCollectible: {
                    const modelItem = CommunityPermissionsHelpers.getCollectibleByKey(
                                        store.collectiblesModel, key)
                    const name = modelItem.name
                    const imageSource = modelItem.iconSource.toString()

                    d.dirtyValues.holdingsModel.set(tokensSelector.editedIndex, { type: HoldingTypes.Type.Collectible, key, name, amount, imageSource })
                    d.triggerDirtyTool = !d.triggerDirtyTool
                    dropdown.close()
                }

                onUpdateEns: {
                    const key = any ? "EnsAny" : "EnsCustom"
                    const name = any ? "" : customDomain
                    const icon = Style.svg("profile/ensUsernames")

                    d.dirtyValues.holdingsModel.set(tokensSelector.editedIndex, { type: HoldingTypes.Type.Ens, key, name: name, amount: 1, imageSource: icon })
                    d.triggerDirtyTool = !d.triggerDirtyTool
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
                dropdown.openFlow(HoldingsDropdown.FlowType.Add)
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
                        dropdown.collectiblesSpecificAmount = modelItem.amount !== 1
                        break
                    case HoldingTypes.Type.Ens:
                        dropdown.ensType = modelItem.name ? EnsPanel.EnsType.CustomSubdomain
                                                          : EnsPanel.EnsType.Any
                        dropdown.ensDomainName = modelItem.name
                        break
                    default:
                        console.warn("Unsupported holdings type.")
                }

                dropdown.openFlow(HoldingsDropdown.FlowType.Update)
                dropdown.setActiveTab(modelItem.type)

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

                onDone: {
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

            Layout.fillWidth: true
            icon: Style.svg("create-category")
            iconSize: 24
            title: qsTr("In")
            defaultItemText: qsTr("Example: `#general` channel")

            useLetterIdenticons: !wholeCommunitySelected || !inDropdown.communityImage

            property bool wholeCommunitySelected: false

            ListModel {
                id: inModelCommunity

                readonly property string colorWorkaround: inDropdown.communityData.color

                Component.onCompleted: {
                    append({
                        imageSource: inDropdown.communityData.image,
                        text: inDropdown.communityData.name,
                        operator: OperatorsUtils.Operators.None
                    })

                    setProperty(0, "color", colorWorkaround)
                }
            }

            ListModel {
                id: inModelChannels
            }

            InDropdown {
                id: inDropdown

                model: root.rootStore.chatCommunitySectionModule.model

                readonly property var communityData: rootStore.mainModuleInst.activeSection

                communityName: communityData.name
                communityImage: communityData.image
                communityColor: communityData.color

                onChannelsSelected: {
                    inModelChannels.clear()
                    inSelector.itemsModel = 0
                    inSelector.wholeCommunitySelected = false

                    channels.map(channel => {
                        inModelChannels.append({
                            itemId: channel.itemId,
                            text: "#" + channel.name,
                            emoji: channel.emoji,
                            color: channel.color,
                            operator: OperatorsUtils.Operators.None
                        })
                    })

                    inSelector.itemsModel = inModelChannels
                    close()
                }

                onCommunitySelected: {
                    inModelChannels.clear()
                    inSelector.wholeCommunitySelected = true
                    inSelector.itemsModel = inModelCommunity
                    close()
                }
            }

            function openInDropdown(parent, x, y) {
                inDropdown.parent = parent
                inDropdown.x = x
                inDropdown.y = y

                const selectedChannels = []

                if (!inSelector.wholeCommunitySelected)
                    for (let i = 0; i < inModelChannels.count; i++)
                        selectedChannels.push(inModelChannels.get(i).itemId)

                inDropdown.setSelectedChannels(selectedChannels)
                inDropdown.open()
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
                    text: qsTr("Private")
                    color: Theme.palette.directColor1
                    font.pixelSize: 15
                }
                StatusBaseText {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    text: qsTr("Make this permission private to hide it from members who don’t meet it’s requirements")
                    color: Theme.palette.baseColor1
                    font.pixelSize: 15
                    lineHeight: 1.2
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                    clip: true
                }
            }
            StatusSwitch {
                checked: d.dirtyValues.isPrivateDirty ? !root.isPrivate : root.isPrivate
                onToggled: d.dirtyValues.isPrivateDirty = (root.isPrivate !== checked)
            }
        }

        StatusButton {
            visible: !root.isEditState
            Layout.topMargin: 24
            text: qsTr("Create permission")
            enabled: d.dirtyValues.holdingsModel && d.dirtyValues.holdingsModel.count > 0 && d.dirtyValues.permissionObject.key !== null
            Layout.preferredHeight: 44
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            onClicked: {
                root.store.createPermission(d.dirtyValues.holdingsModel,
                                            d.dirtyValues.permissionObject,
                                            d.dirtyValues.isPrivateDirty ? !root.isPrivate : root.isPrivate,
                                            root.channelsModel)
                root.permissionCreated()
            }
        }
    }
}
