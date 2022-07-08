import QtQuick 2.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

import shared 1.0
import shared.panels 1.0
import utils 1.0

import "../popups"

Item {
    id: root
    width: selectRectangle.width
    height: childrenRect.height

    property var store

    StatusListItem {
        id: selectRectangle
        implicitWidth: 210
        implicitHeight: 40
        border.width: 1
        border.color: Theme.palette.baseColor2
        color: Theme.palette.statusListItem.backgroundColor
        title: qsTr("All networks")
        components:[
            StatusIcon {
                width: 20
                height: 20
                icon: "chevron-down"
                color: Theme.palette.baseColor1
            }
        ]
        onClicked: {
            if (selectPopup.opened) {
                selectPopup.close();
                return;
            }
            selectPopup.open();
        }
    }

    Grid {
        id: enabledNetworks
        columns: 4
        spacing: 2
        visible: (chainRepeater.count > 0)

        anchors.top: selectRectangle.bottom
        anchors.topMargin: Style.current.padding
        anchors.horizontalCenter: parent.horizontalCenter

        Repeater {
            id: chainRepeater
            model: store.enabledNetworks
            width: parent.width
            height: parent.height

            Rectangle {
                color: Utils.setColorAlpha(Style.current.blue, 0.1)
                width: text.width + Style.current.halfPadding
                height: text.height + Style.current.halfPadding
                radius: Style.current.radius

                StyledText {
                    id: text
                    text: model.chainName
                    color: Style.current.blue
                    font.pixelSize: Style.current.secondaryTextFontSize
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }

    NetworkSelectPopup {
        id: selectPopup
        x: (parent.width - width)
        layer1Networks: store.layer1Networks
        layer2Networks: store.layer2Networks
        testNetworks: store.testNetworks

        onToggleNetwork: {
            store.toggleNetwork(chainId)
        }
    }
}
