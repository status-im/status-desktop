import QtQuick

import utils

StatusChatImageValidator {
    id: root

    onImagesChanged: {
        let isValid = true
        root.validImages = images.filter(img => {
            const isSmallEnough = Utils.isFilesizeValid(img)
            isValid = isValid && isSmallEnough
            return isSmallEnough
        })
        root.isValid = isValid
    }
    errorMessage: qsTr("Max image size is %1 MB").arg(Constants.maxUploadFilesizeMB)
}
