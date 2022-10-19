import QtQuick 2.14
import QtQuick.Controls 2.14

GroupBox {
    id: root

    title: "source code"

    property string sourceCode
    property bool hasErrors: false

    ScrollView {
        id: scrollView

        anchors.fill: parent
        clip: true

        implicitHeight: 0
        implicitWidth: 0

        contentHeight: sourceTextEdit.implicitHeight
        contentWidth: scrollView.width

        TextEdit {
            id: sourceTextEdit

            width: scrollView.width
            font.family: "courier"
            text: StorybookUtils.formatQmlCode(root.sourceCode)
            color: root.hasErrors ? "darkred" : "black"
            selectByMouse: true
            wrapMode: Text.Wrap

            onTextChanged: root.sourceCode = text
        }
    }
}
