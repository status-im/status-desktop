import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.14

import utils 1.0

import StatusQ.Controls 0.1

import "../../../../shared/popups"
import "../../../../shared/panels"

// TODO: replace with StatusModal
ModalPopup {
    id: popup

    displayCloseButton: false
    //% "Before you get started..."
    title: qsTrId("before-you-get-started---")
    width: 430
    height: 300

    ColumnLayout {
        anchors.centerIn: parent
        width: parent.width

        StatusCheckBox {
            id: acknowledge
            objectName: "acknowledgeCheckBox"
            Layout.preferredWidth: parent.width
            //% "I acknowledge that Status Desktop is in Beta and by using it, I take the full responsibility for all risks concerning my data and funds."
            text: qsTrId("i-acknowledge-that-status-desktop-is-in-beta-and-by-using-it--i-take-the-full-responsibility-for-all-risks-concerning-my-data-and-funds-")
        }

        StatusCheckBox {
            id: termsOfUse
            objectName: "termsOfUseCheckBox"
            Layout.preferredWidth: parent.width

            contentItem: Row {
                spacing: 4
                leftPadding: termsOfUse.indicator.width + termsOfUse.spacing

                StyledText {
                    //% "I accept"
                    text: qsTrId("i-accept")
                }

                StyledText {
                    //% "Terms of Use"
                    text: qsTrId("terms-of-service")
                    color: Style.current.blue
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
    }

    footer: Item {
        width: parent.width
        implicitHeight: getStartedButton.height > ppText.height?
                            getStartedButton.height : ppText.height

        StyledText {
            id: ppText
            //% "Privacy Policy"
            objectName: "privacyPolicyLink"
            text: qsTrId("privacy-policy")
            color: Style.current.blue
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left

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

        StatusButton {
            id: getStartedButton
            objectName: "getStartedStatusButton"
            anchors.right: parent.right
            enabled: acknowledge.checked && termsOfUse.checked
            width: 146
            height: 44
            //% "Get Started"
            text: qsTrId("get-started")

            onClicked: {
                popup.close()
            }
        }
    }
}
