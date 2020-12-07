import QtQuick 2.3
import QtGraphicalEffects 1.13
import "../../../../../imports"
import "../../../../../shared"
import "../../../../../shared/status"
import "../../../Profile/LeftTab/constants.js" as ProfileConstants

Item {
    id: root
    property string linkUrls: ""

    height: {
        let h = 0
        for (let i = 0; i < linksRepeater.count; i++) {
            h += linksRepeater.itemAt(i).height
        }
        return h
    }
    width: {
        let w = 0
        for (let i = 0; i < linksRepeater.count; i++) {
            if (linksRepeater.itemAt(i).width > w) {
                w = linksRepeater.itemAt(i).width
            }
        }
        return w
    }

    Repeater {
        id: linksRepeater
        model: {
            if (!root.linkUrls) {
                return []
            }

            return root.linkUrls.split(" ")
        }


        delegate: Loader {
            property string linkString: modelData

            // This connection is needed because since the white list is an array, when something in it changes,
            // The whole object is still the same (reference), so the normal signal is not sent
            Connections {
                target: applicationWindow
                onWhitelistChanged: {
                    linkMessageLoader.sourceComponent = linkMessageLoader.getSourceComponent()
                }
            }

            function getSourceComponent() {
                let linkExists = false
                let linkWhiteListed = false
                Object.keys(appSettings.whitelistedUnfurlingSites).some(function (site) {
                    // Check if our link contains the string part of the url
                    // TODO this might become not  a reliable way to check since youtube has mutliple ways of being shown
                    if (modelData.includes(site)) {
                        linkExists = true
                        // check if it was enabled
                        linkWhiteListed = appSettings.whitelistedUnfurlingSites[site] === true
                        return true
                    }
                    return
                })

                if (linkWhiteListed) {
                    return unfurledLinkComponent
                }
                if (linkExists && !appSettings.neverAskAboutUnfurlingAgain) {
                    return enableLinkComponent
                }

                return
            }

            id: linkMessageLoader
            active: true
            sourceComponent: getSourceComponent()
        }
    }

    Component {
        id: unfurledLinkComponent
        Loader {
            property var linkData: {
                const data = chatsModel.getLinkPreviewData(linkString)
                const result = JSON.parse(data)
                if (result.error) {
                    console.error(result.error)
                    return undefined
                }
                return result
            }
            active: linkData !== undefined && !!linkData.title
            sourceComponent: Component {
                Rectangle {
                    id: rectangle
                    width: 300
                    height: childrenRect.height + Style.current.halfPadding
                    radius: 16
                    clip: true
                    border.width: 1
                    border.color: Style.current.border
                    color:Style.current.background

                    // TODO the clip doesnt seem to work. Find another way to have rounded corners and wait for designs
                    Image {
                        id: linkImage
                        source: linkData.thumbnailUrl
                        fillMode: Image.PreserveAspectFit
                        width: parent.width

                        layer.enabled: true
                        layer.effect: OpacityMask {
                            maskSource: Item {
                                width: linkImage.width
                                height: linkImage.height
                                Rectangle {
                                    anchors.centerIn: parent
                                    width: linkImage.width
                                    height: linkImage.height
                                    radius: 16
                                }
                            }
                        }
                    }

                    StyledText {
                        id: linkTitle
                        text: linkData.title
                        font.pixelSize: 13
                        font.weight: Font.Medium
                        elide: Text.ElideRight
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: linkImage.bottom
                        anchors.rightMargin: Style.current.smallPadding
                        anchors.leftMargin: Style.current.smallPadding
                        anchors.topMargin: Style.current.smallPadding
                    }

                    StyledText {
                        id: linkSite
                        text: linkData.site
                        font.pixelSize: 12
                        font.weight: Font.Thin
                        color: Style.current.secondaryText
                        anchors.top: linkTitle.bottom
                        anchors.topMargin: 2
                        anchors.left: linkTitle.left
                    }

                    MouseArea {
                        anchors.top: linkImage.top
                        anchors.left: linkImage.left
                        anchors.right: linkImage.right
                        anchors.bottom: linkSite.bottom
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Qt.openUrlExternally(linkString)
                    }
                }
            }
        }
    }

    Component {
        id: enableLinkComponent
        Rectangle {
            width: 300
            height: childrenRect.height + Style.current.smallPadding
            radius: 16
            border.width: 1
            border.color: Style.current.border
            color:Style.current.background

            StatusIconButton {
                icon.name: "close"
                icon.width: 20
                icon.height: 20
                anchors.top: parent.top
                anchors.topMargin: Style.current.smallPadding
                anchors.right: parent.right
                anchors.rightMargin: Style.current.smallPadding
            }

            Image {
                id: unfurlingImage
                source: "../../../../img/unfurling-image.png"
                width: 132
                height: 94
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: Style.current.smallPadding
            }

            StyledText {
                id: enableText
                text: qsTr("Enable link previews in chat?")
                horizontalAlignment: Text.AlignHCenter
                width: parent.width
                wrapMode: Text.WordWrap
                anchors.top: unfurlingImage.bottom
                anchors.topMargin: Style.current.halfPadding
                font.pixelSize: 15
            }

            StyledText {
                id: infoText
                text: qsTr("Once enabled, links posted in the chat may share your metadata with their owners")
                horizontalAlignment: Text.AlignHCenter
                width: parent.width
                wrapMode: Text.WordWrap
                anchors.top: enableText.bottom
                font.pixelSize: 13
                color: Style.current.secondaryText
            }

            Separator {
                id: sep1
                anchors.top: infoText.bottom
                anchors.topMargin: Style.current.smallPadding
            }

            StatusButton {
                id: enableBtn
                text: qsTr("Enable in Settings")
                type: "secondary"
                onClicked: {
                    appMain.changeAppSection(Constants.profile)
                    profileLayoutContainer.changeProfileSection(ProfileConstants.PRIVACY_AND_SECURITY)
                }
                width: parent.width
//                height: 43
                anchors.top: sep1.bottom
            }

            Separator {
                id: sep2
                anchors.top: enableBtn.bottom
                anchors.topMargin: 0
            }

            StatusButton {
                text: qsTr("Don't ask me again")
                type: "secondary"
                onClicked: {
                    appSettings.neverAskAboutUnfurlingAgain = true
                }
                width: parent.width
//                height: 43
                anchors.top: sep2.bottom
            }
        }
    }
}
