import QtQuick 2.15

import utils 1.0

StatusChatImageValidator {
    id: root
    errorMessage: qsTr("You can only upload %n image(s) at a time", "", Constants.maxUploadFiles)

    onImagesChanged: {
        root.isValid = images.length <= Constants.maxUploadFiles
        root.validImages = images.slice(0, Constants.maxUploadFiles)
    }
}
