import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../shared"
import "../imports"

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
                isFirst: true
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

        StyledText {
            id: warningMessage
            x: 772
            text: qsTr("Thanks for trying Status Desktop! Please note that this is an alpha release and we advise you that using this app should be done for testing purposes only and you assume the full responsibility for all risks concerning your data and funds. Status makes no claims of security or integrity of funds in these builds.")
            font.bold: true
            anchors.top: rctPageIndicator.bottom
            anchors.topMargin: 5
            anchors.horizontalCenter: parent.horizontalCenter
            font.pixelSize: 14
            font.letterSpacing: 0.1
            width: 700
            wrapMode: Text.Wrap
            color: Theme.black
        }

        CheckBox {
            id: warningCheckBox
            anchors.top: warningMessage.bottom
            anchors.topMargin: 0
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("I understand")
        }

        StyledButton {
            id: btnGetStarted
            enabled: warningCheckBox.checked
            btnColor: this.enabled ? Theme.lightBlue : "lightgrey"
            label: "Get Started"
            anchors.top: warningCheckBox.bottom
            anchors.topMargin: 5
            anchors.horizontalCenter: parent.horizontalCenter
            width: 146
            height: 44
        }

        StyledText {
            id: txtPrivacyPolicy
            x: 772
            text: qsTr("Status does not collect, share or sell any personal data. By continuing you agree with the privacy policy.")
            anchors.top: btnGetStarted.bottom
            anchors.topMargin: 8
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
