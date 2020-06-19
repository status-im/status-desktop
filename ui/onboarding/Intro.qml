import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../shared"

RowLayout {
    property alias btnGetStarted: btnGetStarted

    id: obLayout
    anchors.fill: parent
    Layout.fillWidth: true
    Layout.fillHeight: true

    Rectangle {
        border.width: 0
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        Layout.fillHeight: true
        Layout.fillWidth: true

        SwipeView {
            id: vwOnboarding
            width: parent.width
            height: parent.height
            currentIndex: 0
            interactive: false
            anchors.fill: parent

            Slide {
                image: "img/chat@2x.jpg"
                title: qsTr("Truly private communication")
                description: qsTr("Chat over a peer-to-peer, encrypted network\n where messages can't be censored or hacked")
            }
            Slide {
                image: "img/wallet@2x.jpg"
                title: qsTr("Secure crypto wallet")
                description: qsTr("Send and receive digital assets anywhere in the\nworld--no bank account required")
            }
            Slide {
                image: "img/browser@2x.jpg"
                title: qsTr("Decentralized apps")
                description: qsTr("Explore games, exchanges and social networks\nwhere you alone own your data")
                isLast: true
            }
        }

        Rectangle {
            id: rctPageIndicator
            border.width: 0
            anchors.bottom: vwOnboarding.bottom
            anchors.bottomMargin: 191
            anchors.top: vwOnboarding.top
            anchors.topMargin: 567
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width

            PageIndicator {
                id: pgOnboarding
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 5
                padding: 0
                topPadding: 0
                bottomPadding: 0
                rightPadding: 0
                leftPadding: 0
                font.pixelSize: 6
                count: vwOnboarding.count
                currentIndex: vwOnboarding.currentIndex
            }
        }

        StyledButton {
            id: btnGetStarted
            label: "Get started"
            anchors.top: rctPageIndicator.bottom
            anchors.topMargin: 87
            anchors.horizontalCenter: parent.horizontalCenter
            width: 146
            height: 44
        }

        StyledText {
            id: txtPrivacyPolicy
            x: 772
            text: qsTr("Status does not collect, share or sell any personal data. By continuing you agree with the privacy policy.")
            anchors.top: btnGetStarted.bottom
            anchors.topMargin: 17
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 12
            font.letterSpacing: 0.1
            color: "#939BA1"
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:770;width:1232}
}
##^##*/
