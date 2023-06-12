import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

ToolBar {
    id: root

    property string componentName

    property int figmaPagesCount: 0

    signal figmaPreviewClicked
    signal inspectClicked

    RowLayout {
        anchors.fill: parent

        Item {
            Layout.fillWidth: true
        }

        TextField {
            text: `pages/${root.componentName}Page.qml`
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter

            selectByMouse: true
            readOnly: true
            background: null
        }

        ToolButton {
            text: "📋"

            ToolTip.timeout: 2000
            ToolTip.text: "Component name copied to the clipboard"

            TextInput {
                id: hiddenTextInput
                text: root.componentName
                visible: false
            }

            onClicked: {
                hiddenTextInput.selectAll()
                hiddenTextInput.copy()
                ToolTip.visible = true
            }
        }

        Item {
            Layout.fillWidth: true
        }

        ToolSeparator {}

        ToolButton {
            id: openFigmaButton

            text: `Figma designs (${root.figmaPagesCount})`

            onClicked: root.figmaPreviewClicked()
        }

        ToolSeparator {}

        ToolButton {
            text: "Inspect (Ctrl+Shift+I)"

            Layout.rightMargin: parent.spacing

            onClicked: root.inspectClicked()
        }
    }
}
