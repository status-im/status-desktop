import QtQuick 2.12
import QtQuick.Controls 2.3
import "../../../../imports"
import "../../../../shared"

ModalPopup {
    id: popup
    //% "Get Status at https://status.im"
    readonly property string getStatusText: qsTrId("get-status-at-https---status-im")

    //% "Download Status link"
    title: qsTrId("download-status-link")
    height: 156

    StyledText {
        id: linkText
        text: popup.getStatusText
    }

    CopyToClipBoardButton {
        anchors.left: linkText.right
        anchors.leftMargin: Style.current.smallPadding
        anchors.verticalCenter: linkText.verticalCenter
        textToCopy: popup.getStatusText.substr(popup.getStatusText.indexOf("https"))
    }
}

