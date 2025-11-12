import QtQuick

QtObject {
    id: root

    signal allItemsOpened()

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
        // if all items are opened, stop diplaying the bar
        if(root.downloadModel.count === 0) {
            root.allItemsOpened()
        }
    }
    // TODO check if this works in Windows and Mac
    function openDirectory(index) {
        Qt.openUrlExternally("file://" + downloadModel.downloads[index].downloadDirectory)
    }
}
