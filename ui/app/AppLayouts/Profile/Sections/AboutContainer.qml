import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../imports"
import "../../../../shared"

Item {
    id: aboutContainer
    width: 200
    height: 200
    Layout.fillHeight: true
    Layout.fillWidth: true

    StyledText {
        id: element9
        text: qsTr("About the app")
        anchors.left: parent.left
        anchors.leftMargin: 24
        anchors.top: parent.top
        anchors.topMargin: 24
        font.weight: Font.Bold
        font.pixelSize: 20
    }

    StyledText {
        id: element10
        text: qsTr("Status Desktop")
        anchors.left: parent.left
        anchors.leftMargin: 24
        anchors.top: element9.top
        anchors.topMargin: 58
        font.weight: Font.Bold
        font.pixelSize: 14
    }
    StyledText {
        id: element11
        text: qsTr("Version: 1.0")
        anchors.left: parent.left
        anchors.leftMargin: 24
        anchors.top: element10.top
        anchors.topMargin: 58
        font.weight: Font.Bold
        font.pixelSize: 14
    }
    StyledText {
        id: element12
        text: qsTr("Node Version: %1").arg(profileModel.nodeVersion())
        anchors.left: parent.left
        anchors.leftMargin: 24
        anchors.top: element11.top
        anchors.topMargin: 58
        font.weight: Font.Bold
        font.pixelSize: 14
    }
    StyledText {
        id: privacyPolicyLink
        text: "<a href='https://www.iubenda.com/privacy-policy/45710059'>Privacy Policy</a>"
        anchors.left: parent.left
        anchors.leftMargin: 24
        anchors.top: element12.top
        anchors.topMargin: 58
        onLinkActivated: Qt.openUrlExternally(link)

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton // we don't want to eat clicks on the Text
            cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
        }
    }
    StyledText {
        text: "<a href='https://status.im/docs/FAQs.html'>Frequently asked questions</a>"
        anchors.left: parent.left
        anchors.leftMargin: 24
        anchors.top: privacyPolicyLink.top
        anchors.topMargin: 58
        onLinkActivated: Qt.openUrlExternally(link)

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton // we don't want to eat clicks on the Text
            cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
        }
    }
}

/*##^##
Designer {
    D{i:0;height:600;width:800}
}
##^##*/
