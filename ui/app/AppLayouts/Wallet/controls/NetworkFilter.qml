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
    implicitWidth: selectRectangle.width
    implicitHeight: childrenRect.height

    property var store

    // FIXME this should be a (styled) ComboBox
    StatusListItem {
        id: selectRectangle
        implicitWidth: 130
        implicitHeight: 40
        border.width: 1
        border.color: Theme.palette.directColor7
        color: "transparent"
        objectName: "networkSelectorButton"
        leftPadding: 12
        rightPadding: 12
        statusListItemTitle.font.pixelSize: 13
        statusListItemTitle.font.weight: Font.Medium
        statusListItemTitle.color: Theme.palette.baseColor1
        title: store.enabledNetworks.count === store.allNetworks.count ? qsTr("All networks") : qsTr("%n network(s)", "", store.enabledNetworks.count)
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

    Row {
        anchors.top: selectRectangle.bottom
        anchors.topMargin: Style.current.halfPadding
        anchors.right: parent.right
        spacing: Style.current.smallPadding
        visible: chainRepeater.count > 0

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
        y: (selectRectangle.height + 5)
        layer1Networks: store.layer1Networks
        layer2Networks: store.layer2Networks
        testNetworks: store.testNetworks

        onToggleNetwork: {
            store.toggleNetwork(chainId)
        }
    }
}
