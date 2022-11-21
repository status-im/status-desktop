import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

ToolBar {
    id: root

    property string title
    property int figmaPagesCount: 0

    signal figmaPreviewClicked

    RowLayout {
        anchors.fill: parent

        TextField {
            Layout.fillWidth: true

            text: root.title
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter

            selectByMouse: true
            readOnly: true
            background: null
        }

        ToolSeparator {}

        ToolButton {
            id: openFigmaButton

            enabled: root.figmaPagesCount
            text: `Figma designs (${root.figmaPagesCount})`

            onClicked: root.figmaPreviewClicked()
        }
    }
}
