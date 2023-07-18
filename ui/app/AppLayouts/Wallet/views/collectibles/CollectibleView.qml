import QtQuick 2.13
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

import AppLayouts.Communities.panels 1.0

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

    // Special Owner and TMaster token properties
    property bool isPrivilegedToken: false // Owner or TMaster tokens
    property bool isOwner: false // Owner token
    property color ornamentColor // Relevant color for these special tokens (community color)

    signal clicked

    implicitHeight: 225
    implicitWidth: 176

    background: Rectangle {
        radius: 8
        color: Theme.palette.baseColor2
        visible: !root.isLoading && mouse.containsMouse
    }

    contentItem: ColumnLayout {
        spacing: 0

        StatusRoundedMedia {
            id: image

            Layout.alignment: Qt.AlignHCenter
            Layout.margins: Style.current.halfPadding
            Layout.fillWidth: true
            Layout.preferredHeight: width

            visible: !root.isPrivilegedToken
            radius: 8
            mediaUrl: root.mediaUrl
            mediaType: root.mediaType
            fallbackImageUrl: root.fallbackImageUrl
            border.color: Theme.palette.baseColor2
            border.width: 1
            showLoadingIndicator: true
            color: root.isLoading ? "transparent": root.backgroundColor

            Loader {
                anchors.fill: parent
                active: root.isLoading
                sourceComponent: LoadingComponent {radius: image.radius}
            }
        }

        PrivilegedTokenArtworkPanel {
            Layout.alignment: Qt.AlignHCenter
            Layout.margins: Style.current.halfPadding
            Layout.fillWidth: true
            Layout.preferredHeight: width

            visible: root.isPrivilegedToken
            size: PrivilegedTokenArtworkPanel.Size.Medium
            artwork: root.fallbackImageUrl
            color: root.ornamentColor
            isOwner: root.isOwner

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
                Layout.alignment: Qt.AlignLeft
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 15
                customColor: Theme.palette.directColor1
                font.weight: Font.DemiBold
                elide: Text.ElideRight
                text: root.isLoading ? Constants.dummyText : root.title
                loading: root.isLoading
            }

            StatusIcon {
                Layout.alignment: Qt.AlignVCenter
                visible: root.navigationIconVisible
                icon: "next"
                color: Theme.palette.baseColor1
            }
        }

        StatusTextWithLoadingState {
            id: subTitleItem

            Layout.alignment: Qt.AlignLeft
            Layout.topMargin: 3
            Layout.leftMargin: Style.current.halfPadding
            Layout.rightMargin: Layout.leftMargin
            Layout.fillWidth: !root.isLoading
            Layout.preferredWidth: root.isLoading ? 88 : width
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 13
            customColor: Theme.palette.baseColor1
            elide: Text.ElideRight
            text: root.isLoading? Constants.dummyText : root.subTitle
            loading: root.isLoading
        }

        // Filler
        Item {
            Layout.fillHeight: true
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            if (!root.isLoading) {
                root.clicked()
            }
        }
    }
}
