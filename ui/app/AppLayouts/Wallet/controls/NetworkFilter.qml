import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

import shared 1.0
import shared.panels 1.0
import shared.controls 1.0
import utils 1.0

import "../popups"

Item {
    id: root
    implicitWidth: 130
    implicitHeight: parent.height

    required property var allNetworks
    required property var layer1Networks
    required property var layer2Networks
    required property var testNetworks
    required property var enabledNetworks

    property bool isChainVisible: true
    property bool multiSelection: true

    /// \c network is a network.model.nim entry
    /// It is called for every toggled network if \c multiSelection is \c true
    /// If \c multiSelection is \c false, it is called only for the selected network when the selection changes
    signal toggleNetwork(var network)

    QtObject {
        id: d

        property string selectedChainName: ""
        property string selectedIconUrl: ""

        // Persist selection between selectPopupLoader reloads
        property var currentModel: layer1Networks
        property int currentIndex: 0
    }

    Component.onCompleted: {
        if (d.currentModel.count > 0) {
            d.selectedChainName = d.currentModel.rowData(d.currentIndex, "chainName")
            d.selectedIconUrl = d.currentModel.rowData(d.currentIndex, "iconUrl")
        }
    }

    Item {
        id: selectRectangleItem

        width: parent.width
        height: 56

        // FIXME this should be a (styled) ComboBox
        StatusListItem {
            implicitWidth: parent.width
            implicitHeight: 40
            anchors.verticalCenter: parent.verticalCenter
            border.width: 1
            border.color: Theme.palette.directColor7
            color: "transparent"
            objectName: "networkSelectorButton"
            leftPadding: 12
            rightPadding: 12
            statusListItemTitle.font.pixelSize: 13
            statusListItemTitle.font.weight: Font.Medium
            statusListItemTitle.color: Theme.palette.baseColor1
            title: root.multiSelection
                        ? (root.enabledNetworks.count === root.allNetworks.count
                            ? qsTr("All networks")
                            : qsTr("%n network(s)", "", root.enabledNetworks.count))
                        : d.selectedChainName
            asset.height: 24
            asset.width: asset.height
            asset.isImage: !root.multiSelection
            asset.name: !root.multiSelection ? Style.svg(d.selectedIconUrl) : ""
            components:[
                StatusIcon {
                    width: 16
                    height: 16
                    icon: "chevron-down"
                    color: Theme.palette.baseColor1
                }
            ]

            onClicked: {
                selectPopupLoader.active = !selectPopupLoader.active
            }
        }
    }

    Row {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Style.current.halfPadding
        spacing: Style.current.smallPadding
        visible: root.isChainVisible && chainRepeater.count > 0

        Repeater {
            id: chainRepeater
            model: root.enabledNetworks
            delegate: InformationTag {
                tagPrimaryLabel.text: model.shortName
                tagPrimaryLabel.color: model.chainColor
                image.source: Style.svg("tiny/" + model.iconUrl)
            }
        }
    }

    Loader {
        id: selectPopupLoader

        active: false

        sourceComponent: NetworkSelectPopup {
            id: selectPopup

            x: -width + selectRectangleItem.width + 5
            y: selectRectangleItem.height + 5

            layer1Networks: root.layer1Networks
            layer2Networks: root.layer2Networks
            testNetworks: root.testNetworks

            singleSelection {
                enabled: !root.multiSelection
                currentModel: d.currentModel
                currentIndex: d.currentIndex
            }

            useEnabledRole: false

            onToggleNetwork: (network, networkModel, index) => {
                d.selectedChainName = network.chainName
                d.selectedIconUrl = network.iconUrl
                d.currentModel = networkModel
                d.currentIndex = index
                root.toggleNetwork(network)
            }


            onClosed: selectPopupLoader.active = false
        }

        onLoaded: item.open()
    }
}
