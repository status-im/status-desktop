import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import StatusQ.Core
import StatusQ.Controls
import StatusQ.Core.Theme

Control {
    id: root

    property alias primaryText: primaryText.text
    property alias secondaryText: secondaryText.text
    property alias primaryLabel: primaryText
    property alias secondaryLabel: secondaryText

    property bool isLoading: false

    padding: Theme.halfPadding

    background: Rectangle {
        radius: Theme.radius
        border.width: 1
        border.color: Theme.palette.baseColor2
        color: Theme.palette.transparent
    }

    contentItem: ColumnLayout {
        spacing: 0
        anchors.centerIn: parent

        StatusBaseText {
            id: primaryText

            Layout.fillWidth: true

            font.pixelSize: Theme.additionalTextSize
            color: Theme.palette.directColor5
            visible: text
            elide: Text.ElideRight
        }

        StatusTextWithLoadingState {
            id: secondaryText

            Layout.fillWidth: true

            font.pixelSize: Theme.primaryTextFontSize
            customColor: Theme.palette.directColor1
            visible: text
            elide: Text.ElideRight
            loading: root.isLoading
        }
    }
}
