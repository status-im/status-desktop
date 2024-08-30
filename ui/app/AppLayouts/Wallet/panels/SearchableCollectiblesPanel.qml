import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.15

import StatusQ 0.1
import StatusQ.Controls 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Popups.Dialog 0.1

import AppLayouts.Wallet.views 1.0
import utils 1.0

import SortFilterProxyModel 0.2

/**
  Panel holding search field and two-levels list of collectibles.
*/
Control {
    id: root

    /**
      Expected model structure:

        groupName           [string] - group name
        icon                [url]    - icon image of a group
        type                [string] - group type, can be "community" or "other"
        subitems            [model]  - submodel of collectibles/collections of the group
            key             [string] - balance
            name            [string] - name of the subitem
            balance         [int]    - balance of the subitem
            icon            [url]    - icon of the subitem
    **/
    property alias model: sfpm.sourceModel

    signal collectionSelected(string key)
    signal collectibleSelected(string key)

    property string highlightedKey: ""

    readonly property alias currentItem: collectiblesStackView.currentItem

    SortFilterProxyModel {
        id: sfpm

        filters: SearchFilter {
            roleName: "groupName"
            searchPhrase: collectiblesSearchBox.text
        }
    }

    contentItem: StackView {
        id: collectiblesStackView

        initialItem: ColumnLayout {
            spacing: 0

            TokenSearchBox {
                id: collectiblesSearchBox

                Layout.fillWidth: true
                placeholderText: qsTr("Search collectibles")
            }

            StatusDialogDivider {
                Layout.fillWidth: true
                visible: collectiblesListView.count
            }

            StatusListView {
                id: collectiblesListView

                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredHeight: contentHeight

                clip: true
                model: sfpm

                delegate: TokenSelectorCollectibleDelegate {
                    required property var model

                    readonly property int subitemsCount:
                        model.subitems.ModelCount.count

                    readonly property bool isCommunity:
                        model.type === "community"

                    readonly property bool showCount:
                        subitemsCount > 1 || isCommunity

                    name: model.groupName
                    balance: showCount ? subitemsCount : ""
                    image: model.icon
                    goDeeperIconVisible: subitemsCount > 1
                                         || isCommunity
                    highlighted: subitemsCount === 1 && !isCommunity
                                 ? ModelUtils.get(model.subitems, 0, "key")
                                   === root.highlightedKey
                                 : false

                    onClicked: {
                        if (subitemsCount === 1 && !isCommunity) {
                            const key = ModelUtils.get(model.subitems, 0, "key")
                            root.collectibleSelected(key)
                            return
                        }

                        const parameters = {
                            index: sfpm.index(model.index, 0),
                            model: model.subitems,
                            isCommunity: isCommunity
                        }

                        collectiblesStackView.push(
                                    collectiblesSublistComponent,
                                    parameters,
                                    StackView.Immediate)
                    }
                }

                section.property: "type"
                section.delegate: StatusBaseText {
                    color: Theme.palette.baseColor1
                    topPadding: Style.current.padding

                    text: section === "community"
                          ? qsTr("Community minted")
                          : qsTr("Other")
                }
            }
        }
    }

    Component {
        id: collectiblesSublistComponent

        ColumnLayout {
            property var index
            property alias model: sublistSfpm.sourceModel
            property bool isCommunity

            spacing: 0

            SortFilterProxyModel {
                id: sublistSfpm

                filters: SearchFilter {
                    roleName: "name"
                    searchPhrase: collectiblesSublistSearchBox.text
                }
            }

            StatusIconTextButton {
                id: backButton

                statusIcon: "previous"
                icon.width: 12
                icon.height: 12
                text: qsTr("Back")

                onClicked: collectiblesStackView.pop(StackView.Immediate)
            }

            StatusDialogDivider {
                Layout.fillWidth: true
                visible: collectiblesListView.count
            }

            TokenSearchBox {
                id: collectiblesSublistSearchBox

                Layout.fillWidth: true
                placeholderText: qsTr("Search collectibles")
            }

            StatusDialogDivider {
                Layout.fillWidth: true
                visible: collectiblesListView.count
            }

            StatusListView {
                id: sublist

                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredHeight: contentHeight

                model: sublistSfpm

                clip: true

                delegate: TokenSelectorCollectibleDelegate {
                    required property var model

                    name: model.name
                    balance: model.balance > 1 ? model.balance : ""
                    image: model.icon
                    goDeeperIconVisible: false
                    highlighted: model.key === root.highlightedKey

                    onClicked: {
                        if (isCommunity)
                            root.collectionSelected(model.key)
                        else
                            root.collectibleSelected(model.key)
                    }
                }
            }

            // Detection if the related model entry has been removed.
            // Using model.Component.destruction.connect is not reliable because
            // is not called for submodels maintained in c++ by the parent model.
            ItemSelectionModel {
                id: selection

                model: sfpm

                onHasSelectionChanged: {
                    if (!hasSelection)
                        collectiblesStackView.pop(StackView.Immediate)
                }

                Component.onCompleted: select(index, ItemSelectionModel.Select)
            }
        }
    }
}
