import QtQuick 2.14
import QtQuick.Layouts 1.12

import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1
import StatusQ.Controls 0.1

import utils 1.0
import AppLayouts.Wallet 1.0

ColumnLayout {
    id: root

    property int networkLayer: 0
    property bool error: false
    property bool pending: false
    property int steps: isLayer1 ? 64 : 1
    property int confirmations: 0
    property int confirmationBlocks: isLayer1 ? 4 : 1
    property string chainName
    property int timestamp: 0

    property color fillColor: Theme.palette.blockProgressBarColor
    property color confirmationColor: Theme.palette.successColor1

    property alias blockProgressBar: blockProgressBar
    property alias titleText: title.text
    property alias subText: subText.text

    readonly property bool isValid: root.networkLayer > 0 && !!root.chainName
    readonly property double confirmationTimeStamp: WalletUtils.calculateConfirmationTimestamp(root.networkLayer, root.timestamp)
    readonly property double finalisationTimeStamp: WalletUtils.calculateFinalisationTimestamp(root.networkLayer, root.timestamp)

    readonly property bool finalized: (isLayer1 ? confirmations >= steps : progress >= duration) && !error && !pending
    readonly property bool confirmed: confirmations >= confirmationBlocks && !error && !pending

    readonly property bool isLayer1: networkLayer === 1

    // Below properties only needed when not a mainnet tx
    property int duration: Constants.time.hoursIn7Days
    property alias progress: progressBar.value

    spacing: 8
    visible: isValid

    StatusBaseText {
        id: title
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: 15
        color: Theme.palette.directColor1
        lineHeight: 22
        lineHeightMode: Text.FixedHeight
        text: {
            if (error) {
                return qsTr("Failed on %1").arg(root.chainName)
            } else if (pending) {
                return qsTr("Confirmation in progress on %1...").arg(root.chainName)
            } else if (root.finalized) {
                return qsTr("Finalised on %1").arg(root.chainName)
            } else if (root.confirmed) {
                return qsTr("Confirmed on %1, finalisation in progress...").arg(root.chainName)
            }
            return qsTr("Pending on %1...").arg(root.chainName)
        }
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
                to: root.duration
                value: root.pending || root.error ? 0 : (Math.floor(Date.now() / 1000) - root.timestamp) / Constants.time.secondsInHour
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
        text: {
            if (root.finalized) {
                return qsTr("In epoch %1").arg(root.confirmations)
            } else if (root.confirmed && !root.isLayer1) {
                return qsTr("%n day(s) until finality", "", Math.ceil((root.duration - root.progress) / Constants.time.hoursInDay))
            }
            return qsTr("%1 / %2 confirmations").arg(root.confirmations).arg(root.steps)
        }
    }
}
