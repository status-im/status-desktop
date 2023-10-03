import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.15

import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

import shared.controls 1.0
import utils 1.0

ColumnLayout {
    id: root

    property string nftName
    property string nftUrl
    property string tokenId
    property string tokenAddress
    property bool strikethrough: false
    property bool areTestNetworksEnabled: false
    property bool isSepoliaEnabled: false

    spacing: Style.current.padding

    StatusBaseText {
        Layout.fillWidth: true
        font.pixelSize: 15
        color: Theme.palette.directColor5
        text: qsTr("Preview")
        elide: Text.ElideRight
    }

    Rectangle {
        radius: 8
        Layout.fillWidth: true
        Layout.preferredHeight: nftPreviewColumn.height + Style.current.bigPadding
        color: nftPreviewSensor.hovered ? Theme.palette.baseColor2 : "transparent"
        border.width: 1
        border.color: Style.current.separator

        HoverHandler {
            id: nftPreviewSensor
            target: parent
        }

        Column {
            // NOTE Using Column instead of Layout to handle image fill mode properly
            id: nftPreviewColumn
            spacing: Style.current.padding
            anchors {
                left: parent.left
                top: parent.top
                right: parent.right
                margins: Style.current.bigPadding / 2
            }
            height: childrenRect.height

            StatusRoundedMedia {
                id: nftPreviewImage
                width: parent.width
                height: width
                mediaUrl: root.nftUrl
                mediaType: "image"
                radius: 8
            }

            RowLayout {
                width: parent.width
                spacing: Style.current.smallPadding
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.rightMargin: button.visible ? 0 : button.width + parent.spacing
                    Layout.topMargin: Style.current.smallPadding
                    Layout.alignment: Qt.AlignLeft
                    spacing: 4
                    StatusBaseText {
                        Layout.fillWidth: true
                        font.pixelSize: 15
                        font.strikeout: root.strikethrough
                        text: root.nftName
                        visible: !!text
                        elide: Text.ElideRight
                    }

                    StatusBaseText {
                        Layout.fillWidth: true
                        font.pixelSize: 15
                        color: Theme.palette.directColor5
                        text: root.tokenId
                        visible: !!text
                        elide: Text.ElideRight
                    }
                }

                StatusRoundButton {
                    id: button
                    implicitWidth: 32
                    implicitHeight: 32
                    Layout.alignment: Qt.AlignRight | Qt.AlignTop
                    icon.color: hovered ? Theme.palette.directColor1 : Theme.palette.baseColor1
                    icon.name: "external"
                    type: StatusRoundButton.Type.Quinary
                    radius: 8
                    visible: nftPreviewSensor.hovered && !!root.tokenId && !!root.tokenAddress
                    onClicked: {
                        let link = Constants.networkExplorerLinks.etherscan
                        if (areTestNetworksEnabled) {
                            if (root.isSepoliaEnabled) {
                                link = Constants.networkExplorerLinks.sepoliaEtherscan
                            } else {
                                link = Constants.networkExplorerLinks.goerliEtherscan
                            }
                        }
                        Global.openLink("%1/nft/%2/%3".arg(link).arg(root.tokenAddress).arg(root.tokenId))
                    }
                }
            }
        }
    }
}
