import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

import shared 1.0

import utils 1.0

CalloutCard {
    id: root

    enum State {
        Invalid,
        Loading,
        LoadingFailed,
        Loaded
    }

    enum Type {
        Link,
        Image,
        Community,
        Channel,
        User
    }

    required property string titleStr
    required property string domain
    required property string communityName
    required property string channelName
    required property url favIconUrl
    required property url thumbnailImageUrl
    required property int previewState
    required property int type

    readonly property bool containsMouse: mouseArea.hovered || reloadButton.hovered || closeButton.hovered

    signal close()
    signal retry()
    signal clicked(var eventPoint)

    implicitWidth: 260
    implicitHeight: 64
    verticalPadding: 15
    horizontalPadding: 12
    borderColor: Theme.palette.directColor7
    backgroundColor: root.containsMouse ? Theme.palette.directColor7 : Theme.palette.baseColor4

    // behavior
    states: [
        State {
            name: "invalid"
            when: root.previewState === LinkPreviewMiniCard.State.Invalid
            PropertyChanges {
                target: root
                visible: false
            }
        },
        State {
            name: "loading"
            when: root.previewState === LinkPreviewMiniCard.State.Loading
            PropertyChanges { target: root; visible: true; dashedBorder: true; }
            PropertyChanges { target: loadingAnimation; visible: true; }
            PropertyChanges { target: titleText; text: qsTr("Generating preview..."); color: Theme.palette.baseColor1 }
            PropertyChanges { target: subtitleText; visible: false; }
            PropertyChanges { target: reloadButton; visible: false; }
        },
        State {
            name: "loadingFailed"
            when: root.previewState === LinkPreviewMiniCard.State.LoadingFailed
            PropertyChanges { target: root; visible: true; dashedBorder: true; }
            PropertyChanges { target: loadingAnimation; visible: false; }
            PropertyChanges { target: titleText; text: qsTr("Failed to generate preview"); color: Theme.palette.directColor1 }
            PropertyChanges { target: subtitleText; visible: false; }
            PropertyChanges { target: reloadButton; visible: true; }
        },
        State {
            name: "loaded"
            when: root.previewState === LinkPreviewMiniCard.State.Loaded && root.type === LinkPreviewMiniCard.Type.Link
            PropertyChanges { 
                target: root; visible: true; dashedBorder: false; borderWidth: 0;
                backgroundColor: root.containsMouse ? Theme.palette.directColor8 : Theme.palette.indirectColor1; 
                borderColor: backgroundColor;
            }
            PropertyChanges { target: loadingAnimation; visible: false; }
            PropertyChanges { target: titleText; text: root.titleStr; color: Theme.palette.directColor1 }
            PropertyChanges { target: subtitleText; visible: true; }
            PropertyChanges { target: reloadButton; visible: false; }
            PropertyChanges { target: favIcon; visible: true }
        },
        State {
            name: "loadedImage"
            when: root.previewState === LinkPreviewMiniCard.State.Loaded && root.type === LinkPreviewMiniCard.Type.Image
            extend: "loaded"
            PropertyChanges { target: thumbnailImage; visible: root.thumbnailImageUrl != "" }
            PropertyChanges { target: favIcon; visible: true; name: root.domain; asset.isLetterIdenticon: true; asset.color: Theme.palette.baseColor2; }
        },
        State {
            name: "loadedCommunity"
            when: root.previewState === LinkPreviewMiniCard.State.Loaded && root.type === LinkPreviewMiniCard.Type.Community
            extend: "loaded"
            PropertyChanges { target: titleText; text: root.communityName; }
        },
        State {
            name: "loadedChannel"
            when: root.previewState === LinkPreviewMiniCard.State.Loaded && root.type === LinkPreviewMiniCard.Type.Channel
            extend: "loaded"
            PropertyChanges { target: titleText; text: root.communityName; Layout.fillWidth: false; Layout.maximumWidth: Math.min(92, implicitWidth); }
            PropertyChanges { target: secondTitleText; text: root.channelName; visible: true; }
        },
        State {
            name: "loadedUser"
            when: root.previewState === LinkPreviewMiniCard.State.Loaded && root.type === LinkPreviewMiniCard.Type.User
            extend: "loaded"
            PropertyChanges { 
                target: favIcon
                visible: true
                name: root.titleStr
                asset.isLetterIdenticon: true
                asset.charactersLen: 2
                asset.color: Theme.palette.miscColor9
            }
        }
    ]

    contentItem: Item {
        implicitHeight: layout.implicitHeight
        implicitWidth: layout.implicitWidth

        RowLayout {
            id: layout
            anchors.fill: parent
            spacing: 0
            LoadingAnimation {
                id: loadingAnimation
                Layout.alignment: Qt.AlignVCenter
                Layout.margins: 4
                visible: false
            }
            StatusSmartIdenticon {
                id: favIcon
                Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                Layout.topMargin: 1
                Layout.preferredWidth: 16
                Layout.preferredHeight: 16
                visible: false
                name: root.titleStr
                asset.name: root.favIconUrl
                asset.letterSize: asset.charactersLen == 1 ? 10 : 7
            }
            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.leftMargin: 8
                spacing: 0
                RowLayout {
                    id: titleRow
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 0
                    StatusBaseText {
                        id: titleText
                        text: root.titleStr
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        font.pixelSize: Style.current.additionalTextSize
                        font.weight: Font.Medium
                        wrapMode: Text.Wrap
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                        maximumLineCount: 1
                    }
                    StatusIcon {
                        id: secondTitleIcon
                        width: 16
                        height: 16
                        icon: "tiny/chevron-right"
                        color: Theme.palette.baseColor1
                        visible: secondTitleText.visible

                    }
                    StatusBaseText {
                        id: secondTitleText
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        font.pixelSize: Style.current.additionalTextSize
                        font.weight: Font.Medium
                        wrapMode: Text.Wrap
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                        maximumLineCount: 1
                        visible: false
                    }
                }
                StatusBaseText {
                    id: subtitleText
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    font.pixelSize: Style.current.tertiaryTextFontSize
                    color: Theme.palette.baseColor1
                    text: root.domain
                    wrapMode: Text.WordWrap
                    elide: Text.ElideRight
                }
            }
            StatusRoundedImage {
                id: thumbnailImage
                Layout.alignment: Qt.AlignRight
                Layout.rightMargin: 4
                implicitWidth: 34
                implicitHeight: 34
                radius: 4
                image.source: root.thumbnailImageUrl
                visible: false
            }
            StatusFlatButton {
                id: reloadButton
                icon.name: "refresh"
                size: StatusBaseButton.Size.Small
                hoverColor: Theme.palette.directColor8
                textColor: Theme.palette.directColor1
                onClicked: root.retry()
            }
            StatusFlatButton {
                id: closeButton
                icon.name: "close"
                size: StatusBaseButton.Size.Small
                hoverColor: Theme.palette.directColor8
                textColor: Theme.palette.directColor1
                onClicked: root.close()
            }
        }
    }

    HoverHandler {
        id: mouseArea
        target: background
        cursorShape: Qt.PointingHandCursor
    }
    TapHandler {
        id: tapHandler
        target: background
        onTapped: root.clicked(eventPoint)
    }
}
