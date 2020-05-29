import QtQuick 2.3
import QtQuick.Controls 1.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQml 2.14
import "../imports"

Button {
    property string label: "My button"

    id: btnStyled
    width: txtBtnLabel.width + 2 * Theme.padding
    height: 44

    background: Rectangle {
        color: "#ECEFFC"
        radius: 8
        anchors.fill: parent
    }

    Text {
        id: txtBtnLabel
        color: Theme.blue
        font.pointSize: 15
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        text: label
        font.weight: Font.Medium
    }
}

