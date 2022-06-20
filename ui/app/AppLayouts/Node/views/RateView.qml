import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0
import shared 1.0
import shared.status 1.0
import shared.controls 1.0

import "../stores"

Column {
    property RootStore store

    spacing: 0
    StatusSectionHeadline {
        text: qsTr("Bandwidth")
        topPadding: Style.current.bigPadding
        bottomPadding: Style.current.padding
    }

    Row {
        width: parent.width
        spacing: Style.dp(10)
        StatusBaseText {
            text: qsTr("Upload")
            width: Style.dp(250)
            anchors.verticalCenter: parent.verticalCenter
        }

        Item {
            width: Style.dp(140)
            height: Style.dp(44)
            // TODO: replace with StatusInput from StatusQ at some point
            Input {
                id: uploadRate
                text: Math.round(parseInt(store.nodeModelInst.uploadRate, 10) / 1024 * 100) / 100
                width: parent.width
                readOnly: true
                customHeight: Style.dp(44)
                placeholderText: "0"
                anchors.top: parent.top
            }

            StatusBaseText {
                color: Theme.palette.directColor7
                text: qsTr("Kb/s")
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: uploadRate.right
                anchors.rightMargin: Style.current.padding
                font.pixelSize: Style.current.primaryTextFontSize
            }
        }

        StatusBaseText {
            text: qsTr("Download")
            width: Style.dp(273)
            anchors.verticalCenter: parent.verticalCenter
        }

        Item {
            width: Style.dp(140)
            height: Style.dp(44)
            // TODO: replace with StatusInput from StatusQ at some point
            Input {
                id: downloadRate
                text: Math.round(parseInt(store.nodeModelInst.downloadRate, 10) / 1024 * 100) / 100
                width: parent.width
                readOnly: true
                customHeight: Style.dp(44)
                placeholderText: "0"
                anchors.top: parent.top
            }

            StatusBaseText {
                color: Theme.palette.directColor7
                text: qsTr("Kb/s")
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: downloadRate.right
                anchors.rightMargin: Style.current.padding
                font.pixelSize: Style.current.primaryTextFontSize
            }
        }
    }
}
