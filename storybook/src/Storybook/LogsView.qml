import QtQuick 2.14

import StatusQ.Core.Theme 0.1

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
        font.family: Theme.palette.monoFont.name
        font.letterSpacing: 1.2
        readOnly: true
        selectByMouse: true
    }
}
