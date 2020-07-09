import QtQuick 2.12
import QtQuick.Controls 2.3
import "../../../../imports"
import "../../../../shared"

ModalPopup {
    id: popup
    readonly property string getStatusText: qsTr("Get Status at https://status.im")

    title: qsTr("Download Status link")
    height: 156

    StyledText {
        id: linkText
        text: popup.getStatusText
    }

    CopyToClipBoardButton {
        anchors.left: linkText.right
        anchors.leftMargin: Style.current.smallPadding
        anchors.verticalCenter: linkText.verticalCenter
        textToCopy: popup.getStatusText
    }
}

