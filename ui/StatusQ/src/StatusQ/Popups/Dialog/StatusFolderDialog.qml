import QtQuick 2.15
import QtQuick.Dialogs 1.3

// Since this is a temporal component, it will be wrapped into this visual item since wrapping the
// FileDialog into a SQUtils.QObject it does not open the dialog in macos
Item {

    id: root

    property alias title: dlg.title
    property alias selectedFolder: dlg.fileUrl
    property alias modality: dlg.modality
    property alias currentFolder: dlg.folder

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

        selectFolder: true
        selectExisting: true
        selectMultiple: false

        onAccepted: root.accepted()
        onRejected: root.rejected()
    }
}
