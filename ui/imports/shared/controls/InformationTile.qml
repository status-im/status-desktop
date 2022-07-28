import QtQuick 2.13
import QtQuick.Layouts 1.13
import QtQuick.Controls 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

Rectangle {
    id: root

    property alias primaryText: primaryText.text
    property alias secondaryText: secondaryText.text
    property alias tagsModel: tags.model
    property alias tagsDelegate: tags.delegate
    property int maxWidth: 0

    implicitHeight: 52
    implicitWidth: layout.width + Style.current.xlPadding
    radius: Style.current.radius
    border.width: 1
    border.color: Theme.palette.baseColor2
    color: Style.current.transparent

    ColumnLayout {
        id: layout
        spacing: 0
        anchors.centerIn: parent
        StatusBaseText {
            id: primaryText
            Layout.maximumWidth: root.maxWidth - Style.current.xlPadding
            font.pixelSize: 13
            color: Theme.palette.directColor5
            visible: text
            elide: Text.ElideRight
        }
        StatusBaseText {
            id: secondaryText
            Layout.maximumWidth: root.maxWidth - Style.current.xlPadding
            font.pixelSize: 15
            color: Theme.palette.directColor1
            visible: text
            elide: Text.ElideRight
        }
        ScrollView {
            Layout.preferredHeight: 24
            Layout.maximumWidth: root.maxWidth - Style.current.xlPadding
            clip: true
            visible: tags.count > 0
            ListView {
                id: tags
                orientation: ListView.Horizontal
                spacing: 10
            }
        }
    }
}
