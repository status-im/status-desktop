import QtQuick 2.15

import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

StatusRoundedMedia {
    id: root

    readonly property bool isEmpty: !mediaUrl.toString() && !fallbackImageUrl.toString()
    property color backgroundColor: Theme.palette.baseColor5
    property bool isCollectibleLoading: false
    property bool isMetadataValid: false

    QtObject {
        id: d

        property bool isUnknown: root.isError && root.componentMediaType === StatusRoundedMedia.MediaType.Unknown
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
