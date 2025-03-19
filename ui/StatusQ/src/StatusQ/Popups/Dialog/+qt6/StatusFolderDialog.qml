import QtQuick
import QtQuick.Dialogs

import StatusQ.Core.Utils 0.1

QObject {

    id: root

    property alias title: dlg.title
    property alias selectedFolder: dlg.selectedFolder
    property alias modality: dlg.modality
    property alias currentFolder: dlg.currentFolder

    signal accepted
    signal rejected

    function open() {
        dlg.open()
    }

    function close() {
        dlg.close()
    }

    FolderDialog {
        id: dlg

        onAccepted: root.accepted()
        onRejected: root.rejected()
    }
}
