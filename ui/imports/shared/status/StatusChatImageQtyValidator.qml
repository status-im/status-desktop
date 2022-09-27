import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.0

import utils 1.0
import ".."

StatusChatImageValidator {
    id: root
    errorMessage: qsTr("You can only upload %n image(s) at a time", "", Constants.maxUploadFiles)

    onImagesChanged: {
        root.isValid = images.length <= Constants.maxUploadFiles
        root.validImages = images.slice(0, Constants.maxUploadFiles)
    }
}
