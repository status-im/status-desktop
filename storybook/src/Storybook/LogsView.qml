import QtQuick

Flickable {
    id: root

    contentWidth: logTextEdit.implicitWidth
    contentHeight: logTextEdit.implicitHeight

    property alias logText: logTextEdit.text

    onLogTextChanged: {
        if(logTextEdit.implicitHeight > root.height)
            root.contentY = logTextEdit.implicitHeight - root.height
    }

    TextEdit {
        id: logTextEdit
        width: root.width
        wrapMode: TextEdit.Wrap
        font.family: "courier"
        font.letterSpacing: 1.2
        readOnly: true
        selectByMouse: true
    }
}
