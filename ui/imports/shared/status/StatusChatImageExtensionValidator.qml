import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.0

import utils 1.0
import ".."

StatusChatImageValidator {
    id: root

    //% "Format not supported."
    errorMessage: qsTrId("format-not-supported-")
    //% "Upload %1 only"
    secondaryErrorMessage: qsTrId("upload--1-only").arg(Constants.acceptedDragNDropImageExtensions.map(ext => ext.replace(".", "").toUpperCase() + "s").join(", "))

    onImagesChanged: {
        let isValid = true
        root.validImages = images.filter(img => {
            const isImage = Utils.hasDragNDropImageExtension(img)
            isValid = isValid && isImage
            return isImage
        })
        root.isValid = isValid
    }
}
