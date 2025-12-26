import QtQuick
import StatusQ

QtObject {
    id: root

    property ListModel downloadModel : ListModel {
        property var downloads: []
    }

    function getDownload(index) {
        return downloadModel.downloads[index]
    }

    function addDownload(download) {
        downloadModel.append(download);
        downloadModel.downloads.push(download);
    }

    function openFile(index) {
        const filePath = `${downloadModel.downloads[index].downloadDirectory}/${downloadModel.downloads[index].downloadFileName}`
        Qt.openUrlExternally(UrlUtils.urlFromUserInput(filePath))
    }

    function openDirectory(index) {
        const dirPath = downloadModel.downloads[index].downloadDirectory
        Qt.openUrlExternally(UrlUtils.urlFromUserInput(dirPath))
    }
}
