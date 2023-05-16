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
    property bool isMainnetTx: true
    property bool error: false
    property int confirmations: 0
    property string chainName
    property int duration: 0
    property int progress: 0
    property double confirmationTimeStamp
    property double finalisationTimeStamp
    property double failedTimeStamp

    spacing: 32

    QtObject {
        id: d
        readonly property bool finalized: (isMainnetTx ? confirmations >= progressBar.steps : progress === duration) && !error
        readonly property bool confirmed: confirmations >= progressBar.confirmationBlocks && !error
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
        isMainnetTx: root.isMainnetTx
        confirmations: root.confirmations
        duration: root.duration
        progress: root.progress
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
                text: LocaleUtils.formatDateTime(root.confirmationTimeStamp * 1000, Locale.LongFormat)
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
                text: LocaleUtils.formatDateTime(root.finalisationTimeStamp * 1000, Locale.LongFormat)
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
                text: LocaleUtils.formatDateTime(root.failedTimeStamp * 1000, Locale.LongFormat)
            }
        }
    }

    Separator {
        Layout.fillWidth: true
        Layout.topMargin: 8
        implicitHeight: 1
    }
}
