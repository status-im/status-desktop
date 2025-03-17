import QtQuick
import QtQuick.Dialogs
import QtCore

import StatusQ.Core.Utils 0.1

QObject {
    id: root

    property alias title: dlg.title
    property alias nameFilters: dlg.nameFilters
    property alias selectedFile: dlg.selectedFile
    property alias selectedFiles: dlg.selectedFiles
    property bool selectMultiple

    property alias modality: dlg.modality
    property alias currentFolder: dlg.currentFolder

    property string picturesShortcut: StandardPaths.writableLocation(StandardPaths.PicturesLocation)

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

        fileMode: selectMultiple ? FileDialog.OpenFiles : FileDialog.OpenFile

        onAccepted: root.accepted()
        onRejected: root.rejected()
    }
}
