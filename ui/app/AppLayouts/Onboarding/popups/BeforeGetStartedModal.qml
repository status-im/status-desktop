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
    header.title: qsTrId("before-you-get-started---")
    hasCloseButton: false
    closePolicy: Popup.NoAutoClose

    contentItem: Item {
        implicitHeight: childrenRect.height
        width: popup.width
        Column {
            spacing: Style.dp(12)
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Style.dp(32)
            anchors.rightMargin: Style.dp(32)

            Item { height: Style.dp(12);  width: parent.width }

            StatusCheckBox {
                id: acknowledge
                objectName: "acknowledgeCheckBox"
                width: parent.width
                text: qsTrId("i-acknowledge-that-status-desktop-is-in-beta-and-by-using-it--i-take-the-full-responsibility-for-all-risks-concerning-my-data-and-funds-")
            }

            StatusCheckBox {
                id: termsOfUse
                objectName: "termsOfUseCheckBox"

                contentItem: Row {
                    spacing: Style.dp(4)
                    leftPadding: termsOfUse.indicator.width + termsOfUse.spacing

                    StatusBaseText {
                        text: qsTr("I accept Status")
                        color: Theme.palette.directColor1
                    }

                    StatusBaseText {
                        objectName: "termsOfUseLink"
                        text: qsTrId("terms-of-service")
                        color: Theme.palette.primaryColor1

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

                    StatusBaseText {
                        text: " & "
                        color: Theme.palette.directColor1
                    }

                    StatusBaseText {
                        objectName: "privacyPolicyLink"
                        text: qsTr("Privacy Policy")
                        color: Theme.palette.primaryColor1

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
                }
            }

            Item { height: Style.dp(12);  width: parent.width }
        }
    }

    rightButtons: [
        StatusButton {
            id: getStartedButton
            objectName: "getStartedStatusButton"
            enabled: acknowledge.checked && termsOfUse.checked
            text: qsTrId("get-started")
            onClicked: {
                popup.close()
            }
        }
    ]
}
