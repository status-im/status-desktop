import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Window 2.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

import shared.controls 1.0
import shared.status 1.0
import utils 1.0

import "./private"

CalloutCard {
    id: root

    readonly property LinkData linkData: LinkData { }
    readonly property UserData userData: UserData { }
    readonly property CommunityData communityData: CommunityData { }
    readonly property ChannelData channelData: ChannelData { }

    property int type: Constants.LinkPreviewType.NoPreview

    property bool highlight: false

    signal clicked(var mouse)

    borderWidth: 1
    implicitHeight: 290
    implicitWidth: 305
    hoverEnabled: true
    dropShadow: d.highlight
    borderColor: d.highlight ? Style.current.background : Style.current.border

    Behavior on borderColor {
        ColorAnimation { duration: 200 }
    }

    contentItem: ColumnLayout {
        Loader {
            id: bannerImageLoader
            Layout.fillWidth: true
            Layout.leftMargin: d.bannerImageMargins
            Layout.rightMargin: d.bannerImageMargins
            Layout.topMargin: d.bannerImageMargins
            Layout.preferredHeight: 170
            active: !!d.bannerImageSource
            sourceComponent: StatusImage {
                id: bannerImage
                asynchronous: true
                source: d.bannerImageSource
                fillMode: Image.PreserveAspectCrop
                layer.enabled: true
                layer.effect: root.clippingEffect
            }
        }
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 12
            Loader {
                id: userImageLoader
                Layout.alignment: Qt.AlignLeft | Qt.AlignVCenter
                Layout.topMargin: 8
                Layout.bottomMargin: 8
                visible: active
                active: root.type === Constants.LinkPreviewType.StatusContact
                sourceComponent: UserImage {
                    interactive: false
                    imageWidth: 58
                    imageHeight: imageWidth
                    ensVerified: root.userData.ensVerified
                    name: root.userData.name
                    pubkey: root.userData.publicKey
                    image: root.userData.image
                }
            }
            RowLayout {
                id: titleLayout
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.maximumHeight: description.text.length ? 28 : 72
                Layout.minimumHeight: 18
                StatusSmartIdenticon {
                    id: logo
                    Layout.alignment: Qt.AlignTop
                    Layout.preferredWidth: 28
                    Layout.preferredHeight: 28
                    asset.width: width
                    asset.height: height
                    visible: false
                }
                StatusBaseText {
                    id: title
                    // One line centered next to the logo
                    // Two or more lines, or no logo, top aligned
                    readonly property bool centerText: lineCount == 1 && height === logo.height && logo.visible 
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignTop
                    Layout.topMargin: verticalAlignment === Text.AlignTop && contentHeight < logo.height ? (logo.height - contentHeight) / 2 : 0
                    font.pixelSize: 13
                    font.weight: Font.Medium
                    wrapMode: Text.Wrap
                    elide: Text.ElideRight
                    verticalAlignment: centerText ? Text.AlignVCenter : Text.AlignTop
                    visible: text.length
                }
            }
            EmojiHash {
                Layout.topMargin: 4
                Layout.bottomMargin: 6
                visible: root.type === Constants.LinkPreviewType.StatusContact
                publicKey: root.userData.publicKey
                oneRow: true
            }
            StatusBaseText {
                id: description
                Layout.fillWidth: true
                Layout.fillHeight: true
                font.pixelSize: 12
                wrapMode: Text.Wrap
                elide: Text.ElideRight
                color: Theme.palette.baseColor1
                visible: description.text.length
            }
            Loader {
                id: footerLoader
                Layout.fillWidth: true
                visible: active
                sourceComponent: FooterText {
                }
            }
        }
    }

    MouseArea {
        anchors.fill: root
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: root.clicked(mouse)
    }

    component FooterText: StatusBaseText {
        font.pixelSize: 12
        lineHeight: 16
        lineHeightMode: Text.FixedHeight
        color: Theme.palette.baseColor1
        elide: Text.ElideRight
        wrapMode: Text.Wrap
        verticalAlignment: Text.AlignBottom
        text: root.linkData.domain
        maximumLineCount: 1
    }

    Component {
        id: channelFooterComponent
        RowLayout {
            spacing: 4
            FooterText {
                Layout.fillHeight: true
                text: qsTr("Channel in")
                verticalAlignment: Text.AlignVCenter
            }
            StatusRoundedImage {
                Layout.preferredHeight: 16
                Layout.preferredWidth: height
                image.source: channelData.communityData.image                
            }
            FooterText {
                Layout.fillHeight: true
                Layout.fillWidth: true
                text: channelData.communityData.name
                verticalAlignment: Text.AlignVCenter
                color: Theme.palette.directColor1
            }
        }
    }

    Component {
        id: communityFooterComponent
        RowLayout {
            spacing: 2
            StatusIcon {
                icon: "group"
                color: Theme.palette.directColor1
                width: 16
                height: width
            }
            FooterText {
                Layout.fillHeight: true
                Layout.fillWidth: !communityData.activeMembersCountAvailable
                color: Theme.palette.directColor1
                text: LocaleUtils.numberToLocaleStringInCompactForm(communityData.membersCount)
                verticalAlignment: Text.AlignVCenter
            }
            StatusIcon {
                Layout.leftMargin: 6
                icon: "active-members"
                color: Theme.palette.directColor1
                width: 16
                height: width
                visible: communityData.activeMembersCountAvailable
            }
            FooterText {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: Theme.palette.directColor1
                text: LocaleUtils.numberToLocaleStringInCompactForm(communityData.activeMembersCount)
                verticalAlignment: Text.AlignVCenter
                visible: communityData.activeMembersCountAvailable
            }
        }
    }
    
    //behavior
    states: [
        State {
            name: "noPreview"
            when: root.type === Constants.LinkPreviewType.NoPreview
            PropertyChanges { target: root; visible: false }
        },
        State {
            name: "linkPreview"
            when: root.type === Constants.LinkPreviewType.Standard
            PropertyChanges { 
                target: logo
                visible: !!root.linkData.image
                name: root.linkData.domain
                asset.name: root.linkData.image
                asset.isImage: !!root.linkData.image
                asset.color: Theme.palette.baseColor2
            }
            PropertyChanges { target: bannerImageLoader; visible: true }
            PropertyChanges { target: title; text: root.linkData.title }
            PropertyChanges { target: description; text: root.linkData.description }
            PropertyChanges { target: d; bannerImageSource: root.linkData.thumbnail }
        },
        State {
            name: "community"
            when: root.type === Constants.LinkPreviewType.StatusCommunity
            PropertyChanges { 
                target: logo
                visible: true
                name: root.communityData.name
                asset.name: root.communityData.image
                asset.isImage: !!root.communityData.image
                asset.color: root.communityData.color
            }
            PropertyChanges { target: bannerImageLoader; visible: true }
            PropertyChanges { target: title; text: root.communityData.name }
            PropertyChanges { target: description; text: root.communityData.description }
            PropertyChanges { target: d; bannerImageSource: root.communityData.banner }
            PropertyChanges { target: footerLoader; active: true; visible: true; sourceComponent: communityFooterComponent }
        },
        State {
            name: "channel"
            when: root.type === Constants.LinkPreviewType.StatusCommunityChannel
            PropertyChanges { 
                target: logo
                visible: true
                name: root.channelData.name
                asset.name: ""
                asset.isImage: false
                asset.color: root.channelData.color
                asset.emoji: root.channelData.emoji
            }
            PropertyChanges { target: bannerImageLoader; visible: true }
            PropertyChanges { target: title; text: "#" + root.channelData.name }
            PropertyChanges { target: description; text: root.channelData.description || root.channelData.communityData.description }
            PropertyChanges { target: d; bannerImageSource: root.channelData.communityData.banner }
            PropertyChanges { target: footerLoader; active: true; visible: true; sourceComponent: channelFooterComponent }
        },
        State {
            name: "contact"
            when: root.type === Constants.LinkPreviewType.StatusContact
            PropertyChanges { target: root; implicitHeight: 187 }
            PropertyChanges { target: bannerImageLoader; visible: false }
            PropertyChanges { target: footerLoader; active: false; visible: !root.userData.bio; Layout.fillHeight: true }
            PropertyChanges { target: title; text: root.userData.name }
            PropertyChanges { target: description; text: root.userData.bio; Layout.minimumHeight: 32; visible: true }
        }
    ]

    QtObject {
        id: d
        property real bannerImageMargins: 1 / Screen.devicePixelRatio // image size isn't pixel perfect..
        property bool highlight: root.highlight || root.hovered
        property string bannerImageSource: ""
    }
}
