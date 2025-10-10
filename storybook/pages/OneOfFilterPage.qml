import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQml

import StatusQ
import StatusQ.Core
import StatusQ.Core.Utils
import StatusQ.Controls
import StatusQ.Components
import StatusQ.Core.Theme

import Models
import Storybook

import SortFilterProxyModel

import utils

Item {
    id: root

    readonly property var networksChainsCurrentlySelectedArray: {
        let supportNwChains = []
        for (let i =0; i< networksRepeater.count; i++) {
            if (networksRepeater.itemAt(i).checked)
                supportNwChains.push(networksRepeater.itemAt(i).chainID)
        }
        return supportNwChains
    }

    readonly property string networksChainsCurrentlySelected: networksChainsCurrentlySelectedArray.join(":")

    ListModel {
        id: chainsModel
        ListElement {
            chainId: 1
        }
        ListElement {
            chainId: 10
        }
        ListElement {
            chainId: 3
        }
        ListElement {
            chainId: 42161
        }
        ListElement {
            chainId: 421614
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12

        RowLayout {
            Layout.fillWidth: true

            FilteredListColumn {
                title: "Unfiltered model"
                model: chainsModel
            }

            FilteredListColumn {
                title: "Filtered with OneOfFilter (array)"
                model: SortFilterProxyModel {
                    sourceModel: chainsModel
                    filters: OneOfFilter {
                        id: filter1
                        roleName: "chainId"
                        array: networksChainsCurrentlySelectedArray
                    }
                }
                Label {
                    text: "Filter: %1".arg(filter1.actualArray)
                }
            }

            FilteredListColumn {
                title: "Filtered with OneOfFilter (separated string)"
                model: SortFilterProxyModel {
                    sourceModel: chainsModel
                    filters: OneOfFilter {
                        id: filter2
                        roleName: "chainId"
                        array: networksChainsCurrentlySelected
                        separator: ":"
                    }
                }
                Label {
                    text: "Filter: %1".arg(filter2.actualArray)
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Text {
                text: "Select networks:"
            }
            Repeater {
                id: networksRepeater
                model: NetworksModel.flatNetworks
                delegate: CheckBox {
                    property int chainID: model.chainId
                    width: parent.width
                    text: "%1 (%2)".arg(model.chainName).arg(chainID)
                }
            }
        }

        component FilteredListColumn: ColumnLayout {
            id: col
            property string title
            property var model

            Layout.preferredWidth: parent.width/3
            Label {
                Layout.fillWidth: true
                text: col.title
                font.bold: true
            }
            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: col.model
                delegate: ItemDelegate {
                    width: ListView.view.width
                    text: "Chain (%1)".arg(model.chainId)
                    onClicked: console.warn("Clicked chainID:", model.chainId)
                }
            }
        }
    }
}

// category: Filters
// status: good
