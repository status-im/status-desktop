import QtQuick 2.13
import QtQuick.Controls 2.13
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"

ModalPopup {
    id: popup

    title: qsTr("Chat link previews")

    onClosed: {
        destroy()
    }

    function populatePreviewableSites() {
        let whitelist = JSON.parse(profileModel.getLinkPreviewWhitelist())
        whitelist.forEach(entry => {
            entry.isWhitelisted = appSettings.whitelistedUnfurlingSites[entry.address] || false
            previewableSites.append(entry)
        })
    }

    onOpened: {
        populatePreviewableSites()
    }

    Column {
        anchors.fill: parent
        spacing: Style.current.bigPadding

        StatusSectionHeadline {
            id: labelWebsites
            text: qsTr("Websites")
            width: parent.width

            StatusButton {
                text: qsTr("Enable all")
                type: "secondary"
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                flat: true
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
            target: applicationWindow
            onSettingsLoaded: {
                popup.populatePreviewableSites()
            }
        }

        ListView {
            id: sitesListView
            width: parent.width
            model: previewableSites
            interactive: false
            height: childrenRect.height
            spacing: Style.current.padding

            delegate: Component {
                Item {
                    width: parent.width
                    height: linkLine.height
                    function toggleSetting(newState) {
                        if (newState !== undefined) {
                            settingSwitch.checked = newState
                            return
                        }
                        settingSwitch.checked = !settingSwitch.checked
                    }

                    Item {
                        id: linkLine
                        width: parent.width
                        height: childrenRect.height

                        SVGImage {
                            id: thumbnail
                            width: 40
                            height: 40
                            source: {
                                let filename;
                                switch (title.toLowerCase()) {
                                case "youtube":
                                case "youtube shortener":
                                    filename = "youtube.png"; break;
                                case "github":
                                    filename = "github.png"; break;
                                // TODO get a good default icon
                                default: filename = "../globe.svg"
                                }
                                return `../../../img/linkPreviewThumbnails/${filename}`
                            }
                            anchors.top: parent.top
                            anchors.left: parent.left
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

                        StatusSwitch {
                            id: settingSwitch
                            checked: !!isWhitelisted
                            onCheckedChanged: function () {
                                if (appSettings.whitelistedUnfurlingSites[address] === this.checked) {
                                    return
                                }

                                const settings = appSettings.whitelistedUnfurlingSites
                                settings[address] = this.checked
                                appSettings.whitelistedUnfurlingSites = settings
                            }
                            anchors.verticalCenter: siteTitle.bottom
                            anchors.right: parent.right
                        }
                    }

                    MouseArea {
                        anchors.fill: linkLine
                        cursorShape: Qt.PointingHandCursor
                        onClicked: toggleSetting()
                    }
                }
            }
        }

        StyledText {
            text: qsTr("Previewing links from these websites may share your metadata with their owners.")
            width: parent.width
            wrapMode: Text.WordWrap
            font.weight: Font.Thin
            color: Style.current.secondaryText
            font.pixelSize: 15
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
