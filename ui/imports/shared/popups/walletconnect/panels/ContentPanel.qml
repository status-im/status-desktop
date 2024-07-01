import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

Rectangle {
    id: root

    property alias payloadToDisplay: contentText.text

    border.width: 1
    border.color: Theme.palette.baseColor2
    color: "transparent"
    radius: 8

    implicitHeight: contentScrollView.implicitHeight + (2 * contentText.anchors.margins)

    MouseArea {
        anchors.fill: parent
        cursorShape: contentScrollView.enabled || !enabled ? undefined : Qt.PointingHandCursor
        enabled: contentScrollView.height < contentScrollView.contentHeight

        onClicked: {
            contentScrollView.enabled = !contentScrollView.enabled
        }
        z: contentScrollView.z + 1
    }

    StatusScrollView {
        id: contentScrollView
        anchors.fill: parent

        contentWidth: availableWidth
        contentHeight: contentText.contentHeight

        padding: 0

        enabled: false

        StatusBaseText {
            id: contentText
            anchors.fill: parent
            anchors.margins: 20

            width: contentScrollView.availableWidth

            text: root.payloadToDisplay

            wrapMode: Text.WrapAnywhere
        }
    }
}
