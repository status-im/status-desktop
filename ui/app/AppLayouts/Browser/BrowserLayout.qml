import QtQuick 2.3
import QtQuick.Controls 1.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.1
import QtWebView 1.14
import "../../../imports"
import "../../../shared"

Item {
    id: browserView
    x: 0
    y: 0
    Layout.fillHeight: true
    Layout.fillWidth: true

    WebView {
        id: browserContainer
        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        url: "https://dap.ps/"
  }
}
