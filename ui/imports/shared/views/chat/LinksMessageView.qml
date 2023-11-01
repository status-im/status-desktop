import QtQuick 2.15

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

import shared.controls 1.0
import shared.status 1.0
import shared.panels 1.0

import shared.controls.delegates 1.0

Flow {
    id: root

    required property bool isOnline
    required property bool playAnimations

    required property var linkPreviewModel
    required property var gifLinks

    required property bool gifUnfurlingEnabled
    required property bool canAskToUnfurlGifs

    readonly property alias hoveredLink: linksRepeater.hoveredUrl
    property string highlightLink: ""

    signal imageClicked(var image, var mouse, string imageSource, string url)
    signal openContextMenu(var item, string url, string domain)
    signal setNeverAskAboutUnfurlingAgain(bool neverAskAgain)

    function resetLocalAskAboutUnfurling() {
        d.localAskAboutUnfurling = true
    }

    spacing: 12

    //TODO: remove once GIF previews are unfurled sender side

    QtObject {
        id: d
        property bool localAskAboutUnfurling: true
    }

    Loader {
        visible: active
        active: root.gifLinks && root.gifLinks.length > 0
                 && !root.gifUnfurlingEnabled
                 && d.localAskAboutUnfurling && root.canAskToUnfurlGifs
        sourceComponent: enableLinkComponent
    }

    Repeater {
        id: tempRepeater
        visible: root.canAskToUnfurlGifs
        model: root.gifUnfurlingEnabled ? gifLinks : []

        delegate: LinkPreviewGifDelegate {
            required property string modelData

            link: modelData
            isOnline: root.isOnline
            playAnimation: root.playAnimations
            onClicked: root.imageClicked(imageAlias, mouse, link, link)
        }
    }

    Repeater {
        id: linksRepeater

        property string hoveredUrl: ""

        model: root.linkPreviewModel
        delegate: LinkPreviewCardDelegate {
            id: delegate
            highlight: url === root.highlightLink
            onHoveredChanged: {
                linksRepeater.hoveredUrl = hovered ? url : ""
            }
            onClicked: (mouse) => {
                if(mouse.button === Qt.RightButton) {
                    const domain = previewType === Constants.LinkPreviewType.Standard ? linkData.domain : Constants.externalStatusLink
                    root.openContextMenu(delegate, url, domain)
                    return
                }

                if(previewType === Constants.LinkPreviewType.Standard) {
                    Global.openLinkWithConfirmation(url, linkData.domain)
                    return
                }

                Global.activateDeepLink(url)
            }
        }
    }

    Component {
        id: enableLinkComponent

        Rectangle {
            id: enableLinkRoot
            implicitWidth: 300
            implicitHeight: childrenRect.height + Style.current.smallPadding
            radius: 16
            border.width: 1
            border.color: Style.current.border
            color: Style.current.background

            StatusFlatRoundButton {
                anchors.top: parent.top
                anchors.topMargin: Style.current.smallPadding
                anchors.right: parent.right
                anchors.rightMargin: Style.current.smallPadding
                icon.width: 20
                icon.height: 20
                icon.name: "close-circle"
                onClicked: d.localAskAboutUnfurling = false
            }
            Image {
                id: unfurlingImage
                source: Style.png("unfurling-image")
                width: 132
                height: 94
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: Style.current.smallPadding
            }
            StatusBaseText {
                id: enableText
                text: qsTr("Enable automatic GIF unfurling")
                horizontalAlignment: Text.AlignHCenter
                width: parent.width
                wrapMode: Text.WordWrap
                anchors.top: unfurlingImage.bottom
                anchors.topMargin: Style.current.halfPadding
                color: Theme.palette.directColor1
            }
            StatusBaseText {
                id: infoText
                text: qsTr("Once enabled, links posted in the chat may share your metadata with their owners")
                horizontalAlignment: Text.AlignHCenter
                width: parent.width
                wrapMode: Text.WordWrap
                anchors.top: enableText.bottom
                font.pixelSize: 13
                color: Theme.palette.baseColor1
            }
            Separator {
                id: sep1
                anchors.top: infoText.bottom
                anchors.topMargin: Style.current.smallPadding
            }
            StatusFlatButton {
                id: enableBtn
                objectName: "LinksMessageView_enableBtn"
                text: qsTr("Enable in Settings")
                onClicked: {
                    Global.changeAppSectionBySectionType(Constants.appSection.profile, Constants.settingsSubsection.messaging);
                }
                width: parent.width
                anchors.top: sep1.bottom
                Component.onCompleted: {
                    background.radius = 0;
                }
            }
            Separator {
                id: sep2
                anchors.top: enableBtn.bottom
                anchors.topMargin: 0
            }
            Item {
                width: parent.width
                height: 44
                anchors.top: sep2.bottom
                clip: true
                StatusFlatButton {
                    id: dontAskBtn
                    width: parent.width
                    height: (parent.height+Style.current.padding)
                    anchors.top: parent.top
                    anchors.topMargin: -Style.current.padding
                    contentItem: Item {
                        StatusBaseText {
                            anchors.centerIn: parent
                            anchors.verticalCenterOffset: Style.current.halfPadding
                            font: dontAskBtn.font
                            color: dontAskBtn.textColor
                            text: qsTr("Don't ask me again")
                        }
                    }
                    onClicked: root.setNeverAskAboutUnfurlingAgain(true)
                    Component.onCompleted: {
                        background.radius = Style.current.padding;
                    }
                }
            }
        }
    }
}

