import QtQuick 2.14
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

Button {
    id: root

    property color bgColor: Theme.palette.baseColor2
    property color contentColor: Theme.palette.baseColor1
    property var type: StatusPickerButton.Type.Next
    property int lateralMargins: 16
    property int textPixelSize: 15
    /*!
       \qmlproperty StatusImageSettings StatusPickerButton::image
       This property holds the image settings information.
    */
    property StatusImageSettings image: StatusImageSettings {
        width: 20
        height: 20
        isIdenticon: false
    }

    enum Type {
        Next,
        Down
    }

    implicitWidth: 446
    implicitHeight: 44
    background: Item {
        anchors.fill: parent
        Rectangle {
            id: background
            anchors.fill: parent
            radius: 8
            color: root.bgColor
        }   
    }

    contentItem: Item {
        anchors.fill: parent
        state: root.type === StatusPickerButton.Type.Next ? "NEXT" : "DOWN"

        RowLayout {
            id: rowLabel
            width: parent.width - icon.width - icon.anchors.rightMargin - icon.anchors.leftMargin
            anchors.verticalCenter: parent.verticalCenter
            clip: true
            spacing: 4
            StatusRoundedImage {
                id: rowImage
                Layout.alignment: Qt.AlignVCenter
                visible: root.image.source.toString() !== ""
                Layout.preferredWidth: root.image.width
                Layout.preferredHeight: root.image.height
                image.source: root.image.source
            }
            StatusBaseText {
                id: textLabel
                Layout.alignment: Qt.AlignVCenter
                Layout.fillWidth: true
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: root.textPixelSize
                color: root.contentColor
                text: root.text
                clip: true
                elide: Text.ElideRight
            }
        }
        StatusIcon {
            id: icon
            anchors.verticalCenter: parent.verticalCenter
            color: !Qt.colorEqual(root.contentColor, Theme.palette.baseColor1) ? root.contentColor : Theme.palette.directColor1
        }

        states: [
            State {
                name: "NEXT"
                PropertyChanges {target: icon; icon: "next"}
                PropertyChanges {target: icon; anchors.left: undefined }
                PropertyChanges {target: icon; anchors.right: parent.right }
                PropertyChanges {target: icon; anchors.rightMargin: root.lateralMargins / 2 }
                PropertyChanges {target: icon; anchors.leftMargin: root.lateralMargins / 2 }
                PropertyChanges {target: rowLabel; anchors.left: parent.left }
                PropertyChanges {target: rowLabel; anchors.right: undefined }
                PropertyChanges {target: rowLabel; anchors.rightMargin: undefined }
                PropertyChanges {target: rowLabel; anchors.leftMargin: root.lateralMargins }
            },
            State {
                name: "DOWN"
                PropertyChanges {target: icon; icon: "chevron-down"}
                PropertyChanges {target: icon; anchors.left: parent.left }
                PropertyChanges {target: icon; anchors.right: undefined }
                PropertyChanges {target: icon; anchors.rightMargin: root.lateralMargins / 2 }
                PropertyChanges {target: icon; anchors.leftMargin: root.lateralMargins }
                PropertyChanges {target: rowLabel; anchors.left: icon.right }
                PropertyChanges {target: rowLabel; anchors.right: undefined }
                PropertyChanges {target: rowLabel; anchors.rightMargin: root.lateralMargins / 2 }
                PropertyChanges {target: rowLabel; anchors.leftMargin: undefined }
            }
        ]
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: { root.clicked() }
    }
}
