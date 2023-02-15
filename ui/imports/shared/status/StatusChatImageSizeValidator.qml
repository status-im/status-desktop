import QtQuick 2.13

import utils 1.0

StatusChatImageValidator {
    id: root
    readonly property int maxImgSizeBytes: Constants.maxUploadFilesizeMB * 1048576 /* 1 MB in bytes */

    onImagesChanged: {
        let isValid = true
        root.validImages = images.filter(img => {
            let size = parseInt(globalUtils.getFileSize(img))
            const isSmallEnough = size <= maxImgSizeBytes
            isValid = isValid && isSmallEnough
            return isSmallEnough
        })
        root.isValid = isValid
    }
    errorMessage: qsTr("Max image size is %1 MB").arg(Constants.maxUploadFilesizeMB)
}
