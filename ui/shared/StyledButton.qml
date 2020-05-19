import QtQuick 2.3
import QtQuick.Controls 1.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQml 2.14



Button {
    property alias label: txtBtnLabel.text
    font.weight: Font.Medium

    id: btnStyled
    rightPadding: 32
    leftPadding: 32
    bottomPadding: 11
    topPadding: 11

    background: Rectangle {
        color: "#ECEFFC"
        radius: 8
    }

    Text {
        id: txtBtnLabel
        color: "#4360DF"
        font.family: "Inter"
        font.pointSize: 15
        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenter: parent.horizontalCenter
        text: "Get started"
    }
}

