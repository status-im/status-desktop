import QtQuick 2.13
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

import shared 1.0
import shared.panels 1.0
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
            delegate: Control {
                horizontalPadding: Style.current.halfPadding
                verticalPadding: 5
                background: Rectangle {
                    implicitWidth: 66
                    implicitHeight: 32
                    color: "transparent"
                    border.width: 1
                    border.color: Theme.palette.baseColor2
                    radius: 36
                }

                contentItem: Row {
                    spacing: 4
                    // FIXME this could be StatusIcon but it can't load images from an arbitrary URL
                    Image {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 22
                        height: 22
                        source: Style.png(model.iconUrl)
                    }
                    StatusBaseText {
                        anchors.verticalCenter: parent.verticalCenter
                        text: model.shortName
                        color: model.chainColor
                        font.pixelSize: Style.current.primaryTextFontSize
                        font.weight: Font.Medium
                    }
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
