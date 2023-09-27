import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13

import utils 1.0

import StatusQ.Controls 0.1
import StatusQ.Popups 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

Rectangle {
    id: footer

    property string maxFiatFees: "..."
    property alias totalTimeEstimate: estimatedTime.text
    property bool pending: true
    property alias nextButtonText: nextButton.text

    signal nextButtonClicked()

    implicitHeight: 82
    radius: 8
    color: Theme.palette.baseColor3

    layer.enabled: true
    layer.effect: DropShadow {
        verticalOffset: 2
        radius: 16
        samples: 17
        color: Theme.palette.dropShadow
    }

    RowLayout {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 32
        anchors.rightMargin: 32

        ColumnLayout {
            StatusBaseText {
                font.pixelSize: 15
                color: Theme.palette.directColor5
                text: qsTr("Estimated Time:")
                wrapMode: Text.WordWrap
            }
            // To-do not implemented yet
            StatusBaseText {
                id: estimatedTime
                font.pixelSize: 15
                color: Theme.palette.directColor1
                wrapMode: Text.WordWrap
            }
        }

        // To fill gap in between
        Item {
            Layout.fillWidth: true
            implicitHeight: 1
        }

        RowLayout {
            spacing: 16
            ColumnLayout {
                StatusBaseText {
                    font.pixelSize: 15
                    color: Theme.palette.directColor5
                    text: qsTr("Max Fees:")
                    wrapMode: Text.WordWrap
                }
                StatusBaseText {
                    id: fiatFees
                    font.pixelSize: 15
                    color: Theme.palette.directColor1
                    text: maxFiatFees
                    wrapMode: Text.WordWrap
                }
            }

            StatusFlatButton {
                id: nextButton
                text: qsTr("Send")
                objectName: "sendModalFooterSendButton"
                size: StatusBaseButton.Size.Large
                normalColor: Theme.palette.primaryColor2
                disabledColor: Theme.palette.baseColor2
                enabled: !footer.pending
                loading: footer.pending
                onClicked: nextButtonClicked()
                icon.name: "password"
            }
        }
    }
}

