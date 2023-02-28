import QtQuick 2.13

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

    property var store
    property bool isChainVisible: true
    property bool multiSelection: true

    signal singleNetworkSelected(int chainId)

    QtObject {
        id: d

        property string selectedChainName: ""
        property string selectedIconUrl: ""
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
            title: root.multiSelection ? (store.enabledNetworks.count === store.allNetworks.count ? qsTr("All networks") : qsTr("%n network(s)", "", store.enabledNetworks.count)) :
                                         d.selectedChainName
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
                if (selectPopup.opened) {
                    selectPopup.close();
                } else {
                    selectPopup.open();
                }
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
            model: store.enabledNetworks
            delegate: InformationTag {
                tagPrimaryLabel.text: model.shortName
                tagPrimaryLabel.color: model.chainColor
                image.source: Style.svg("tiny/" + model.iconUrl)
            }
        }
    }

    NetworkSelectPopup {
        id: selectPopup
        x: (parent.width - width + 5)
        y: (selectRectangleItem.height + 5)
        layer1Networks: store.layer1Networks
        layer2Networks: store.layer2Networks
        testNetworks: store.testNetworks
        multiSelection: root.multiSelection

        onToggleNetwork: {
            store.toggleNetwork(chainId)
        }

        onSingleNetworkSelected: {
            d.selectedChainName = chainName
            d.selectedIconUrl = iconUrl
            root.singleNetworkSelected(chainId)
        }
    }
}
