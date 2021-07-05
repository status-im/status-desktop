import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.14

import "../imports"
import "../shared"
import "../shared/status"

ModalPopup {
    id: popup
    displayCloseButton: false
    title: qsTr("Before you get started...")
    width: 430
    height: 300

    ColumnLayout {
        anchors.centerIn: parent
        width: parent.width

        StatusCheckBox {
            id: acknowledge
            Layout.preferredWidth: parent.width
            text: qsTr("I acknowledge that Status Desktop is in Beta and by using it, I take the full responsibility for all risks concerning my data and funds.")
        }

        StatusCheckBox {
            id: termsOfUse
            Layout.preferredWidth: parent.width

            contentItem: Row {
                spacing: 4
                leftPadding: termsOfUse.indicator.width + termsOfUse.spacing

                StyledText {
                    text: qsTr("I accept")
                }

                StyledText {
                    text: qsTr("Terms of Use")
                    color: Style.current.blue

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
            text: qsTr("Privacy Policy")
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
            anchors.right: parent.right
            enabled: acknowledge.checked && termsOfUse.checked
            width: 146
            height: 44
            text: qsTr("Get Started")

            onClicked: {
                popup.close()
            }
        }
    }
}
