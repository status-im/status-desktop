import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme

import utils

Control {
    id: root

    property string accountName
    property alias totalFeeText: feeTotalRow.feeText
    property alias errorText: errorText.text

    contentItem: ColumnLayout {
        spacing: 0

        StatusBaseText {
            Layout.topMargin: Theme.padding
            Layout.fillWidth: true

            visible: root.accountName !== ""
            color: Theme.palette.baseColor1
            elide: Text.ElideRight
            font.pixelSize: Theme.primaryTextFontSize
            maximumLineCount: 2
            text: qsTr("via %1").arg(root.accountName)
            wrapMode: Text.Wrap
        }

        Rectangle {
            Layout.topMargin: Theme.padding
            Layout.fillWidth: true
            Layout.preferredHeight: 1

            color: Theme.palette.baseColor2
        }

        FeeRow {
            id: feeTotalRow

            Layout.topMargin: Theme.padding
            Layout.fillWidth: true

            title: qsTr("Total")
            highlightFee: true
        }

        StatusBaseText {
            id: errorText

            Layout.fillWidth: true
            Layout.topMargin: Theme.halfPadding

            color: Theme.palette.dangerColor1
            font.pixelSize: Theme.additionalTextSize
            horizontalAlignment: Text.AlignRight
            visible: text !== ""
            wrapMode: Text.Wrap
        }
    }
}
