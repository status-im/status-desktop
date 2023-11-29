import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

import AppLayouts.Communities.panels 1.0
import AppLayouts.Wallet.controls 1.0

import utils 1.0

Control {
    id: root

    property string title: ""
    property string subTitle: ""
    property alias subTitleColor: subTitleItem.customColor
    property string backgroundColor: "transparent"
    property url mediaUrl : ""
    property string mediaType: ""
    property url fallbackImageUrl : ""
    property bool isLoading: false
    property bool navigationIconVisible: false
    property string communityId: ""
    property string communityName
    property string communityImage

    // Special Owner and TMaster token properties
    readonly property bool isCommunityCollectible: communityId !== ""
    property int privilegesLevel: Constants.TokenPrivilegesLevel.Community
    readonly property bool isPrivilegedToken: (privilegesLevel === Constants.TokenPrivilegesLevel.Owner) ||
                                              (privilegesLevel === Constants.TokenPrivilegesLevel.TMaster)
    property color ornamentColor // Relevant color for these special tokens (community color)

    signal clicked
    signal rightClicked
    signal switchToCommunityRequested(string communityId)

    background: Rectangle {
        radius: Style.current.radius
        color: Theme.palette.baseColor2
        visible: !root.isLoading && root.hovered

        TapHandler {
            acceptedButtons: Qt.LeftButton
            enabled: !root.isLoading
            onTapped: root.clicked()
        }
        TapHandler {
            acceptedButtons: Qt.RightButton
            enabled: !root.isLoading
            onTapped: root.rightClicked()
        }
    }

    HoverHandler {
        cursorShape: !root.isLoading ? Qt.PointingHandCursor : undefined
    }

    contentItem: ColumnLayout {
        spacing: 0

        StatusRoundedMedia {
            id: image

            Layout.alignment: Qt.AlignHCenter
            Layout.margins: Style.current.halfPadding
            Layout.fillWidth: true
            Layout.preferredHeight: width

            visible: !specialCollectible.visible
            radius: Style.current.radius
            mediaUrl: root.mediaUrl
            mediaType: root.mediaType
            fallbackImageUrl: root.fallbackImageUrl
            showLoadingIndicator: true
            color: root.isLoading ? "transparent" : root.backgroundColor

            Loader {
                anchors.fill: parent
                active: root.isLoading
                sourceComponent: LoadingComponent {radius: image.radius}
            }
        }

        PrivilegedTokenArtworkPanel {
            id: specialCollectible

            Layout.alignment: Qt.AlignHCenter
            Layout.margins: Style.current.halfPadding
            Layout.fillWidth: true
            Layout.preferredHeight: width

            visible: root.isCommunityCollectible && root.isPrivilegedToken
            size: PrivilegedTokenArtworkPanel.Size.Medium
            artwork: root.fallbackImageUrl
            color: root.ornamentColor
            isOwner: root.privilegesLevel === Constants.TokenPrivilegesLevel.Owner

            Loader {
                anchors.fill: parent
                active: root.isLoading
                sourceComponent: LoadingComponent {radius: image.radius}
            }
        }

        RowLayout {
            Layout.leftMargin: Style.current.halfPadding
            Layout.rightMargin: Layout.leftMargin
            Layout.fillWidth: !root.isLoading
            Layout.preferredWidth: root.isLoading ? 134 : width

            StatusTextWithLoadingState {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                customColor: Theme.palette.directColor1
                font.weight: Font.DemiBold
                elide: Text.ElideRight
                text: root.isLoading ? Constants.dummyText : root.title
                loading: root.isLoading
            }

            StatusIcon {
                visible: root.navigationIconVisible
                icon: "next"
                color: Theme.palette.baseColor1
            }
        }

        StatusTextWithLoadingState {
            id: subTitleItem

            Layout.topMargin: 4
            Layout.leftMargin: Style.current.halfPadding
            Layout.rightMargin: Layout.leftMargin
            Layout.fillWidth: !root.isLoading
            Layout.preferredWidth: root.isLoading ? 88 : width
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 13
            customColor: Theme.palette.baseColor1
            elide: Text.ElideRight
            text: root.isLoading ? Constants.dummyText : root.subTitle
            loading: root.isLoading
            visible: text && !root.communityName
        }

        ManageTokensCommunityTag {
            Layout.topMargin: Style.current.halfPadding
            Layout.leftMargin: Style.current.halfPadding
            Layout.rightMargin: Style.current.halfPadding
            Layout.maximumWidth: parent.width - Layout.leftMargin - Layout.rightMargin
            text: root.communityName
            imageSrc: root.communityImage
            visible: root.isCommunityCollectible
            enabled: !root.isLoading
            StatusToolTip {
                text: qsTr("This token was minted by the %1 community").arg(root.communityName)
                visible: parent.hovered
            }
            TapHandler {
                acceptedButtons: Qt.LeftButton
                onSingleTapped: root.switchToCommunityRequested(root.communityId)
            }
        }

        // Filler
        Item {
            Layout.fillHeight: true
        }
    }
}
