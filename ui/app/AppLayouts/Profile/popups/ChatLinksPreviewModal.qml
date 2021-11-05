import QtQuick 2.13
import QtQuick.Controls 2.13

import utils 1.0

import StatusQ.Controls 0.1 as StatusQControls

import shared 1.0
import shared.panels 1.0
import shared.popups 1.0
import shared.status 1.0

// TODO: replace with StatusModal
ModalPopup {
    id: popup

    //% "Chat link previews"
    title: qsTrId("chat-link-previews")

    onClosed: {
        destroy()
    }

    function populatePreviewableSites() {
        let whitelist = JSON.parse(privacyModule.getLinkPreviewWhitelist())
        if (!localAccountSensitiveSettings.whitelistedUnfurlingSites) {
            localAccountSensitiveSettings.whitelistedUnfurlingSites = {}
        }
        whitelist.forEach(entry => {
            entry.isWhitelisted = localAccountSensitiveSettings.whitelistedUnfurlingSites[entry.address] || false
            previewableSites.append(entry)
        })
    }

    onOpened: {
        populatePreviewableSites()
    }

    Item {
        anchors.fill: parent

        StatusSectionHeadline {
            id: labelWebsites
            //% "Websites"
            text: qsTrId("websites")
            width: parent.width

            StatusQControls.StatusFlatButton {
                //% "Enable all"
                text: qsTrId("enable-all")
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                onClicked: {
                    const count = sitesListView.count
                    for (let i = 0; i < count; i++) {
                        sitesListView.itemAtIndex(i).toggleSetting(true)
                    }
                }
            }
        }

        ListModel {
            id: previewableSites
        }

        Connections {
            target: appMain
            onSettingsLoaded: {
                popup.populatePreviewableSites()
            }
        }

        ScrollView {
            width: parent.width
            anchors.top: labelWebsites.bottom
            anchors.topMargin: Style.current.bigPadding
            anchors.bottom: infoText.top
            anchors.bottomMargin: Style.current.bigPadding
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.vertical.policy: ScrollBar.AlwaysOn
            clip: true

            ListView {
                id: sitesListView
                anchors.fill: parent
                anchors.rightMargin: Style.current.padding
                model: previewableSites
                spacing: 0

                delegate: Component {
                    Rectangle {
                        property bool isHovered: false
                        id: linkRectangle
                        width: parent.width
                        height: 64
                        color: isHovered ? Style.current.backgroundHover : Style.current.transparent
                        radius: Style.current.radius
                        border.width: 0

                        function toggleSetting(newState) {
                            if (newState !== undefined) {
                                settingSwitch.checked = newState
                                return
                            }
                            settingSwitch.checked = !settingSwitch.checked
                        }

                        SVGImage {
                            id: thumbnail
                            width: 40
                            height: 40
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: Style.current.padding

                            source: {
                                let filename;
                                switch (title.toLowerCase()) {
                                case "youtube":
                                case "youtube shortener":
                                    filename = "youtube"; break;
                                case "github":
                                    filename = "github"; break;
                                case "medium":
                                    filename = "medium"; break;
                                case "tenor gifs":
                                    filename = "tenor"; break;
                                case "giphy gifs":
                                case "giphy gifs shortener":
                                case "giphy gifs subdomain":
                                    filename = "giphy"; break;
                                case "github":
                                    filename = "github"; break;
                                case "status":
                                    filename = "status"; break;
                                    // TODO get a good default icon
                                default: filename = "../globe"
                                }
                                return Style.svg(`linkPreviewThumbnails/${filename}`)
                            }

                            Rectangle {
                                width: parent.width
                                height: parent.height
                                radius: width / 2
                                color: Style.current.transparent
                                border.color: Style.current.border
                                border.width: 1
                            }
                        }

                        StyledText {
                            id: siteTitle
                            text: title
                            font.pixelSize: 15
                            font.weight: Font.Medium
                            anchors.top: thumbnail.top
                            anchors.left: thumbnail.right
                            anchors.leftMargin: Style.current.padding
                        }

                        StyledText {
                            text: address
                            font.pixelSize: 15
                            font.weight: Font.Thin
                            color: Style.current.secondaryText
                            anchors.top: siteTitle.bottom
                            anchors.left: siteTitle.left
                        }

                        StatusQControls.StatusSwitch {
                            id: settingSwitch
                            checked: !!isWhitelisted
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.right: parent.right
                            anchors.rightMargin: Style.current.padding
                            onCheckedChanged: function () {
                                let settings = localAccountSensitiveSettings.whitelistedUnfurlingSites

                                if (!settings) {
                                    settings = {}
                                }

                                if (settings[address] === this.checked) {
                                    return
                                }

                                settings[address] = this.checked
                                localAccountSensitiveSettings.whitelistedUnfurlingSites = settings
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onEntered: linkRectangle.isHovered = true
                            onExited: linkRectangle.isHovered = false
                            onClicked: toggleSetting()
                        }
                    }
                }
            }
        }

        StyledText {
            id: infoText
            //% "Previewing links from these websites may share your metadata with their owners."
            text: qsTrId("previewing-links-from-these-websites-may-share-your-metadata-with-their-owners-")
            width: parent.width
            wrapMode: Text.WordWrap
            font.weight: Font.Thin
            color: Style.current.secondaryText
            font.pixelSize: 15
            anchors.bottom: parent.bottom
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
