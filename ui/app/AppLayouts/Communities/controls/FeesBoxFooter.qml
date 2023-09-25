import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0


Control {
    id: root

    property alias generalErrorText: generalErrorText.text

    property bool showTotal: true
    property alias totalFeeText: feeTotalRow.feeText

    readonly property alias accountsSelector: accountSelector
    property bool showAccountsSelector: true

    property alias accountErrorText: accountErrorText.text

    required property string accountSelectorText

    component Separator: Rectangle {
        Layout.fillWidth: true
        Layout.preferredHeight: 1
        Layout.topMargin: Style.current.padding

        color: Theme.palette.baseColor2
    }

    component ErrorText: StatusBaseText {
        Layout.fillWidth: true
        Layout.topMargin: Style.current.halfPadding
        horizontalAlignment: Text.AlignRight

        font.pixelSize: Theme.tertiaryTextFontSize
        color: Theme.palette.dangerColor1

        wrapMode: Text.Wrap
    }

    contentItem: ColumnLayout {
        spacing: 0

        ErrorText {
            id: generalErrorText

            visible: text !== ""
        }

        Separator {
            visible: root.showTotal
        }

        FeeRow {
            id: feeTotalRow

            Layout.fillWidth: true
            Layout.topMargin: Style.current.padding

            title: qsTr("Total")
            highlightFee: true
            visible: root.showTotal
        }

        Separator {
            visible: accountSelector.visible
        }

        StatusBaseText {
            Layout.topMargin: Style.current.padding
            Layout.fillWidth: true

            visible: accountSelector.visible
            text: root.accountSelectorText
            color: Theme.palette.baseColor1
            font.pixelSize: Theme.primaryTextFontSize
            lineHeight: 1.2
            wrapMode: Text.WordWrap
        }

        AccountSelector {
            id: accountSelector

            Layout.fillWidth: true
            Layout.topMargin: Style.current.halfPadding

            visible: root.showAccountsSelector
            forceError: accountErrorText.visible
        }

        ErrorText {
            id: accountErrorText

            visible: accountSelector.visible && text !== ""
        }
    }
}
