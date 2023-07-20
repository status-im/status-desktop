import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

Control {
    id: root

    property string accountName
    property alias totalFeeText: feeTotalRow.feeText
    property alias errorText: errorText.text

    contentItem: ColumnLayout {
        spacing: 0

        StatusBaseText {
            Layout.topMargin: Style.current.padding
            Layout.fillWidth: true

            visible: root.accountName !== ""
            color: Theme.palette.baseColor1
            elide: Text.ElideRight
            font.pixelSize: Style.current.primaryTextFontSize
            maximumLineCount: 2
            text: qsTr("via %1").arg(root.accountName)
            wrapMode: Text.Wrap
        }

        Rectangle {
            Layout.topMargin: Style.current.padding
            Layout.fillWidth: true
            Layout.preferredHeight: 1

            color: Theme.palette.baseColor2
        }

        FeeRow {
            id: feeTotalRow

            Layout.topMargin: Style.current.padding
            Layout.fillWidth: true

            title: qsTr("Total")
            highlightFee: true
        }

        StatusBaseText {
            id: errorText

            Layout.fillWidth: true
            Layout.topMargin: Style.current.halfPadding

            color: Theme.palette.dangerColor1
            font.pixelSize: Theme.tertiaryTextFontSize + 1
            horizontalAlignment: Text.AlignRight
            visible: text !== ""
            wrapMode: Text.Wrap
        }
    }
}
