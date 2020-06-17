import QtQuick 2.13
import QtQuick.Layouts 1.13
import QtWebView 1.14

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

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
