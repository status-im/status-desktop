import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Utils 0.1

import utils 1.0
import shared.panels 1.0

import SortFilterProxyModel 0.2

import "../../../Chat/controls/community"

Flickable {
    id: root

    property var store
    property int viewWidth: 560 // by design

    signal permissionCreated()

    QtObject {
        id: d
        property bool isPrivate: false
        property int permissionType: PermissionTypes.Type.None
    }

    contentWidth: mainLayout.width
    contentHeight: mainLayout.height
    clip: true
    flickableDirection: Flickable.AutoFlickIfNeeded

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

            // roles: type, key, name, amount, imageSource, operator
            ListModel {
                id: holdingsModel
            }

            property int editedIndex
            itemsModel: SortFilterProxyModel {
                sourceModel: holdingsModel

                proxyRoles: ExpressionRole {
                    name: "text"
                    expression: root.store.setHoldingsTextFormat(model.type, model.name, model.amount)
               }
            }

            HoldingsDropdown {
                id: dropdown
                store: root.store

                function addItem(type, item, amount, operator) {
                    const key = item.key
                    const name = item.shortName ? item.shortName : item.name
                    const imageSource = item.iconSource.toString()

                    holdingsModel.append({ type, key, name, amount, imageSource, operator })
                }

                onAddToken: {
                    const modelItem = store.getTokenByKey(key)
                    addItem(HoldingTypes.Type.Token, modelItem, amount, operator)
                    dropdown.close()
                }

                onAddCollectible: {
                    const modelItem = store.getCollectibleByKey(key)
                    addItem(HoldingTypes.Type.Collectible, modelItem, amount, operator)
                    dropdown.close()
                }

                onAddEns: {
                    const key = any ? "EnsAny" : "EnsCustom"
                    const name = any ? "" : customDomain
                    const icon = Style.svg("ensUsernames")

                    holdingsModel.append({type: HoldingTypes.Type.Ens, key, name, amount: 1, imageSource: icon, operator })
                    dropdown.close()
                }

                onUpdateToken: {
                    const modelItem = store.getTokenByKey(key)
                    const name = modelItem.shortName ? modelItem.shortName : modelItem.name
                    const imageSource = modelItem.iconSource.toString()

                    holdingsModel.set(tokensSelector.editedIndex, { type: HoldingTypes.Type.Token, key, name, amount, imageSource })
                    dropdown.close()
                }

                onUpdateCollectible: {
                    const modelItem = store.getCollectibleByKey(key)
                    const name = modelItem.name
                    const imageSource = modelItem.iconSource.toString()

                    holdingsModel.set(tokensSelector.editedIndex, { type: HoldingTypes.Type.Collectible, key, name, amount, imageSource })
                    dropdown.close()
                }

                onUpdateEns: {
                    const key = any ? "EnsAny" : "EnsCustom"
                    const name = any ? "" : customDomain
                    const icon = Style.svg("ensUsernames")

                    holdingsModel.set(tokensSelector.editedIndex, { type: HoldingTypes.Type.Ens, key, name: name, amount: 1, imageSource: icon })
                    dropdown.close()
                }

                onRemoveClicked: {
                    holdingsModel.remove(tokensSelector.editedIndex)

                    if (holdingsModel.count) {
                        holdingsModel.set(0, { operator: OperatorsUtils.Operators.None})
                    }

                    dropdown.close()
                }
            }

            addButton.onClicked: {
                dropdown.parent = tokensSelector.addButton
                dropdown.x = tokensSelector.addButton.width + 4
                dropdown.y = 0

                if (holdingsModel.count === 0)
                    dropdown.openFlow(HoldingsDropdown.FlowType.Add)
                else
                    dropdown.openFlow(HoldingsDropdown.FlowType.AddWithOperators)
            }

            onItemClicked: {
                if (mouse.button !== Qt.LeftButton)
                    return

                dropdown.parent = item
                dropdown.x = mouse.x + 4
                dropdown.y = 1

                const modelItem = tokensSelector.itemsModel.get(index)

                switch(modelItem.type) {
                    case HoldingTypes.Type.Token:
                        dropdown.tokenKey = modelItem.key
                        dropdown.tokenAmount = modelItem.amount
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

            Binding on itemsModel {
                when: d.permissionType !== PermissionTypes.Type.None
                value: QtObject {
                    id: permissionsListObjectModel

                    readonly property int operator: OperatorsUtils.Operators.None
                    property var key
                    property string text: ""
                    property string imageSource: ""
                }
            }

            addButton.visible: d.permissionType === PermissionTypes.Type.None

            PermissionsDropdown {
                id: permissionsDropdown

                initialPermissionType: d.permissionType

                onDone: {
                    d.permissionType = permissionType
                    permissionsListObjectModel.key = permissionType
                    permissionsListObjectModel.text = title
                    permissionsListObjectModel.imageSource = asset
                    permissionsDropdown.close()
                }
            }

            addButton.onClicked: {
                permissionsDropdown.mode = PermissionsDropdown.Mode.Add
                permissionsDropdown.parent = permissionsSelector.addButton
                permissionsDropdown.x = permissionsSelector.addButton.width + 4
                permissionsDropdown.y = 0
                permissionsDropdown.open()
            }

            onItemClicked: {
                if (mouse.button !== Qt.LeftButton)
                    return

                permissionsDropdown.mode = PermissionsDropdown.Mode.Update
                permissionsDropdown.parent = item
                permissionsDropdown.x = mouse.x + 4
                permissionsDropdown.y = 1
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
            Layout.fillWidth: true
            icon: Style.svg("create-category")
            iconSize: 24
            title: qsTr("In")
            defaultItemText: qsTr("Example: `#general` channel")
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
                checked: d.isPrivate
                onToggled: { d.isPrivate = checked }
            }
        }
        StatusButton {
            Layout.topMargin: 24
            text: qsTr("Create permission")
            enabled: holdingsModel.count > 0 && permissionsListObjectModel.key !== undefined
            Layout.preferredHeight: 44
            Layout.alignment: Qt.AlignHCenter
            Layout.fillWidth: true
            onClicked: {
                root.store.createPermissions(holdingsModel, permissionsListObjectModel, d.isPrivate)
                root.permissionCreated()
            }
        }
    }
}
