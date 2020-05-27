import QtQuick 2.3
import QtQuick.Controls 1.3
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
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

            Item {
                id: itmSlide1

                Image {
                    id: img1
                    anchors.horizontalCenter: parent.horizontalCenter
                    sourceSize.width: 414
                    sourceSize.height: 414
                    anchors.topMargin: 17
                    fillMode: Image.PreserveAspectFit
                    source: "img/chat@2x.jpg"
                }

                Text {
                    id: txtTitle1
                    text: qsTr("Truly private communication")
                    anchors.right: parent.right
                    anchors.rightMargin: 177
                    anchors.left: parent.left
                    anchors.leftMargin: 177
                    anchors.top: img1.bottom
                    anchors.topMargin: 44
                    font.letterSpacing: -0.2
                    font.weight: Font.Bold
                    lineHeight: 1
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    transformOrigin: Item.Center
                    font.bold: true
                    font.pixelSize: 22
                    font.kerning: true

                }

                Text {
                    id: txtDesc1
                    x: 772
                    color: "#939BA1"
                    text: qsTr("Chat over a peer-to-peer, encrypted network\n where messages can't be censored or hacked")
                    font.weight: Font.Normal
                    style: Text.Normal
                    anchors.horizontalCenterOffset: 0
                    anchors.top: txtTitle1.bottom
                    anchors.topMargin: 14
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: 15
                }

                Button {
                    id: btnNext1
                    width: 40
                    height: 40
                    anchors.top: txtDesc1.top
                    anchors.bottomMargin: -2
                    anchors.bottom: txtDesc1.bottom
                    anchors.topMargin: -2
                    anchors.left: txtDesc1.right
                    anchors.leftMargin: 32
                    onClicked: vwOnboarding.currentIndex++
                    background: Rectangle {
                        id: rctNext1
                        color: "#ECEFFC"
                        border.width: 0
                        radius: 50

                        Image {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            source: "img/next.svg"
                        }
                    }
                }
            }
            Item {
                id: itmSlide2

                Image {
                    id: img2
                    anchors.horizontalCenter: parent.horizontalCenter
                    sourceSize.width: 414
                    sourceSize.height: 414
                    anchors.top: parent.top
                    anchors.topMargin: 17
                    fillMode: Image.PreserveAspectFit
                    source: "img/wallet@2x.jpg"
                }

                Text {
                    id: txtTitle2
                    text: qsTr("Secure crypto wallet")
                    anchors.right: parent.right
                    anchors.rightMargin: 177
                    anchors.left: parent.left
                    anchors.leftMargin: 177
                    anchors.top: img2.bottom
                    anchors.topMargin: 44
                    font.letterSpacing: -0.2
                    font.weight: Font.Bold
                    lineHeight: 1
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    transformOrigin: Item.Center
                    font.bold: true
                    font.pixelSize: 22
                    font.kerning: true

                }

                Button {
                    id: btnPrev2
                    width: 40
                    height: 40
                    anchors.top: txtDesc2.top
                    anchors.bottomMargin: -2
                    anchors.bottom: txtDesc2.bottom
                    anchors.topMargin: -2
                    anchors.right: txtDesc2.left
                    anchors.rightMargin: 32
                    onClicked: vwOnboarding.currentIndex--
                    background: Rectangle {
                        id: rctPrev2
                        color: "#ECEFFC"
                        border.width: 0
                        radius: 50

                        Image {
                            rotation: 180
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            source: "img/next.svg"
                        }
                    }
                }

                Text {
                    id: txtDesc2
                    x: 772
                    color: "#939BA1"
                    text: qsTr("Send and receive digital assets anywhere in the\nworld--no bank account required")
                    font.weight: Font.Normal
                    style: Text.Normal
                    anchors.horizontalCenterOffset: 0
                    anchors.top: txtTitle2.bottom
                    anchors.topMargin: 14
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: 15
                }

                Button {
                    id: btnNext2
                    width: 40
                    height: 40
                    anchors.top: txtDesc2.top
                    anchors.bottomMargin: -2
                    anchors.bottom: txtDesc2.bottom
                    anchors.topMargin: -2
                    anchors.left: txtDesc2.right
                    anchors.leftMargin: 32
                    onClicked: vwOnboarding.currentIndex++
                    background: Rectangle {
                        id: rctNext2
                        color: "#ECEFFC"
                        border.width: 0
                        radius: 50

                        Image {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            source: "img/next.svg"
                        }
                    }
                }
            }
            Item {
                id: itmSlide3

                Image {
                    id: img3
                    anchors.horizontalCenter: parent.horizontalCenter
                    sourceSize.width: 414
                    sourceSize.height: 414
                    anchors.topMargin: 17
                    fillMode: Image.PreserveAspectFit
                    source: "img/browser@2x.jpg"
                }

                Text {
                    id: txtTitle3
                    text: qsTr("Decentralized apps")
                    anchors.right: parent.right
                    anchors.rightMargin: 177
                    anchors.left: parent.left
                    anchors.leftMargin: 177
                    anchors.top: img3.bottom
                    anchors.topMargin: 44
                    font.letterSpacing: -0.2
                    font.weight: Font.Bold
                    lineHeight: 1
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    transformOrigin: Item.Center
                    font.bold: true
                    font.pixelSize: 22
                    font.kerning: true

                }

                Button {
                    id: btnPrev3
                    width: 40
                    height: 40
                    anchors.top: txtDesc3.top
                    anchors.bottomMargin: -2
                    anchors.bottom: txtDesc3.bottom
                    anchors.topMargin: -2
                    anchors.right: txtDesc3.left
                    anchors.rightMargin: 32
                    onClicked: vwOnboarding.currentIndex--
                    background: Rectangle {
                        id: rctPrev3
                        color: "#ECEFFC"
                        border.width: 0
                        radius: 50

                        Image {
                            rotation: 180
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            source: "img/next.svg"
                        }
                    }
                }

                Text {
                    id: txtDesc3
                    x: 772
                    color: "#939BA1"
                    text: qsTr("Explore games, exchanges and social networks\nwhere you alone own your data")
                    font.weight: Font.Normal
                    style: Text.Normal
                    anchors.horizontalCenterOffset: 0
                    anchors.top: txtTitle3.bottom
                    anchors.topMargin: 14
                    font.bold: true
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.pixelSize: 15
                }
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
//            onClicked: app.visible = true
            width: 146
            height: 44
        }

        Text {
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
