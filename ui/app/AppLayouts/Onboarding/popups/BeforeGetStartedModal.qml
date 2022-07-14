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

    width: 480
    height: 318
    anchors.centerIn: parent
    header.title: qsTr("Before you get started...")
    hasCloseButton: false
    closePolicy: Popup.NoAutoClose

    contentItem: Item {
        Column {
            spacing: 12
            anchors.fill: parent
            anchors.leftMargin: 32
            anchors.rightMargin: 32
            anchors.topMargin: 24
            anchors.bottomMargin: 24

            StatusCheckBox {
                id: acknowledge
                objectName: "acknowledgeCheckBox"
                spacing: 8
                font.pixelSize: 15
                width: parent.width
                text: qsTr("I acknowledge that Status Desktop is in Beta and by using it I take the full responsibility for all risks concerning my data and funds.")
            }

            StatusCheckBox {
                id: termsOfUse
                objectName: "termsOfUseCheckBox"
                width: parent.width
                font.pixelSize: 15

                contentItem: Row {
                    spacing: 4
                    leftPadding: termsOfUse.indicator.width + termsOfUse.spacing

                    StatusBaseText {
                        text: qsTr("I accept Status")
                        font.pixelSize: 15
                    }

                    StatusBaseText {
                        objectName: "termsOfUseLink"
                        text: qsTr("Terms of Use")
                        color: Theme.palette.primaryColor1
                        font.pixelSize: 15
                        font.weight: Font.Medium

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
                                Qt.openUrlExternally("https://status.im/terms-of-use/")
                            }
                        }
                    }

                    StatusBaseText {
                        text: "&"
                        font.pixelSize: 15
                    }

                    StatusBaseText {
                        objectName: "privacyPolicyLink"
                        text: qsTr("Privacy Policy")
                        color: Theme.palette.primaryColor1
                        font.pixelSize: 15
                        font.weight: Font.Medium

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
        }
    }

    rightButtons: [
        StatusButton {
            id: getStartedButton
            objectName: "getStartedStatusButton"
            enabled: acknowledge.checked && termsOfUse.checked
            size: StatusBaseButton.Size.Large
            font.weight: Font.Medium
            text: qsTr("Get Started")
            onClicked: {
                popup.close()
            }
        }
    ]
}
