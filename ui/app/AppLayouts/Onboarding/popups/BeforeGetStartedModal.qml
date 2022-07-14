import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.14
import QtQml.Models 2.14

import utils 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups.Dialog 0.1

StatusDialog {
    id: root

    width: 480
    anchors.centerIn: parent
    closePolicy: Popup.NoAutoClose

    header: StatusDialogHeader {
        headline.title: qsTr("Before you get started...")
        actions.closeButton.visible: false
    }

    footer: StatusDialogFooter {
        rightButtons: ObjectModel {
            StatusButton {
                objectName: "getStartedStatusButton"
                enabled: acknowledge.checked && termsOfUse.checked
                size: StatusBaseButton.Size.Large
                font.weight: Font.Medium
                text: qsTr("Get Started")
                onClicked: root.close()
            }
        }
    }

    contentItem: Item {
        Column {
            width: 416
            spacing: 16
            anchors.centerIn: parent

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
}
