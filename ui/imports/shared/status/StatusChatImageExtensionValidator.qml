import QtQuick

import StatusQ

import utils

StatusChatImageValidator {
    id: root

    errorMessage: !!lastFailedImgPath ? qsTr("Format not supported. File: %1").arg(lastFailedImgPath) : qsTr("Format not supported.")
    secondaryErrorMessage: qsTr("Upload %1 only").arg(UrlUtils.validPreferredImageExtensions.map(ext => ext.toUpperCase() + "s").join(", "))

    property string lastFailedImgPath

    onImagesChanged: {
        let isValid = true
        root.validImages = images.filter(img => {
            const isImage = Utils.isValidDragNDropImage(img)
            if (!isImage)
                root.lastFailedImgPath = img
            else
                root.lastFailedImgPath = ""
            isValid = isValid && isImage
            return isImage
        })
        root.isValid = isValid
    }
}
