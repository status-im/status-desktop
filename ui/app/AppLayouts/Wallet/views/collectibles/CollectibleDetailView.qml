import QtQuick 2.14
import QtQuick.Layouts 1.13

import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils

import AppLayouts.Communities.panels 1.0

import utils 1.0
import shared.controls 1.0

import "../../stores"
import "../../controls"

Item {
    id: root

    property var collectible
    property bool isCollectibleLoading
    readonly property int isNarrowMode : width < 700

    // Community related token props:
    readonly property bool isCommunityCollectible: !!collectible ? collectible.communityId !== "" : false
    readonly property bool isOwnerTokenType: !!collectible ? (collectible.communityPrivilegesLevel === Constants.TokenPrivilegesLevel.Owner) : false
    readonly property bool isTMasterTokenType: !!collectible ? (collectible.communityPrivilegesLevel === Constants.TokenPrivilegesLevel.TMaster) : false

    CollectibleDetailsHeader {
        id: collectibleHeader
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        asset.name: collectible.collectionImageUrl
        asset.isImage: true
        primaryText: collectible.collectionName
        secondaryText: "#" + collectible.tokenId
        isNarrowMode: root.isNarrowMode
        networkShortName: collectible.networkShortName
        networkColor: collectible.networkColor
        networkIconURL: collectible.networkIconUrl
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

            readonly property real visibleImageHeight: (collectibleimage.visible ? collectibleimage.height : privilegedCollectibleImage.height)
            readonly property real visibleImageWidth: (collectibleimage.visible ? collectibleimage.width : privilegedCollectibleImage.width)

            Layout.preferredHeight: collectibleImageDetails.visibleImageHeight
            Layout.preferredWidth: parent.width
            spacing: 24

            // Special artwork representation for community `Owner and Master Token` token types:
            PrivilegedTokenArtworkPanel {
                id: privilegedCollectibleImage

                visible: root.isCommunityCollectible && (root.isOwnerTokenType || root.isTMasterTokenType)
                size: root.isNarrowMode ? PrivilegedTokenArtworkPanel.Size.Medium : PrivilegedTokenArtworkPanel.Size.Large
                artwork: collectible.imageUrl
                color: !!collectible ? collectible.communityColor : "transparent"
                isOwner: root.isOwnerTokenType
            }

            StatusRoundedMedia {
                id: collectibleimage

                readonly property int size : root.isNarrowMode ? 132 : 253

                visible: !privilegedCollectibleImage.visible
                width: size
                height: size
                radius: 2
                color: collectible.backgroundColor
                border.color: Theme.palette.directColor8
                border.width: 1
                mediaUrl: collectible.mediaUrl
                mediaType: collectible.mediaType
                fallbackImageUrl: collectible.imageUrl
            }

            Column {
                id: collectibleNameAndDescription
                spacing: 12

                width: parent.width - collectibleImageDetails.visibleImageWidth - Style.current.bigPadding

                StatusBaseText {
                    id: collectibleName
                    width: parent.width
                    height: 24

                    text: collectible.name
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

                        text: collectible.description
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
            Layout.topMargin: root.isNarrowMode ? Style.current.padding : Style.current.xlPadding
            visible: collectible.traits.count > 0

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
                    model: collectible.traits
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
