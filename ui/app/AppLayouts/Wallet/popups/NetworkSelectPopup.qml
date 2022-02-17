import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

import utils 1.0

// TODO: replace with StatusModal
Popup {
    id: popup
    modal: false
    width: 360
    height: 432
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
    property var layer1Networks
    property var layer2Networks
    property var testNetworks

    signal toggleNetwork(int chainId)

    background: Rectangle {
        radius: Style.current.radius
        color: Style.current.background
        border.color: Style.current.border
        layer.enabled: true
        layer.effect: DropShadow{
            verticalOffset: 3
            radius: 8
            samples: 15
            fast: true
            cached: true
            color: "#22000000"
        }
    }

    contentItem: ScrollView {
        id: scrollView
        contentHeight: content.height
        width: popup.width
        height: popup.height

        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        clip: true

        Column {
            id: content
            width: popup.width
            spacing: Style.current.padding

            Repeater {
                id: chainRepeater1
                model: popup.layer1Networks

                delegate: chainItem
            }

            Repeater {
                id: chainRepeater2
                model: popup.layer2Networks

                delegate: chainItem
            }

            Repeater {
                id: chainRepeater3
                model: popup.testNetworks

                delegate: chainItem
            }
        }
    }

    Component {
        id: chainItem
        Item {
            width: content.width
            height: 40
            StatusBaseText {
                anchors.left: parent.left
                anchors.leftMargin: Style.current.bigPadding
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: Style.current.primaryTextFontSize
                text: model.chainName
                color: Theme.palette.directColor1
            }

            StatusCheckBox {
                anchors.right: parent.right
                anchors.rightMargin: Style.current.bigPadding
                anchors.verticalCenter: parent.verticalCenter
                checked: model.isEnabled
                onCheckedChanged: {
                    if (model.isEnabled !== checked) {
                        popup.toggleNetwork(model.chainId)
                    }
                }
            }
        }
    }
}
