import QtQuick
import QtQuick.Dialogs
import QtCore

import StatusQ
import StatusQ.Core.Utils

QObject {
    id: root

    property alias title: dlg.title
    property alias nameFilters: dlg.nameFilters
    readonly property alias selectedFile: d.resolvedFile
    readonly property alias selectedFiles: d.resolvedFiles
    property bool selectMultiple

    property alias modality: dlg.modality
    property alias currentFolder: dlg.currentFolder

    property string picturesShortcut: Utils.isIOS ? "assets-library://" :
                            StandardPaths.writableLocation(StandardPaths.PicturesLocation)

    signal accepted
    signal rejected

    function open() {
        dlg.open()
    }

    function close() {
        dlg.close()
    }

    QtObject {
        id: d
        readonly property url resolvedFile: resolveFile(dlg.selectedFile)
        readonly property var resolvedFiles: resolveSelectedFiles(dlg.selectedFiles)

        function resolveFile(file) {
            if (!file)
                return ""

            let resolvedLocalFile = UrlUtils.convertUrlToLocalPath(file)
            if (!resolvedLocalFile.startsWith("file:"))
                resolvedLocalFile = "file:" + resolvedLocalFile
            return resolvedLocalFile
        }
        function resolveSelectedFiles(selectedFiles) {
            if (selectedFiles.length === 0)
                return []

            return selectedFiles.map(file => d.resolveFile(file)).filter(file => !!file)
        }
    }

    FileDialog {
        id: dlg

        fileMode: selectMultiple ? FileDialog.OpenFiles : FileDialog.OpenFile

        onAccepted: root.accepted()
        onRejected: root.rejected()
    }
}
