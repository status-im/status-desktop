import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme

import shared.controls

import utils


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
        Layout.topMargin: Theme.padding

        color: Theme.palette.baseColor2
    }

    component ErrorText: StatusBaseText {
        Layout.fillWidth: true
        Layout.topMargin: Theme.halfPadding
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
            Layout.topMargin: Theme.padding

            title: qsTr("Total")
            highlightFee: true
            visible: root.showTotal
        }

        Separator {
            visible: accountSelector.visible
        }

        StatusBaseText {
            Layout.topMargin: Theme.padding
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
            Layout.topMargin: Theme.halfPadding

            visible: root.showAccountsSelector
            forceError: accountErrorText.visible
        }

        ErrorText {
            id: accountErrorText

            visible: accountSelector.visible && text !== ""
        }
    }
}
