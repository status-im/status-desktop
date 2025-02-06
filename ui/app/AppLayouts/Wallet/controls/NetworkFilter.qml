import QtQuick 2.15
import QtQml 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import QtGraphicalEffects 1.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1
import StatusQ.Components 0.1
import StatusQ.Components.private 0.1 as SQP
import StatusQ.Controls 0.1

import SortFilterProxyModel 0.2

import AppLayouts.Wallet.helpers 1.0
import AppLayouts.Wallet.popups 1.0

import utils 1.0

import "../views"

StatusComboBox {
    id: root

    required property var flatNetworks
    readonly property alias singleSelectionItemData: d.singleSelectionItem.item

    property bool multiSelection: true
    property bool showSelectionIndicator: true
    property bool showAllSelectedText: true
    property bool showTitle: true
    property bool selectionAllowed: true
    property var selection: []

    signal toggleNetwork(int chainId, int index)

    onSelectionChanged: {
        if (root.selection !== networkSelectorView.selection) {
            networkSelectorView.selection = root.selection
        }
    }

    control.padding: 12
    control.spacing: 0
    control.rightPadding: 36
    control.topPadding: 7

    control.popup.horizontalPadding: 4
    control.popup.verticalPadding: 4

    size: StatusComboBox.Size.Small

    control.background: SQP.StatusComboboxBackground {
        height: 38
        opacity: root.interactive ? 1 : 0.5
        active: root.control.down || root.control.hovered
    }

    control.indicator: SQP.StatusComboboxIndicator {
        x: root.control.mirrored ? root.control.horizontalPadding : root.width - width - root.control.horizontalPadding
        y: root.control.topPadding + (root.control.availableHeight - height) / 2
        opacity: root.interactive ? 1 : 0.5
        visible: !d.selectionUnavailable && root.selectionAllowed
    }

    control.contentItem: RowLayout {
        spacing: Theme.halfPadding
        StatusSmartIdenticon {
            objectName: "contentItemIcon"
            Layout.alignment: Qt.AlignVCenter
            asset.height: 24
            asset.width: 24
            asset.isImage: !root.multiSelection
            asset.name: !root.multiSelection ? Theme.svg(d.singleSelectionIconUrl) : ""
            active: !root.multiSelection
            visible: active
        }
        Row {
            id: row
            spacing: -4
            visible: (!d.allSelected || !root.showAllSelectedText) && chainRepeater.count > 0
            Repeater {
                id: chainRepeater
                model: SortFilterProxyModel {
                    sourceModel: root.multiSelection ? root.flatNetworks : null
                    filters: FastExpressionFilter {
                        expression: {
                            root.selection
                            return root.selection.includes(model.chainId) 
                        } 
                        expectedRoles: ["chainId"] 
                    }
                }
                delegate: StatusRoundedImage {
                    id: delegateItem
                    required property var model
                    required property int index

                    width: 24
                    height: 24
                    image.source: Theme.svg(model.iconUrl)
                    z: index + 1

                    image.layer.enabled: index < chainRepeater.count - 1 && row.spacing < 0
                    image.layer.effect: OpacityMask {
                        id: mask
                        invert: true

                        maskSource: Item {
                            width: mask.width + 2
                            height: mask.height + 2

                            Rectangle {
                                anchors.centerIn: parent
                                anchors.horizontalCenterOffset: delegateItem.width + row.spacing

                                width: parent.width
                                height: width
                                radius: width / 2
                            }
                        }
                    }
                }
            }
        }

        StatusBaseText {
            objectName: "contentItemText"
            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true
            font.pixelSize: Theme.additionalTextSize
            font.weight: Font.Medium
            elide: Text.ElideRight
            lineHeight: 24
            lineHeightMode: Text.FixedHeight
            verticalAlignment: Text.AlignVCenter
            text: d.titleText
            color: Theme.palette.baseColor1
            visible: !!text
        }
    }

    popup: NetworkSelectPopup {
        id: networkSelectorView
        y: control.height + 4
        x: root.width - width

        flatNetworks: root.flatNetworks
        selectionAllowed: root.selectionAllowed
        multiSelection: root.multiSelection
        showSelectionIndicator: root.showSelectionIndicator
        selection: root.selection

        onSelectionChanged: {
            if (root.selection !== networkSelectorView.selection) {
                root.selection = networkSelectorView.selection
            }
        }

        onToggleNetwork: root.toggleNetwork(chainId, index)
    }

    Connections {
        target: control.popup
        enabled: !root.multiSelection
        function onOpened() {
            if (d.selectionUnavailable)
                control.popup.close()
        }
    }

    QtObject {
        id: d
        readonly property int networksCount: root.flatNetworks.ModelCount.count
        readonly property bool allSelected: root.selection.length === networksCount
        readonly property bool noneSelected: root.selection.length === 0
        readonly property bool oneSelected: root.selection.length === 1
        readonly property bool selectionUnavailable: d.networksCount <= 1 && d.oneSelected

        readonly property ModelEntry singleSelectionItem: ModelEntry {
            sourceModel: d.oneSelected ? root.flatNetworks : null
            key: "chainId"
            value: root.selection[0] ?? -1
        }

        readonly property string singleSelectionIconUrl: singleSelectionItem.item.iconUrl ?? ""
        readonly property string singleCelectionChainName: singleSelectionItem.item.chainName ?? ""

        readonly property string titleText: {
            if (d.oneSelected && root.showTitle) {
                return d.singleCelectionChainName
            }

            if (root.multiSelection) {
                if (d.noneSelected) {
                    return  qsTr("Select networks")
                }
                if (d.allSelected && root.showAllSelectedText) {
                    return qsTr("All networks")
                }
            }

            return ""
        }
    }
}
