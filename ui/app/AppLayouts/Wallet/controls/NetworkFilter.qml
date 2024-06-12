import QtQuick 2.15
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

import utils 1.0

import "../views"

StatusComboBox {
    id: root

    required property var flatNetworks
    property bool multiSelection: true
    property bool preferredNetworksMode: false
    property var preferredSharingNetworks: []
    property bool showAllSelectedText: true
    property bool showCheckboxes: true
    property bool showRadioButtons: true
    property bool showTitle: true

    /// \c network is a network.model.nim entry
    /// It is called for every toggled network if \c multiSelection is \c true
    /// If \c multiSelection is \c false, it is called only for the selected network when the selection changes
    signal toggleNetwork(var network)

    function setChain(chainId) {
        if(!multiSelection && !!root.flatNetworks && root.flatNetworks.count > 0) {
            d.currentIndex = NetworkModelHelpers.getChainIndexByChainId(root.flatNetworks, chainId)
            if(d.currentIndex == -1)
                d.currentIndex = NetworkModelHelpers.getChainIndexForFirstLayer2Network(root.flatNetworks)

            // Notify change:
            root.toggleNetwork(ModelUtils.get(root.flatNetworks, d.currentIndex))
        }
    }

    QtObject {
        id: d

        readonly property string selectedChainName: {
            root.multiSelection
            NetworkModelHelpers.getChainName(root.flatNetworks, d.currentIndex)
        }
        readonly property string selectedIconUrl: {
            root.multiSelection
            NetworkModelHelpers.getChainIconUrl(root.flatNetworks, d.currentIndex)
        }
        readonly property bool allSelected: root.preferredNetworksMode ? root.preferredSharingNetworks.length === root.flatNetworks.count :
                                                                        enabledFlatNetworks.count === root.flatNetworks.count
        readonly property bool noneSelected: enabledFlatNetworks.count === 0

        // Persist selection between selectPopupLoader reloads
        property int currentIndex: 0

        property SortFilterProxyModel enabledFlatNetworks: SortFilterProxyModel {
            sourceModel: root.flatNetworks
            filters: [
                ValueFilter { roleName: "isEnabled"; value: true; enabled: !root.preferredNetworksMode },
                FastExpressionFilter {
                    expression: root.preferredSharingNetworks.includes(chainId.toString())
                    expectedRoles: ["chainId"]
                    enabled: root.preferredNetworksMode
                }
            ]
        }
    }

    onMultiSelectionChanged: root.setChain()

    control.padding: 12
    control.spacing: 0
    control.rightPadding: 36
    control.topPadding: 7

    control.popup.x: root.width - control.popup.width
    control.popup.width: 300
    control.popup.horizontalPadding: 4
    control.popup.verticalPadding: 4

    size: StatusComboBox.Size.Small

    control.background: SQP.StatusComboboxBackground {
        height: 38
        active: root.control.down || root.control.hovered
    }

    control.indicator: SQP.StatusComboboxIndicator {
        x: root.control.mirrored ? root.control.horizontalPadding : root.width - width - root.control.horizontalPadding
        y: root.control.topPadding + (root.control.availableHeight - height) / 2
    }

    control.contentItem: RowLayout {
        spacing: Style.current.padding
        StatusSmartIdenticon {
            objectName: "contentItemIcon"
            Layout.alignment: Qt.AlignVCenter
            asset.height: 24
            asset.width: 24
            asset.isImage: !root.multiSelection
            asset.name: !root.multiSelection ? Style.svg(d.selectedIconUrl) : ""
            active: !root.multiSelection
            visible: active
        }
        StatusBaseText {
            objectName: "contentItemText"
            Layout.alignment: Qt.AlignVCenter
            Layout.fillWidth: true
            font.pixelSize: Style.current.additionalTextSize
            font.weight: Font.Medium
            elide: Text.ElideRight
            lineHeight: 24
            lineHeightMode: Text.FixedHeight
            verticalAlignment: Text.AlignVCenter
            text: root.multiSelection ? (d.noneSelected ? qsTr("Select networks"): d.allSelected && root.showAllSelectedText ? qsTr("All networks") : "")
                                      : (root.showTitle ? d.selectedChainName : "")
            color: Theme.palette.baseColor1
            visible: !!text
        }
        Row {
            id: row
            spacing: -4
            visible: (!d.allSelected || !root.showAllSelectedText) && chainRepeater.count > 0
            Repeater {
                id: chainRepeater
                model: root.multiSelection ? d.enabledFlatNetworks: []
                delegate: StatusRoundedImage {
                    id: delegateItem
                    width: 24
                    height: 24
                    image.source: Style.svg(model.iconUrl)
                    z: index + 1
                    visible: root.preferredNetworksMode ? root.preferredSharingNetworks.includes(model.chainId.toString()): image.source !== ""

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
    }

    control.popup.contentItem: NetworkSelectionView {
        flatNetworks: root.flatNetworks
        preferredSharingNetworks: root.preferredSharingNetworks
        preferredNetworksMode: root.preferredNetworksMode
        showCheckboxes: root.showCheckboxes
        showRadioButtons: root.showRadioButtons

        implicitWidth: contentWidth
        implicitHeight: contentHeight

        singleSelection {
            enabled: !root.multiSelection
            currentModel: root.flatNetworks
            currentIndex: d.currentIndex
        }

        useEnabledRole: false

        onToggleNetwork: (network, index) => {
                             d.currentIndex = index
                             root.toggleNetwork(network)
                             if(singleSelection.enabled)
                                control.popup.close()
                         }
    }
}
