import QtQuick 2.1
import QtQuick.Controls 1.0
import QtQuick.Controls.Styles 1.0
import QtWebEngine 1.9
import QtQuick.Layouts 1.0
import "../../../shared"
import "../../../shared/status"
import "../../../imports"

Rectangle {
    id: downloadView
    color: Style.current.background

    function append(download) {
        downloadModel.append(download);
        downloadModel.downloads.push(download);
    }

    StatusIconButton {
        id: closeBtn
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.rightMargin: Style.current.padding
        anchors.topMargin: Style.current.padding
        icon.name: "browser/close"
        iconColor: Style.current.textColor
        onClicked: {
            downloadView.visible = false
        }
    }

    ListView {
        id: listView
        anchors {
            topMargin: Style.current.bigPadding
            top: parent.top
            bottom: parent.bottom
            bottomMargin: Style.current.bigPadding * 2
            horizontalCenter: parent.horizontalCenter
        }
        width: 624
        spacing: Style.current.padding

        model: downloadModel
        delegate: Component {
            DownloadElement {
                width: parent.width
            }
        }
    }

    Text {
        visible: !listView.count
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: 15
        text: qsTr("Downloaded files will appear here.")
        color: Style.current.secondaryText
    }

    StatusButton {
        text: qsTr("Close")
        onClicked: {
            downloadView.visible = false;
        }
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Style.current.padding
    }
}
