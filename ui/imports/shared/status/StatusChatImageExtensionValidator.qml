import QtQuick 2.15

import utils 1.0

StatusChatImageValidator {
    id: root

    errorMessage: qsTr("Format not supported.")
    secondaryErrorMessage: qsTr("Upload %1 only").arg(Constants.acceptedDragNDropImageExtensions.map(ext => ext.replace(".", "").toUpperCase() + "s").join(", "))

    onImagesChanged: {
        let isValid = true
        root.validImages = images.filter(img => {
            const isImage = Utils.isValidDragNDropImage(img)
            isValid = isValid && isImage
            return isImage
        })
        root.isValid = isValid
    }
}
