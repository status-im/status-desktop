import QtQuick 2.13
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0
import shared.panels 1.0

import "../controls"

ColumnLayout {
    id: root

    property bool error: false
    property bool pending: false

    property int outNetworkLayer: 0
    property int inNetworkLayer: 0

    property double outNetworkTimestamp: 0
    property double inNetworkTimestamp: 0

    property string outChainName
    property string inChainName

    property int outNetworkConfirmations: 0
    property int inNetworkConfirmations: 0

    spacing: 32

    StatusTxProgressBar {
        id: progressBarOut
        Layout.topMargin: 8
        Layout.fillWidth: true
        error: root.error
        networkLayer: root.outNetworkLayer
        confirmations: root.outNetworkConfirmations
        timestamp: root.outNetworkTimestamp
        chainName: root.outChainName
    }

    TextColumn {
        visible: progressBarOut.isValid && progressBarOut.error
        text: qsTr("Failed on %1").arg(progressBarOut.chainName)
        timestamp: progressBarOut.timestamp
    }

    StatusTxProgressBar {
        id: progressBarIn
        Layout.topMargin: 8
        Layout.fillWidth: true
        error: root.error
        networkLayer: root.inNetworkLayer
        confirmations: root.inNetworkConfirmations
        timestamp: root.inNetworkTimestamp
        chainName: root.inChainName
    }

    TextColumn {
        visible: progressBarOut.isValid && progressBarOut.confirmed
        text: qsTr("Confirmed on %1").arg(progressBarOut.chainName)
        timestamp: progressBarOut.confirmationTimeStamp
    }

    TextColumn {
        visible: progressBarIn.isValid && progressBarIn.confirmed
        text: qsTr("Confirmed on %1").arg(progressBarIn.chainName)
        timestamp: progressBarIn.confirmationTimeStamp
    }

    TextColumn {
        visible: progressBarOut.isValid && progressBarOut.finalized
        text: qsTr("Finalised on %1").arg(progressBarOut.chainName)
        timestamp: progressBarOut.finalisationTimeStamp
    }

    TextColumn {
        visible: progressBarIn.isValid && progressBarIn.finalized
        text: qsTr("Finalised on %1").arg(progressBarIn.chainName)
        timestamp: progressBarIn.finalisationTimeStamp
    }

    TextColumn {
        visible: progressBarIn.isValid && progressBarIn.error
        text: qsTr("Failed on %1").arg(progressBarIn.chainName)
        timestamp: progressBarIn.timestamp
    }

    component TextColumn: Column {
        id: textColumn

        property string text
        property int timestamp

        spacing: 4
        StatusBaseText {
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 13
            color: Theme.palette.baseColor1
            lineHeight: 18
            lineHeightMode: Text.FixedHeight
            text: textColumn.text
        }
        StatusBaseText {
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 13
            color: Theme.palette.directColor1
            lineHeight: 18
            lineHeightMode: Text.FixedHeight
            text: textColumn.timestamp > 0 ? LocaleUtils.formatDateTime(textColumn.timestamp * 1000, Locale.LongFormat) : ""
        }
    }
}
