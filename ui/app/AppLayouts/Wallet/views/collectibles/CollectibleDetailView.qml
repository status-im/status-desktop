import QtQuick 2.14
import QtQuick.Layouts 1.13

import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils

import utils 1.0
import shared.controls 1.0

import "../../stores"
import "../../controls"

Item {
    id: root

    property var currentCollectible: RootStore.currentCollectible
    readonly property int isNarrowMode : width < 700

    CollectibleDetailsHeader {
        id: collectibleHeader
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        asset.name: currentCollectible.collectionImageUrl
        asset.isImage: true
        primaryText: currentCollectible.collectionName
        secondaryText: "#" + currentCollectible.tokenId
        isNarrowMode: root.isNarrowMode
        networkShortName: currentCollectible.networkShortName
        networkColor: currentCollectible.networkColor
        networkIconURL: currentCollectible.networkIconUrl
    }

    ColumnLayout {
        id: collectibleBody
        anchors.top: collectibleHeader.bottom
        anchors.topMargin: 25
        anchors.left: parent.left
        anchors.leftMargin: root.isNarrowMode ? 0 : 52
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        spacing: Style.current.padding

        Row {
            id: collectibleImageDetails
            Layout.preferredHeight: root.isNarrowMode ? 152 : collectibleimage.height
            Layout.preferredWidth: parent.width
            spacing: 24

            StatusRoundedMedia {
                id: collectibleimage
                readonly property int size : root.isNarrowMode ? 132 : 253
                width: size
                height: size
                radius: 2
                color: currentCollectible.backgroundColor
                border.color: Theme.palette.directColor8
                border.width: 1
                mediaUrl: currentCollectible.mediaUrl
                mediaType: currentCollectible.mediaType
                fallbackImageUrl: currentCollectible.imageUrl
            }

            Column {
                id: collectibleNameAndDescription
                spacing: 12

                width: parent.width - collectibleimage.width - Style.current.bigPadding

                StatusBaseText {
                    id: collectibleName
                    width: parent.width
                    height: 24

                    text: currentCollectible.name
                    color: Theme.palette.directColor1
                    font.pixelSize: 17
                    lineHeight: 24
                    elide: Text.ElideRight
                    wrapMode: Text.WordWrap
                }

                StatusScrollView {
                    id: descriptionScrollView
                    width: parent.width
                    height: collectibleImageDetails.height - collectibleName.height - parent.spacing

                    contentWidth: availableWidth

                    padding: 0
                    
                    StatusBaseText {
                        id: descriptionText
                        width: descriptionScrollView.availableWidth

                        text: currentCollectible.description
                        textFormat: Text.MarkdownText
                        color: Theme.palette.directColor4
                        font.pixelSize: 15
                        lineHeight: 22
                        lineHeightMode: Text.FixedHeight
                        elide: Text.ElideRight
                        wrapMode: Text.Wrap
                    }
                }
            }
        }

        StatusTabBar {
            id: collectiblesDetailsTab
            Layout.fillWidth: true
            Layout.topMargin: root.isNarrowMode ? 0 : Style.current.xlPadding
            visible: currentCollectible.properties.count > 0

            StatusTabButton {
                leftPadding: 0
                width: implicitWidth
                text: qsTr("Properties")
            }
        }

        StatusScrollView {
            id: scrollView
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: availableWidth
            Flow {
                width: scrollView.availableWidth
                spacing: 10
                Repeater {
                    model: currentCollectible.properties
                    InformationTile {
                        maxWidth: parent.width
                        primaryText: model.traitType
                        secondaryText: model.value
                    }
                }
            }
        }
    }
}
