import QtQuick

import utils

StatusChatImageValidator {
    id: root
    errorMessage: qsTr("You can only upload %n image(s) at a time", "", Constants.maxUploadFiles)

    onImagesChanged: {
        root.isValid = images.length <= Constants.maxUploadFiles
        root.validImages = images.slice(0, Constants.maxUploadFiles)
    }
}
