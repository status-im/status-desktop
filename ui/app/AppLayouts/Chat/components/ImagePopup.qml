import QtQuick 2.13
import QtQuick.Window 2.2
import "../../../../imports"
import "../../../../shared"
import "./"

ModalPopup {
    id: popup
    width: 500
    height: 500

    function setPopupData(image) {
        messageImage.source = image;
        if (Screen.desktopAvailableWidth <= messageImage.sourceSize.width || Screen.desktopAvailableHeight <= messageImage.sourceSize.height) {
            this.width = Screen.desktopAvailableWidth - 100;
            this.height = Screen.desktopAvailableHeight - 100;
            return;
        }
        this.width = messageImage.sourceSize.width;
        this.height = messageImage.sourceSize.height;
    }

    function openPopup(image) {
        setPopupData(image);
        popup.open();
    }

    Image {
        id: messageImage
        asynchronous: true
        fillMode: Image.PreserveAspectFit
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        height: parent.height - Style.current.padding
        width: parent.width - Style.current.padding
        mipmap: true
        smooth: false
    }
}
