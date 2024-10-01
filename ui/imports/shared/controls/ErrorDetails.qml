import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

Rectangle {
    id: root

    property string title
    property string details
    readonly property string detailsVisible: d.detailsVisible

    implicitWidth: layout.implicitWidthj
                   + layout.anchors.leftMargin
                   + layout.anchors.rigthMargin

    implicitHeight: layout.implicitHeight
                    + layout.anchors.topMargin
                    + layout.anchors.bottomMargin

    radius: 8
    color: Theme.palette.baseColor4

    QtObject {
        id: d
        property bool detailsVisible: false
    }

    CopyButton {
        width: 20
        height: 20
        visible: d.detailsVisible
        color: Theme.palette.baseColor1
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 8
        anchors.rightMargin: 8
        textToCopy: root.details
    }

    ColumnLayout {
        id: layout

        anchors.fill: parent
        anchors.margins: 10
        spacing: 4

        StatusBaseText {
            Layout.fillWidth: true
            horizontalAlignment: Qt.AlignHCenter
            text: root.title
            font.pixelSize: 13
            font.weight: Font.Medium
        }

        StatusBaseText {
            Layout.fillWidth: true
            horizontalAlignment: Qt.AlignHCenter
            visible: !d.detailsVisible
            text: qsTr("Show error details")
            color: Theme.palette.primaryColor1
            font.pixelSize: 12

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    d.detailsVisible = true
                }
            }
        }

        StatusBaseText {
            Layout.fillWidth: true
            horizontalAlignment: Qt.AlignHCenter
            visible: d.detailsVisible
            text: root.details
            color: Theme.palette.baseColor1
            font.pixelSize: 12
            wrapMode: Text.WordWrap
        }
    }
}
