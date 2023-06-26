import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQml 2.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Utils 0.1

import utils 1.0
import shared.panels 1.0

import AppLayouts.Communities.helpers 1.0
import AppLayouts.Communities.controls 1.0
import AppLayouts.Communities.panels 1.0

StatusScrollView {
    id: root

    required property var assetsModel
    required property var collectiblesModel
    required property var channelsModel

    // id, name, image, color, owner properties expected
    required property var communityDetails

    property int viewWidth: 560 // by design
    property bool isEditState: false

    readonly property bool dirty:
        root.holdingsRequired !== d.dirtyValues.holdingsRequired ||
        (d.dirtyValues.holdingsRequired && !holdingsModelComparator.equal) ||
        !channelsModelComparator.equal ||
        root.isPrivate !== d.dirtyValues.isPrivate ||
        root.permissionType !== d.dirtyValues.permissionType

    readonly property alias dirtyValues: d.dirtyValues

    readonly property bool isFullyFilled:
        (dirtyValues.selectedHoldingsModel.count > 0 || !whoHoldsSwitch.checked) &&
        dirtyValues.permissionType !== PermissionTypes.Type.None &&
        (d.isCommunityPermission || dirtyValues.selectedChannelsModel.count > 0)

    property int permissionType: PermissionTypes.Type.None
    property bool isPrivate: false
    property bool holdingsRequired: true

    // roles: type, key, name, amount, imageSource
    property var selectedHoldingsModel: ListModel {}

    // roles: itemId, text, icon, emoji, color, colorId
    property var selectedChannelsModel: ListModel {}

    property bool permissionDuplicated: false
    property bool permissionTypeLimitReached: false

    signal createPermissionClicked
    signal navigateToMintTokenSettings

    function resetChanges() {
        d.loadInitValues()
    }

    ModelsComparator {
        id: holdingsModelComparator

        modelA: root.dirtyValues.selectedHoldingsModel
        modelB: root.selectedHoldingsModel

        roles: ["key", "amount"]
        mode: ModelsComparator.CompareMode.Set
    }

    ModelsComparator {
        id: channelsModelComparator

        modelA: root.dirtyValues.selectedChannelsModel
        modelB: root.selectedChannelsModel

        roles: ["itemId"]
        mode: ModelsComparator.CompareMode.Set
    }

    QtObject {
        id: d

        readonly property int maxHoldingsItems: 5

        readonly property int dropdownHorizontalOffset: 4
        readonly property int dropdownVerticalOffset: 1

        readonly property bool isCommunityPermission:
            PermissionTypes.isCommunityPermission(dirtyValues.permissionType)

        onIsCommunityPermissionChanged: {
            if (isCommunityPermission) {
                d.dirtyValues.selectedChannelsModel.clear()
                inSelector.wholeCommunitySelected = true
                inSelector.model = inModelCommunity
            } else {
                inSelector.model = 0
                inSelector.wholeCommunitySelected = false
                inSelector.model = channelsSelectionModel
            }
        }

        readonly property QtObject dirtyValues: QtObject {
            readonly property ListModel selectedHoldingsModel: ListModel {}
            readonly property ListModel selectedChannelsModel: ListModel {}

            property int permissionType: PermissionTypes.Type.None
            property bool isPrivate: false
            property bool holdingsRequired: true

            Binding on isPrivate {
                value: (d.dirtyValues.permissionType === PermissionTypes.Type.Admin) ||
                       (d.dirtyValues.permissionType === PermissionTypes.Type.Moderator)
            }

            function getHoldingIndex(key) {
                return ModelUtils.indexOf(selectedHoldingsModel, "key", key)
            }

            function getTokenKeysAndAmounts() {
                return ModelUtils.modelToArray(selectedHoldingsModel, ["type", "key", "amount"])
                    .filter(item => item.type !== HoldingTypes.Type.Ens)
                    .map(item => ({ key: item.key, amount: item.amount }))
            }

            function getEnsNames() {
                return ModelUtils.modelToArray(selectedHoldingsModel, ["type", "name"])
                    .filter(item => item.type === HoldingTypes.Type.Ens)
                    .map(item => item.name)
            }
        }

        function loadInitValues() {
            // Holdings:
            d.dirtyValues.selectedHoldingsModel.clear()
            d.dirtyValues.selectedHoldingsModel.append(
                        ModelUtils.modelToArray(root.selectedHoldingsModel,
                                                ["type", "key", "amount"]))

            // Permissions:
            d.dirtyValues.permissionType = root.permissionType

            // Channels
            d.dirtyValues.selectedChannelsModel.clear()
            d.dirtyValues.selectedChannelsModel.append(
                        ModelUtils.modelToArray(root.selectedChannelsModel, ["key"]))

            if (root.selectedChannelsModel &&
                    (root.selectedChannelsModel.rowCount()
                     || d.dirtyValues.permissionType === PermissionTypes.Type.None)) {
                inSelector.wholeCommunitySelected = false
                inSelector.model = channelsSelectionModel
            } else {
                inSelector.wholeCommunitySelected = true
                inSelector.model = inModelCommunity
            }

            // Is private permission
            d.dirtyValues.isPrivate = root.isPrivate

            // Are holdings required
            d.dirtyValues.holdingsRequired = root.holdingsRequired
        }
    }

    onPermissionTypeChanged: Qt.callLater(() => d.loadInitValues())
    contentWidth: mainLayout.width
    contentHeight: mainLayout.height
    
    SequenceColumnLayout {
        id: mainLayout

        width: root.viewWidth
        title: qsTr("Anyone")

        StatusItemSelector {
            id: tokensSelector

            property int editedIndex: -1

            Layout.fillWidth: true
            icon: Style.svg("contact_verified")
            title: qsTr("Who holds")
            placeholderText: qsTr("Example: 10 SNT")
            tagLeftPadding: 2
            asset.height: 28
            asset.width: asset.height
            addButton.visible: count < d.maxHoldingsItems &&
                               whoHoldsSwitch.checked

            model: HoldingsSelectionModel {
                sourceModel: d.dirtyValues.selectedHoldingsModel

                assetsModel: root.assetsModel
                collectiblesModel: root.collectiblesModel
            }

            label.enabled: whoHoldsSwitch.checked
            placeholderItem.visible: count === 0 && whoHoldsSwitch.checked

            Binding on model {
                when: !whoHoldsSwitch.checked
                value: 0
                restoreMode: Binding.RestoreBindingOrValue
            }

            Binding on bottomPadding {
                when: !whoHoldsSwitch.checked
                value: 0
                restoreMode: Binding.RestoreBindingOrValue
            }

            children: StatusSwitch {
                id: whoHoldsSwitch

                padding: 0
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.rightMargin: 12
                anchors.topMargin: 10

                checked: d.dirtyValues.holdingsRequired
                onToggled: d.dirtyValues.holdingsRequired = checked
            }

            HoldingsDropdown {
                id: dropdown

                communityId: root.communityDetails.id

                assetsModel: root.assetsModel
                collectiblesModel: root.collectiblesModel

                function addItem(type, item, amount) {
                    const key = item.key

                    d.dirtyValues.selectedHoldingsModel.append(
                                { type, key, amount })
                }

                function prepareUpdateIndex(key) {
                    const itemIndex = tokensSelector.editedIndex
                    const existingIndex = d.dirtyValues.getHoldingIndex(key)

                    if (itemIndex !== -1 && existingIndex !== -1 && itemIndex !== existingIndex) {
                        const previousKey = d.dirtyValues.selectedHoldingsModel.get(itemIndex).key
                        d.dirtyValues.selectedHoldingsModel.remove(existingIndex)
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
                    const modelItem = PermissionsHelpers.getTokenByKey(
                                        root.assetsModel, key)
                    addItem(HoldingTypes.Type.Asset, modelItem, amount)
                    dropdown.close()
                }

                onAddCollectible: {
                    const modelItem = PermissionsHelpers.getTokenByKey(
                                        root.collectiblesModel, key)
                    addItem(HoldingTypes.Type.Collectible, modelItem, amount)
                    dropdown.close()
                }

                onAddEns: {
                    d.dirtyValues.selectedHoldingsModel.append(
                                { type: HoldingTypes.Type.Ens, key: domain, amount: 1 })
                    dropdown.close()
                }

                onUpdateAsset: {
                    const itemIndex = prepareUpdateIndex(key)
                    const modelItem = PermissionsHelpers.getTokenByKey(root.assetsModel, key)

                    d.dirtyValues.selectedHoldingsModel.set(
                                itemIndex, { type: HoldingTypes.Type.Asset, key, amount })
                    dropdown.close()
                }

                onUpdateCollectible: {
                    const itemIndex = prepareUpdateIndex(key)
                    const modelItem = PermissionsHelpers.getTokenByKey(
                                        root.collectiblesModel, key)

                    d.dirtyValues.selectedHoldingsModel.set(
                                itemIndex,
                                { type: HoldingTypes.Type.Collectible, key, amount })
                    dropdown.close()
                }

                onUpdateEns: {
                    d.dirtyValues.selectedHoldingsModel.set(
                                tokensSelector.editedIndex,
                                { type: HoldingTypes.Type.Ens, key: domain, amount: 1 })
                    dropdown.close()
                }

                onRemoveClicked: {
                    d.dirtyValues.selectedHoldingsModel.remove(tokensSelector.editedIndex)
                    dropdown.close()
                }

                onNavigateToMintTokenSettings: {
                    root.navigateToMintTokenSettings()
                    close()
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

                const modelItem = tokensSelector.model.get(index)

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

        SequenceColumnLayout.Separator {}

        StatusFlowSelector {
            id: permissionsSelector

            Layout.fillWidth: true

            title: qsTr("Is allowed to")
            placeholderText: qsTr("Example: View and post")
            icon: Style.svg("profile/security")

            readonly property bool empty:
                d.dirtyValues.permissionType === PermissionTypes.Type.None

            placeholderItem.visible: empty
            addButton.visible: empty

            StatusListItemTag {
                readonly property int key: d.dirtyValues.permissionType

                title: PermissionTypes.getName(key)
                visible: !permissionsSelector.empty

                asset.name: PermissionTypes.getIcon(key)
                asset.bgColor: "transparent"
                closeButtonVisible: false
                titleText.font.pixelSize: Theme.primaryTextFontSize
                leftPadding: 6

                Binding on bgColor {
                    when: root.permissionTypeLimitReached
                    value: Theme.palette.dangerColor3
                }

                Binding on titleText.color {
                    when: root.permissionTypeLimitReached
                    value: Theme.palette.dangerColor1
                }

                Binding on asset.color {
                    when: root.permissionTypeLimitReached
                    value: Theme.palette.dangerColor1
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor

                    onClicked: {
                        permissionsDropdown.mode = PermissionsDropdown.Mode.Update
                        permissionsDropdown.parent = parent
                        permissionsDropdown.x = mouse.x + d.dropdownHorizontalOffset
                        permissionsDropdown.y = d.dropdownVerticalOffset
                        permissionsDropdown.open()
                    }
                }
            }

            PermissionsDropdown {
                id: permissionsDropdown

                initialPermissionType: d.dirtyValues.permissionType
                enableAdminPermission: root.communityDetails.owner

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
        }

        SequenceColumnLayout.Separator {}

        StatusItemSelector {
            id: inSelector

            readonly property bool editable: !d.isCommunityPermission

            addButton.visible: editable
            itemsClickable: editable

            Layout.fillWidth: true
            icon: d.isCommunityPermission ? Style.svg("communities") : Style.svg("create-category")
            title: qsTr("In")
            placeholderText: qsTr("Example: `#general` channel")

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

                if (!inSelector.wholeCommunitySelected) {
                    const model = d.dirtyValues.selectedChannelsModel
                    const count = model.count

                    for (let i = 0; i < count; i++)
                        selectedChannels.push(model.get(i).key)
                }

                inDropdown.setSelectedChannels(selectedChannels)
                inDropdown.open()
            }

            ListModel {
                id: inModelCommunity

                Component.onCompleted: {
                    append({
                        imageSource: inDropdown.communityImage,
                        isIcon: false,
                        text: inDropdown.communityName,
                        operator: OperatorsUtils.Operators.None,
                        color: inDropdown.communityColor
                    })
                }
            }

            ChannelsSelectionModel {
                id: channelsSelectionModel

                sourceModel: d.dirtyValues.selectedChannelsModel

                channelsModel: root.channelsModel
            }

            InDropdown {
                id: inDropdown

                model: root.channelsModel

                communityName: root.communityDetails.name
                communityImage: root.communityDetails.image
                communityColor: root.communityDetails.color

                onChannelsSelected: {
                    d.dirtyValues.selectedChannelsModel.clear()
                    inSelector.model = 0
                    inSelector.wholeCommunitySelected = false

                    const modelData = channels.map(key => ({ key }))
                    d.dirtyValues.selectedChannelsModel.append(modelData)

                    inSelector.model = channelsSelectionModel
                    close()
                }

                onCommunitySelected: {
                    d.dirtyValues.selectedChannelsModel.clear()
                    inSelector.wholeCommunitySelected = true
                    inSelector.model = inModelCommunity
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

        WarningPanel {
            id: duplicationPanel

            Layout.fillWidth: true
            Layout.topMargin: 50 // by desing

            text: {
                if (root.permissionTypeLimitReached)
                    return PermissionTypes.getPermissionsLimitWarning(
                                d.dirtyValues.permissionType)

                if (root.permissionDuplicated)
                    return qsTr("Permission with same properties is already active, edit properties to create a new permission.")

                return ""
            }

            visible: root.permissionDuplicated || root.permissionTypeLimitReached
        }

        StatusButton {
            Layout.preferredHeight: 44
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            Layout.topMargin: Style.current.bigPadding

            visible: !root.isEditState
            text: qsTr("Create permission")
            enabled: root.isFullyFilled
                     && !root.permissionDuplicated
                     && !root.permissionTypeLimitReached

            onClicked: root.createPermissionClicked()
        }
    }
}
