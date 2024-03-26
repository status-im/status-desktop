import QtQuick 2.13
import QtQuick.Layouts 1.13

import utils 1.0

import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1
import StatusQ.Controls 0.1

import shared.controls 1.0

ColumnLayout {
    id: root

    property alias collectibleName: collectibleName.text
    property alias collectibleId: collectibleId.text
    property alias collectionTag: collectionTag
    property string isCollection

    property string communityImage
    property string networkShortName
    property string networkColor
    property string networkIconURL
    property string networkExplorerName

    property bool collectibleLinkEnabled
    property bool collectionLinkEnabled
    property bool explorerLinkEnabled

    signal collectionTagClicked()
    signal openCollectibleExternally()
    signal openCollectibleOnExplorer()

    RowLayout {
        RowLayout {
            StatusBaseText {
                id: collectibleName

                font.pixelSize: 22
                lineHeight: 30
                lineHeightMode: Text.FixedHeight
                elide: Text.ElideRight
                color: Theme.palette.directColor1
            }
            StatusBaseText {
                id: collectibleId
                Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                font.pixelSize: 22
                lineHeight: 30
                lineHeightMode: Text.FixedHeight
                elide: Text.ElideRight
                color: Theme.palette.baseColor1
            }
        }

        Item{Layout.fillWidth: true}

        RowLayout {
            spacing: 12
            StatusButton {
                size: StatusBaseButton.Size.Small
                text: root.networkExplorerName
                icon.name: "external"
                onClicked: root.openCollectibleOnExplorer()
                visible: root.explorerLinkEnabled
            }
            StatusButton {
                size: StatusBaseButton.Size.Small
                text: "OpenSea"
                icon.name: "external"
                onClicked: root.openCollectibleExternally()
                visible: root.collectibleLinkEnabled
            }
        }
    }

    RowLayout {
        spacing: 10

        InformationTag {
            id: collectionTag
            asset.name: !!root.communityImage ? root.communityImage: !sensor.containsMouse ? root.isCollection ? "tiny/folder" : "tiny/profile" : "tiny/external"
            asset.isImage: !!root.communityImage
            enabled: root.collectionLinkEnabled
            MouseArea {
                id: sensor
                anchors.fill: parent
                hoverEnabled: root.collectionLinkEnabled
                cursorShape: root.collectionLinkEnabled ? Qt.PointingHandCursor: undefined
                enabled: root.collectionLinkEnabled
                onClicked: {
                    root.collectionTagClicked()
                }
            }
        }

        InformationTag {
            id: networkTag
            readonly property bool isNetworkValid: networkShortName !== ""
            asset.name: isNetworkValid && networkIconURL !== "" ? Style.svg("tiny/" + networkIconURL) : ""
            asset.isImage: true
            tagPrimaryLabel.text: isNetworkValid ? networkShortName : "---"
            tagPrimaryLabel.color: isNetworkValid ? networkColor : "black"
            visible: isNetworkValid
        }
    }
}
