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
        delegate: DownloadElement {
            width: parent.width
        }
    }

    Text {
        visible: !listView.count
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        font.pixelSize: 15
        //% "Downloaded files will appear here."
        text: qsTrId("downloaded-files-will-appear-here-")
        color: Style.current.secondaryText
    }
}
