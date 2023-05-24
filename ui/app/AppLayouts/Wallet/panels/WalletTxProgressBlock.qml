import QtQuick 2.13
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0
import shared.panels 1.0

import "../controls"

ColumnLayout {
    id: root

    // To-do adapt this for multi-tx, not sure how the data will look for that yet
    property bool isLayer1: true
    property bool error: false
    property int confirmations: 0
    property string chainName
    property double timeStamp

    spacing: 32

    QtObject {
        id: d
        readonly property bool finalized: (isLayer1 ? confirmations >= progressBar.steps : progress === duration) && !error
        readonly property bool confirmed: confirmations >= progressBar.confirmationBlocks && !error
        readonly property double confirmationTimeStamp: {
            if (root.isLayer1) {
                return root.timeStamp + 12 * 4 // A block on layer1 is every 12s
            }

            return root.timeStamp
        }

        readonly property double finalisationTimeStamp: {
            if (root.isLayer1) {
                return root.timeStamp + 12 * 64 // A block on layer1 is every 12s
            }

            return root.timeStamp + 604800 // 7 days in seconds
        }

        readonly property int duration: 168 // 7 days in hours
        readonly property int progress: (Math.floor(Date.now() / 1000) - root.timeStamp) / 3600
    }

    Separator {
        Layout.fillWidth: true
        implicitHeight: 1
    }

    StatusTxProgressBar {
        id: progressBar
        Layout.topMargin: 8
        Layout.fillWidth: true
        error: root.error
        isLayer1: root.isLayer1
        confirmations: root.confirmations
        duration: d.duration
        progress: d.progress
        chainName: root.chainName
    }

    Column {
        spacing: 20
        Column {
            spacing: 4
            visible: d.confirmed
            StatusBaseText {
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 13
                color: Theme.palette.baseColor1
                lineHeight: 18
                lineHeightMode: Text.FixedHeight
                text: qsTr("Confirmed on %1").arg(root.chainName)
            }
            StatusBaseText {
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 13
                color: Theme.palette.directColor1
                lineHeight: 18
                lineHeightMode: Text.FixedHeight
                text: LocaleUtils.formatDateTime(d.confirmationTimeStamp * 1000, Locale.LongFormat)
            }
        }

        Column {
            spacing: 4
            visible: d.finalized
            StatusBaseText {
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 13
                color: Theme.palette.baseColor1
                lineHeight: 18
                lineHeightMode: Text.FixedHeight
                text: qsTr("Finalised on %1").arg(root.chainName)
            }
            StatusBaseText {
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 13
                color: Theme.palette.directColor1
                lineHeight: 18
                lineHeightMode: Text.FixedHeight
                text: LocaleUtils.formatDateTime(d.finalisationTimeStamp * 1000, Locale.LongFormat)
            }
        }

        Column {
            spacing: 4
            visible: root.error
            StatusBaseText {
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 13
                color: Theme.palette.baseColor1
                lineHeight: 18
                lineHeightMode: Text.FixedHeight
                text: qsTr("Failed on %1").arg(root.chainName)
            }
            StatusBaseText {
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 13
                color: Theme.palette.directColor1
                lineHeight: 18
                lineHeightMode: Text.FixedHeight
                text: LocaleUtils.formatDateTime(root.timeStamp * 1000, Locale.LongFormat)
            }
        }
    }

    Separator {
        Layout.fillWidth: true
        Layout.topMargin: 8
        implicitHeight: 1
    }
}
