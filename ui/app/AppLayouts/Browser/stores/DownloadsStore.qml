pragma Singleton

import QtQuick 2.13

QtObject {
    id: root

    property ListModel downloadModel : ListModel {
        property var downloads: []
    }

    function getDownload(index) {
        return downloadModel.downloads[index]
    }

    function removeDownloadFromModel(index) {
        downloadModel.downloads = downloadModel.downloads.filter(function (el) {
            return el.id !== downloadModel.downloads[index].id;
        });
        downloadModel.remove(index);
    }

    function addDownload(download) {
        downloadModel.append(download);
        downloadModel.downloads.push(download);
    }

    function openFile(index) {
        Qt.openUrlExternally(`file://${downloadModel.downloads[index].downloadDirectory}/${downloadModel.downloads[index].downloadFileName}`)
        root.removeDownloadFromModel(index)
    }
    // TODO check if this works in Windows and Mac
    function openDirectory(index) {
        Qt.openUrlExternally("file://" + downloadModel.downloads[index].downloadDirectory)
    }
}
