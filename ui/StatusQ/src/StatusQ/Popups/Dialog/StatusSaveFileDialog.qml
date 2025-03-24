import QtQuick 2.15
import Qt.labs.platform 1.1

// Since this is a temporal component, it will be wrapped into this visual item since wrapping the
// FileDialog into a SQUtils.QObject it does not open the dialog in macos
Item {
    id: root

    property alias title: dlg.title
    property alias selectedFile: dlg.currentFile
    property alias acceptLabel: dlg.acceptLabel
    property alias defaultSuffix: dlg.defaultSuffix

    readonly property string picturesShortcut: StandardPaths.writableLocation(StandardPaths.PicturesLocation)
    readonly property string documentsLocation: StandardPaths.writableLocation(StandardPaths.DocumentsLocation)

    signal accepted
    signal rejected

    function open() {
        dlg.open()
    }

    function close() {
        dlg.close()
    }

    FileDialog {
        id: dlg

        fileMode: FileDialog.SaveFile

        onAccepted: root.accepted()
        onRejected: root.rejected()
    }
}
