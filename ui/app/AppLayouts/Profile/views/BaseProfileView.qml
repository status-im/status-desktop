import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

ScrollView {
    id: root

    property real defaultMargin: 24 // TODO: to Style.current

    property real profileContentWidth

    default property alias columnContent: column.children

    clip: true
    contentHeight: rootItem.height

    Layout.fillHeight: true
    Layout.fillWidth: true

    Item {
        id: rootItem
        anchors.horizontalCenter: parent.horizontalCenter
        width: profileContentWidth
        height: this.childrenRect.height

        ColumnLayout {
            id: column
            anchors.fill: parent
            anchors.margins: defaultMargin
            spacing: 20 // TODO: to Style.current
        }
    }
}
