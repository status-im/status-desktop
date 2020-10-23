import QtQuick 2.3
import "../../../../../imports"
import "../../../../../shared"

Item {
    id: linksItem
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
            if (!linkUrls) {
                return []
            }

            return linkUrls.split(" ")
        }

        delegate: Loader {
            property string linkString: modelData
            active: true
            sourceComponent: {
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
                if (linkExists) {
                    return enableLinkComponent
                }

                return
            }
        }
    }

    Component {
        id: unfurledLinkComponent
        Loader {
            property var linkData: {
                try {
                    const data = chatsModel.getLinkPreviewData(linkString)
                    return JSON.parse(data)
                } catch (e) {
                    console.error("Error parsing link data", e)
                    return undfined
                }
            }
            enabled: linkData !== undefined && !!linkData.title
            sourceComponent: Component {
                Rectangle {
                    id: rectangle
                    width: 200
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
                        width: 200
                    }

                    StyledText {
                        id: linkTitle
                        text: linkData.title
                        elide: Text.ElideRight
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: linkImage.bottom
                        anchors.rightMargin: Style.current.halfPadding
                        anchors.leftMargin: Style.current.halfPadding
                        anchors.topMargin: Style.current.halfPadding
                    }

                    StyledText {
                        id: linkSite
                        text: linkData.site
                        color: Style.current.secondaryText
                        anchors.top: linkTitle.bottom
                        anchors.topMargin: Style.current.halfPadding
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
            height: 200
            radius: 16

            border.width: 1
            border.color: Style.current.border
            color:Style.current.background

            StyledText {
                text: qsTr("You need to enable this before being able to see it")
            }
        }
    }
}
