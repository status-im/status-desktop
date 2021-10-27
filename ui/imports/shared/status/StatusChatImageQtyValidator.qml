import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.0

import utils 1.0
import ".."

StatusChatImageValidator {
    id: root
    //% "You can only upload %1 images at a time"
    errorMessage: qsTrId("you-can-only-upload--1-images-at-a-time").arg(Constants.maxUploadFiles)

    onImagesChanged: {
        root.isValid = images.length <= Constants.maxUploadFiles
        root.validImages = images.slice(0, Constants.maxUploadFiles)
    }
}
