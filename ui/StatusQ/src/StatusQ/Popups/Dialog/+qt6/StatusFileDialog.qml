import QtQuick
import QtQuick.Dialogs
import QtCore

import StatusQ 0.1
import StatusQ.Core.Utils 0.1

import utils 1.0

QObject {
    id: root

    property alias title: dlg.title
    property alias nameFilters: dlg.nameFilters
    readonly property alias selectedFile: d.resolvedFile
    readonly property alias selectedFiles: d.resolvedFiles
    property bool selectMultiple

    property alias modality: dlg.modality
    property alias currentFolder: dlg.currentFolder

    property string picturesShortcut: Constants.isIOS ? Constants.iosPhotoLibraryShortcut :
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
        property url resolvedFile: resolveFile(lg.selectedFile)
        property var resolvedFiles: resolveSelectedFiles(dlg.selectedFiles)

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

            const files = []
            for (let i = 0; i < selectedFiles.length; i++) {
                const file = selectedFiles[i]
                if (!!file) {
                    files.push(d.resolveFile(file))
                }
            }
            return files
        }
    }

    FileDialog {
        id: dlg

        fileMode: selectMultiple ? FileDialog.OpenFiles : FileDialog.OpenFile

        onAccepted: root.accepted()
        onRejected: root.rejected()
    }
}
