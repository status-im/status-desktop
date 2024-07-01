import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

ColumnLayout {
        property alias name: appNameText.text
        property alias url: appUrlText.text
        property string iconUrl: ""

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 72
            Layout.preferredHeight: Layout.preferredWidth

            radius: width / 2
            color: Theme.palette.primaryColor3

            StatusRoundedImage {
                id: iconDisplay

                anchors.fill: parent

                visible: !fallbackImage.visible

                image.source: iconUrl
            }

            StatusIcon {
                id: fallbackImage

                anchors.centerIn: parent

                width: 40
                height: 40

                icon: "dapp"
                color: Theme.palette.primaryColor1

                visible: iconDisplay.image.isLoading || iconDisplay.image.isError || !iconUrl
            }
        }

        StatusBaseText {
            id: appNameText

            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 4

            font.bold: true
            font.pixelSize: 17
        }

        // TODO replace with the proper URL control
        StatusLinkText {
            id: appUrlText

            Layout.alignment: Qt.AlignHCenter
            font.pixelSize: 15
        }

        Rectangle {
            Layout.preferredWidth: pairingStatusLayout.implicitWidth + 32
            Layout.preferredHeight: pairingStatusLayout.implicitHeight + 14

            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 16

            visible: d.connectionStatus !== root.notConnectedStatus

            color: d.connectionStatus === root.connectionSuccessfulStatus
                        ? d.afterTwoSecondsFromStatus
                            ? Theme.palette.successColor2
                            : Theme.palette.successColor3
                        : d.afterTwoSecondsFromStatus
                            ? "transparent"
                            : Theme.palette.dangerColor3
            border.color: d.connectionStatus === root.connectionSuccessfulStatus
                                ? Theme.palette.successColor2
                                : Theme.palette.dangerColor2
            border.width: 1
            radius: height / 2

            RowLayout {
                id: pairingStatusLayout

                anchors.centerIn: parent

                spacing: 8

                Rectangle {
                    width: 6
                    height: 6
                    radius: width / 2

                    visible: d.connectionStatus === root.connectionSuccessfulStatus
                    color: Theme.palette.successColor1
                }

                StatusIcon {
                    Layout.preferredWidth: 16
                    Layout.preferredHeight: 16

                    visible: d.connectionStatus !== root.connectionSuccessfulStatus

                    color: Theme.palette.dangerColor1
                    icon: "warning"
                }

                StatusBaseText {
                    text: {
                        if (d.connectionStatus === root.connectionSuccessfulStatus)
                            return qsTr("Connected. You can now go back to the dApp.")
                        else if (d.connectionStatus === root.connectionFailedStatus)
                            return qsTr("Error connecting to dApp. Close and try again")
                        return ""
                    }

                    font.pixelSize: 12
                    color: d.connectionStatus === root.connectionSuccessfulStatus ? Theme.palette.directColor1 : Theme.palette.dangerColor1
                }
            }
        }
    }
