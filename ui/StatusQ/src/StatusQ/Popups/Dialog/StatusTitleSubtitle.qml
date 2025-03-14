import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

Item {
    id: root

    property alias title: title.text
    property alias subtitle: subtitle.text

    implicitHeight: layout.implicitHeight
    implicitWidth: layout.implicitWidth

    ColumnLayout {
        id: layout

        anchors.fill: parent
        spacing: 0

        StatusBaseText {
            id: title

            Layout.fillWidth: true

            font {
                pixelSize: Theme.secondaryAdditionalTextSize
                bold: true
            }
            elide: Text.ElideMiddle
        }

        StatusBaseText {
            id: subtitle

            Layout.fillWidth: true

            visible: text !== ""
            color: Theme.palette.baseColor1
            elide: Text.ElideMiddle
        }
    }
}
