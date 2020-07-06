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
        //% "About the app"
        text: qsTrId("about-the-app")
        anchors.left: parent.left
        anchors.leftMargin: 24
        anchors.top: parent.top
        anchors.topMargin: 24
        font.weight: Font.Bold
        font.pixelSize: 20
    }

    StyledText {
        id: element10
        //% "Status Desktop"
        text: qsTrId("status-desktop")
        anchors.left: parent.left
        anchors.leftMargin: 24
        anchors.top: element9.top
        anchors.topMargin: 58
        font.weight: Font.Bold
        font.pixelSize: 14
    }
    StyledText {
        id: element11
        //% "Version: alpha.0"
        text: qsTrId("version:-alpha.0")
        anchors.left: parent.left
        anchors.leftMargin: 24
        anchors.top: element10.top
        anchors.topMargin: 58
        font.weight: Font.Bold
        font.pixelSize: 14
    }
    StyledText {
        id: element12
        //% "Node Version: %1"
        text: qsTrId("node-version:-%1").arg(profileModel.nodeVersion())
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
        id: faqLink
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
    StyledText {
        id: warningMessage
        x: 772
        //% "Thanks for trying Status Desktop! Please note that this is an alpha release and we advise you that using this app should be done for testing purposes only and you assume the full responsibility for all risks concerning your data and funds. Status makes no claims of security or integrity of funds in these builds."
        text: qsTrId("thanks-for-trying-status-desktop!-please-note-that-this-is-an-alpha-release-and-we-advise-you-that-using-this-app-should-be-done-for-testing-purposes-only-and-you-assume-the-full-responsibility-for-all-risks-concerning-your-data-and-funds.-status-makes-no-claims-of-security-or-integrity-of-funds-in-these-builds.")
        font.bold: true
        anchors.top: faqLink.bottom
        anchors.topMargin: 30
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: 14
        font.letterSpacing: 0.1
        width: 700
        wrapMode: Text.Wrap
        color: Style.current.black
    }
}

/*##^##
Designer {
    D{i:0;height:600;width:800}
}
##^##*/
