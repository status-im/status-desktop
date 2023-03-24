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

import AppLayouts.Chat.helpers 1.0
import AppLayouts.Chat.panels.communities 1.0
import AppLayouts.Chat.controls.community 1.0

// TEMPORAL - BASIC IMPLEMENTATION
StatusScrollView {
    id: root

    // Token models:
    required property var assetsModel
    required property var collectiblesModel

    property int viewWidth: 560 // by design

    // roles: type, key, name, amount, imageSource
    property var selectedHoldingsModel: ListModel {}

    readonly property bool isFullyFilled: selectedHoldingsModel.count > 0 &&
                                          addressess.model.count > 0

    signal airdropClicked(var airdropTokens, string address)
    signal navigateToMintTokenSettings

    QtObject {
        id: d

        readonly property int maxAirdropTokens: 5
        readonly property int dropdownHorizontalOffset: 4
        readonly property int dropdownVerticalOffset: 1
    }

    contentWidth: mainLayout.width
    contentHeight: mainLayout.height

    ColumnLayout {
        id: mainLayout
        width: root.viewWidth
        spacing: 0

        StatusItemSelector {
            id: tokensSelector

            property int editedIndex: -1

            Layout.fillWidth: true
            icon: Style.svg("token")
            title: qsTr("What")
            placeholderText: qsTr("Example: 1 SOCK")
            tagLeftPadding: 2
            asset.height: 28
            asset.width: asset.height
            addButton.visible: model.count < d.maxAirdropTokens

            model: HoldingsSelectionModel {
                sourceModel: root.selectedHoldingsModel

                assetsModel: root.assetsModel
                collectiblesModel: root.collectiblesModel
            }

            // TODO: All this code is repeated inside `CommunityNewPermissionView`. Check how to reuse it.
            HoldingsDropdown {
                id: dropdown

                assetsModel: root.assetsModel
                collectiblesModel: root.collectiblesModel
                isENSTab: false
                isCollectiblesOnly: true
                noDataText: qsTr("First you need to mint or import a collectible before you can perform an airdrop")

                function addItem(type, item, amount) {
                    const key = item.key

                    root.selectedHoldingsModel.append(
                                { type, key, amount })
                }

                function getHoldingIndex(key) {
                    return ModelUtils.indexOf(root.selectedHoldingsModel, "key", key)
                }

                function prepareUpdateIndex(key) {
                    const itemIndex = tokensSelector.editedIndex
                    const existingIndex = getHoldingIndex(key)

                    if (itemIndex !== -1 && existingIndex !== -1 && itemIndex !== existingIndex) {
                        const previousKey = root.selectedHoldingsModel.get(itemIndex).key
                        root.selectedHoldingsModel.remove(existingIndex)
                        return getHoldingIndex(previousKey)
                    }

                    if (itemIndex === -1) {
                        return existingIndex
                    }

                    return itemIndex
                }

                onAddAsset: {
                    const modelItem = CommunityPermissionsHelpers.getTokenByKey(
                                        root.assetsModel, key)
                    addItem(HoldingTypes.Type.Asset, modelItem, amount)
                    dropdown.close()
                }

                onAddCollectible: {
                    const modelItem = CommunityPermissionsHelpers.getTokenByKey(
                                        root.collectiblesModel, key)
                    addItem(HoldingTypes.Type.Collectible, modelItem, amount)
                    dropdown.close()
                }

                onUpdateAsset: {
                    const itemIndex = prepareUpdateIndex(key)
                    const modelItem = CommunityPermissionsHelpers.getTokenByKey(root.assetsModel, key)

                    root.selectedHoldingsModel.set(
                                itemIndex, { type: HoldingTypes.Type.Asset, key, amount })
                    dropdown.close()
                }

                onUpdateCollectible: {
                    const itemIndex = prepareUpdateIndex(key)
                    const modelItem = CommunityPermissionsHelpers.getTokenByKey(
                                        root.collectiblesModel, key)

                    root.selectedHoldingsModel.set(
                                itemIndex,
                                { type: HoldingTypes.Type.Collectible, key, amount })
                    dropdown.close()
                }

                onRemoveClicked: {
                    root.selectedHoldingsModel.remove(tokensSelector.editedIndex)
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

        // TEMPORAL
        StatusInput {
            id: addressInput

            Layout.fillWidth: true
            placeholderText: qsTr("Example: 0x7F47C2e18a4BBf5487E6fb082eC2D9Ab0E6d7999")
        }

        Rectangle {
            Layout.leftMargin: 16
            Layout.preferredWidth: 2
            Layout.preferredHeight: 24
            color: Style.current.separator
        }

        StatusItemSelector {
            id: addressess

            Layout.fillWidth: true
            icon: Style.svg("member")
            title: qsTr("To")
            placeholderText: qsTr("Example: 12 addresses and 3 members")
            tagLeftPadding: 2
            asset.height: 28
            asset.width: asset.height

            model: ListModel {}

            addButton.onClicked: {
                if(addressInput.text.length > 0)
                    model.append({text: addressInput.text})
            }

            onItemClicked: addressess.model.remove(index)
        }

        StatusButton {
            Layout.preferredHeight: 44
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            Layout.topMargin: Style.current.bigPadding
            text: qsTr("Create airdrop")
            enabled: root.isFullyFilled

            onClicked: {
                const airdropTokens = ModelUtils.modelToArray(
                                        root.selectedHoldingsModel,
                                        ["key", "type", "amount"])

                root.airdropClicked(airdropTokens, addressess.model)
            }
        }
    }
}
