import QtQuick

import StatusQ.Components
import StatusQ.Core.Theme

import utils

StatusRoundedMedia {
    id: root

    readonly property bool isEmpty: !mediaUrl.toString() && !fallbackImageUrl.toString()
    property color backgroundColor: Theme.palette.baseColor5
    property bool isCollectibleLoading: false

    QtObject {
        id: d

        readonly property bool isUnknown: root.isError && root.componentMediaType === StatusRoundedMedia.MediaType.Unknown
    }

    radius: Theme.radius
    color: isError || isEmpty ? Theme.palette.baseColor5 : backgroundColor

    Loader {
        id: loadingCompLoader
        anchors.fill: parent
        active: root.isCollectibleLoading || root.isLoading
        sourceComponent: LoadingComponent {
            objectName: "loadingComponent"
            radius: root.radius
        }
    }

    Loader {
        anchors.fill: parent
        active: (root.isError || root.isEmpty) && !loadingCompLoader.active
        sourceComponent: LoadingErrorComponent {
            objectName: "loadingErrorComponent"
            radius: root.radius
            icon: d.isUnknown ? "frowny": "help"
            text: {
                if (d.isUnknown) {
                    return qsTr("Unsupported\nfile format")
                }
                return ""
            }
        }
    }
}
