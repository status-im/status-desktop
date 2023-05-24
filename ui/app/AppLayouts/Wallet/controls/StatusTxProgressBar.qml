import QtQuick 2.14
import QtQuick.Layouts 1.12

import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1
import StatusQ.Controls 0.1

ColumnLayout {
    id: root

    property bool isLayer1: true
    property bool error: false
    property int steps: isLayer1 ? 64 : 1
    property int confirmations: 0
    property int confirmationBlocks: isLayer1 ? 4 : 1
    property string chainName

    property color fillColor: Theme.palette.blockProgressBarColor
    property color confirmationColor: Theme.palette.successColor1

    property alias blockProgressBar: blockProgressBar
    property alias titleText: title.text
    property alias subText: subText.text

    // Below properties only needed when not a mainnet tx
    property alias progress: progressBar.value
    property alias duration: progressBar.to

    QtObject {
        id: d
        readonly property bool finalized: isLayer1 ? confirmations >= steps : progress === duration
        readonly property bool confirmed: confirmations >= confirmationBlocks
        readonly property int hoursInADay: 24
    }

    spacing: 8

    StatusBaseText {
        id: title
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: 15
        color: Theme.palette.directColor1
        lineHeight: 22
        lineHeightMode: Text.FixedHeight
        text: error ? qsTr("Failed on %1").arg(root.chainName) :
                      d.finalized ?
                          qsTr("Finalised on %1").arg(root.chainName) :
                          d.confirmed ?
                              qsTr("Confirmed on %1, finalisation in progress...").arg(root.chainName):
                              confirmations > 0 ?
                                  qsTr("Confirmation in progress on %1...").arg(root.chainName) :
                                  qsTr("Pending on %1...").arg(root.chainName)
    }

    RowLayout {
        spacing: 2
        Layout.preferredHeight: 12
        Layout.fillWidth: true

        StatusBlockProgressBar {
            id: blockProgressBar
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: root.isLayer1
            steps: root.steps
            completedSteps: root.confirmations
            blockSet: root.confirmationBlocks
            error: root.error
        }
        RowLayout {
            spacing: 2
            visible: !root.isLayer1
            Rectangle {
                Layout.preferredWidth: 3
                Layout.fillHeight: true
                color: error ? Theme.palette.dangerColor1 : confirmations > 0 ? confirmationColor : fillColor
                radius: 100
            }
            StatusProgressBar {
                id: progressBar
                Layout.fillWidth: true
                Layout.fillHeight: true
                from: 0
                to: duration
                backgroundColor: root.fillColor
                backgroundBorderColor: "transparent"
                fillColor: error ? "transparent": Theme.palette.primaryColor1
                backgroundRadius: 2
            }
        }
    }

    StatusBaseText {
        id: subText
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: 13
        color: Theme.palette.baseColor1
        lineHeight: 18
        lineHeightMode: Text.FixedHeight
        text: d.finalized && !root.error ? qsTr("In epoch %1").arg(root.confirmations) : d.confirmed && !root.isLayer1 ?
                                               qsTr("%n day(s) until finality", "", Math.ceil((root.duration - root.progress)/d.hoursInADay)):
                                               qsTr("%1 / %2 confirmations").arg(root.confirmations).arg(root.steps)
    }
}
