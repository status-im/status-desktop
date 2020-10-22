import QtQuick 2.1
import QtGraphicalEffects 1.13
import "../../../shared"
import "../../../shared/status"
import "../../../imports"


Item {
    id: downloadElement
    width: 272
    height: 40

    Loader {
        id: iconLoader
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: Style.current.smallPadding
        active: root.visible
        sourceComponent: {
            if (!downloadModel.downloads || !downloadModel.downloads[index] || downloadModel.downloads[index].receivedBytes < downloadModel.downloads[index].totalBytes) {
                return loadingImageComponent
            }
            return fileImageComponent
        }

        Component {
            id: loadingImageComponent
            LoadingImage {}
        }
        Component {
            id: fileImageComponent
            SVGImage {
                source: "../../img/browser/file.svg"
                width: 24
                height: 24
                ColorOverlay {
                    enabled: false
                    anchors.fill: parent
                    source: parent
                    color: Style.current.darkGrey
                }
            }
        }
    }

    StyledText {
        id: filenameText
        text: downloadFileName
        elide: Text.ElideRight
        anchors.left: iconLoader.right
        anchors.right: optionsBtn.left
        anchors.top: parent.top
        minimumPixelSize: 13
        anchors.leftMargin: Style.current.smallPadding
        anchors.topMargin: 2
    }

    StyledText {
        id: progressText
        color: Style.current.secondaryText
        text: `${downloadModel.downloads[index] ? downloadModel.downloads[index].receivedBytes / 1000000 : 0}/${downloadModel.downloads[index] ? downloadModel.downloads[index].totalBytes / 1000000 : 0} MB` //"14.4/109 MB, 26 sec left"
        elide: Text.ElideRight
        anchors.left: iconLoader.right
        anchors.right: optionsBtn.left
        anchors.bottom: parent.bottom
        minimumPixelSize: 13
        anchors.leftMargin: Style.current.smallPadding
        anchors.bottomMargin: 2
    }

    StatusIconButton {
        id: optionsBtn
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: Style.current.smallPadding
        icon.name: "dots-icon"
    }
}

