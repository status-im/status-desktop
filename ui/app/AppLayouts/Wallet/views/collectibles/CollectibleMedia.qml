import QtQuick 2.14

import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

StatusRoundedMedia {
    id: root

    readonly property bool isEmpty: !mediaUrl.toString() && !fallbackImageUrl.toString()
    property color backgroundColor: Theme.palette.baseColor5
    property bool isCollectibleLoading: false
    property bool isMetadataValid: false

    radius: Style.current.radius
    color: isError || isEmpty ? Theme.palette.baseColor5 : backgroundColor

    Loader {
        id: loadingCompLoader
        anchors.fill: parent
        active: root.isCollectibleLoading || root.isLoading
        sourceComponent: LoadingComponent {radius: root.radius}
    }

    Loader {
        anchors.fill: parent
        active: (root.isError || root.isEmpty) && !loadingCompLoader.active
        sourceComponent: LoadingErrorComponent {
            radius: root.radius
            text: {
                if (root.isError && root.componentMediaType === StatusRoundedMedia.MediaType.Unkown) {
                    return qsTr("Unsupported\nfile format")
                }
                if (!root.isMetadataValid) {
                    return qsTr("Info can't\nbe fetched")
                }
                return qsTr("Failed\nto load")
            }
        }
    }
}
