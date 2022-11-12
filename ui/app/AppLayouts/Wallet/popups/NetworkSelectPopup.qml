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
    id: root
    modal: false
    width: 360
    height: 432

    horizontalPadding: 5
    verticalPadding: 5

    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
    property var layer1Networks
    property var layer2Networks
    property var testNetworks

    // If true NetworksExtraStoreProxy expected for layer1Networks and layer2Networks properties
    property bool useNetworksExtraStoreProxy: false

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

    contentItem: StatusScrollView {
        id: scrollView
        contentHeight: content.height
        width: root.width
        height: root.height
        padding: 0

        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        Column {
            id: content
            width: scrollView.availableWidth
            spacing: 4

            Repeater {
                id: chainRepeater1
                width: parent.width
                height: parent.height
                objectName: "networkSelectPopupChainRepeaterLayer1"
                model: root.layer1Networks

                delegate: chainItem
            }

            StatusBaseText {
                font.pixelSize: Style.current.primaryTextFontSize
                color: Theme.palette.baseColor1
                text: qsTr("Layer 2")
                height: 40
                leftPadding: 16
                topPadding: 10
                verticalAlignment: Text.AlignVCenter

                visible: chainRepeater2.count > 0
            }

            Repeater {
                id: chainRepeater2
                model: root.layer2Networks

                delegate: chainItem
            }

            Repeater {
                id: chainRepeater3
                model: root.testNetworks

                delegate: chainItem
            }
        }
    }

    Component {
        id: chainItem
        StatusListItem {
            objectName: model.chainName
            implicitHeight: 48
            implicitWidth: scrollView.width
            title: model.chainName
            asset.height: 24
            asset.width: 24
            asset.isImage: true
            asset.name: Style.svg(model.iconUrl)
            onClicked:  {
                checkBox.checked = !checkBox.checked
            }
            components: [
                StatusCheckBox {
                    id: checkBox
                    checked: root.useNetworksExtraStoreProxy ? model.isActive : model.isEnabled
                    onCheckedChanged: {
                        if(root.useNetworksExtraStoreProxy && model.isActive !== checked) {
                            model.isActive = checked
                        } else if (model.isEnabled !== checked) {
                            root.toggleNetwork(model.chainId)
                        }
                    }
                }
            ]
        }
    }
}
