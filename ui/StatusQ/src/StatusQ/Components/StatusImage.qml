import QtQuick 2.13
Image {
    id: root

    readonly property bool isLoading: status === Image.Loading
    readonly property bool isError: status === Image.Error

    fillMode: Image.PreserveAspectFit

    onSourceChanged: {
        if (sourceSize.width < width || sourceSize.height < height) {
            sourceSize = Qt.binding(function() {
                return Qt.size(width * 2, height * 2)
            })
        }
        else {
            sourceSize = undefined
        }
    }
}
