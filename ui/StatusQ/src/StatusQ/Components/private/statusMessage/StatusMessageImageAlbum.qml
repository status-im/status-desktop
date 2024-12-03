import QtQuick 2.15
import QtQuick.Layouts 1.14
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1


RowLayout {
    id: root

    property var album: []
    property int albumCount: 0
    property real imageWidth: 144
    property int shapeType: -1
    property real loadingComponentHeight: 194

    signal imageClicked(var image, var mouse, var imageSource)

    spacing: 9
    Repeater {
        model: root.albumCount

        delegate: Loader {
            active: true
            objectName: "album_image_loader_" + index
            readonly property bool imageLoaded: index < root.album.length
            readonly property string imagePath: imageLoaded ? root.album[index] : ""
            sourceComponent: imageLoaded ? imageComponent : imagePlaceholderComponent
        }
    }

    Component {
        id: imageComponent
        StatusImageMessage {
            Layout.alignment: Qt.AlignLeft
            imageWidth: root.imageWidth
            source: imagePath
            onClicked: root.imageClicked(image, mouse, imageSource)
            shapeType: root.shapeType
        }
    }

    Component {
        id: imagePlaceholderComponent
        LoadingComponent {
            radius: 4
            height: root.loadingComponentHeight
            width: root.imageWidth
        }
    }

    Item {
        Layout.fillWidth: true
        Layout.fillHeight: true
    }
}
