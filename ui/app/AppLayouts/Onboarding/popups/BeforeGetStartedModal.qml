import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.14

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

StatusModal {
    id: popup

    anchors.centerIn: parent
    //% "Before you get started..."
    header.title: qsTrId("before-you-get-started---")
    hasCloseButton: false

    contentItem: Item {
        implicitHeight: childrenRect.height
        width: popup.width
        Column {
            spacing: 12
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 32
            anchors.rightMargin: 32

            Item { height: 12;  width: parent.width }

            StatusCheckBox {
                id: acknowledge
                objectName: "acknowledgeCheckBox"
                width: parent.width
                //% "I acknowledge that Status Desktop is in Beta and by using it, I take the full responsibility for all risks concerning my data and funds."
                text: qsTrId("i-acknowledge-that-status-desktop-is-in-beta-and-by-using-it--i-take-the-full-responsibility-for-all-risks-concerning-my-data-and-funds-")
            }

            StatusCheckBox {
                id: termsOfUse
                objectName: "termsOfUseCheckBox"

                contentItem: Row {
                    spacing: 4
                    leftPadding: termsOfUse.indicator.width + termsOfUse.spacing

                    StatusBaseText {
                        //% "I accept"
                        text: qsTrId("i-accept")
                        color: Theme.palette.directColor1
                    }

                    StatusBaseText {
                        //% "Terms of Use"
                        text: qsTrId("terms-of-service")
                        color: Theme.palette.primaryColor1
                        objectName: "termsOfUseLink"

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onEntered: {
                                parent.font.underline = true
                            }
                            onExited: {
                                parent.font.underline = false
                            }
                            onClicked: {
                                Qt.openUrlExternally("https://status.im/terms-of-service/")
                            }
                        }
                    }
                }
            }

            Item { height: 12;  width: parent.width }
        }
    }

    leftButtons: [
        StatusBaseText {
            id: ppText
            //% "Privacy Policy"
            objectName: "privacyPolicyLink"
            text: qsTrId("privacy-policy")
            color: Theme.palette.primaryColor1
            anchors.verticalCenter: parent.verticalCenter

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onEntered: {
                    parent.font.underline = true
                }
                onExited: {
                    parent.font.underline = false
                }
                onClicked: {
                    Qt.openUrlExternally("https://status.im/privacy-policy/")
                }
            }
        }

    ]

    rightButtons: [
        StatusButton {
            id: getStartedButton
            objectName: "getStartedStatusButton"
            enabled: acknowledge.checked && termsOfUse.checked
            //% "Get Started"
            text: qsTrId("get-started")
            onClicked: {
                popup.close()
            }
        }
    ]
}
