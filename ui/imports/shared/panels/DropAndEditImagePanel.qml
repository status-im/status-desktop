import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import utils
import shared.panels
import shared.popups

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Layout
import StatusQ.Components
import StatusQ.Controls
import StatusQ.Controls.Validators
import StatusQ.Popups

Item {
    id: root

    property bool hasImage: false
    property bool isDraggable: true
    property bool containsDrag: dropArea.containsDrag
    property bool editorAnchorLeft: true
    property alias uploadTextLabel: textLabel
    property alias editorRoundedImage: editor.roundedImage
    property alias dataImage: editor.dataImage
    property alias artworkSource: editor.source
    property alias artworkCropRect: editor.cropRect
    property alias editorTitle: editor.title
    property alias acceptButtonText: editor.acceptButtonText

    Item {
        id: dropAreaItem
        anchors.fill: parent
        Rectangle {
            anchors.fill: parent
            opacity: root.containsDrag ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 100 } }
            color: "#33869eff"
            border.color: Theme.palette.primaryColor1
            radius: Theme.radius
            NoImageUploadedPanel {
                visible: !editor.userSelectedImage
                anchors.centerIn: parent
                imgColor: Theme.palette.primaryColor1
                uploadTextColor: Theme.palette.primaryColor1
                uploadText: qsTr("Drop It!")
            }
        }
        DropArea {
            id: dropArea
            anchors.fill: parent
            enabled: root.isDraggable
            onEntered: {
                root.hasImage = (drag.urls.length > 0);
            }
            onDropped: {
                editor.cropImage(drop.urls[0]);
            }
        }
    }

    EditCroppedImagePanel {
        id: editor
        width: parent.height
        height: width
        anchors.left: root.editorAnchorLeft ? parent.left : undefined
        anchors.horizontalCenter: !root.editorAnchorLeft ? parent.horizontalCenter : undefined
        visible: editor.userSelectedImage || !(root.containsDrag && root.hasImage)
        opacity: visible ? ((root.containsDrag && root.hasImage) ? .4 : 1) : 0
        Behavior on opacity { NumberAnimation { duration: 100 } }
        editButtonVisible: !(root.containsDrag && root.hasImage)

        NoImageUploadedPanel {
            id: textLabel
            width: parent.width
            anchors.centerIn: parent
            visible: !editor.userSelectedImage && !root.dataImage
            additionalTextPixelSize: Theme.secondaryTextFontSize
        }
    }
}
