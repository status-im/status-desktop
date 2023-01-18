import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

import shared.controls 1.0

ColumnLayout {
    id: root

    property int mode: HoldingTypes.Mode.Add
    property alias tokenName: item.name
    property alias tokenShortName: item.shortName
    property alias tokenImage: item.iconSource
    property alias amountText: amountInput.text
    property alias amount: amountInput.amount
    property alias tokenCategoryText: tokenLabel.text
    property alias addOrUpdateButtonEnabled: addOrUpdateButton.enabled
    property alias allowDecimals: amountInput.allowDecimals
    readonly property bool amountValid: amountInput.valid && amountInput.text.length > 0

    signal addClicked
    signal updateClicked
    signal removeClicked

    function setAmount(amount) {
        amountInput.setAmount(amount)
    }

    QtObject {
        id: d

        // values from design
        readonly property int defaultHeight: 44
        readonly property int defaultSpacing: 8
    }

    spacing: d.defaultSpacing

    StatusBaseText {
        id: tokenLabel
        Layout.topMargin: 2 * d.defaultSpacing
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignVCenter
        Layout.leftMargin: d.defaultSpacing
        color: Theme.palette.baseColor1
        font.pixelSize: 12
        elide: Text.ElideRight
    }

    TokenItem {
        id: item
        Layout.fillWidth: true
        enabled: false
    }

    AmountInput {
        id: amountInput

        Layout.fillWidth: true
        Layout.bottomMargin: (validationError !== "") ? root.spacing : 0
        customHeight: d.defaultHeight
        allowDecimals: true
        keepHeight: true
    }

    StatusButton {
        id: addOrUpdateButton

        text: (root.mode === HoldingTypes.Mode.Add) ? qsTr("Add") : qsTr("Update")
        Layout.preferredHeight: d.defaultHeight
        Layout.topMargin: d.defaultSpacing
        Layout.fillWidth: true
        onClicked: root.mode === HoldingTypes.Mode.Add
                   ? root.addClicked() : root.updateClicked()
    }

    StatusFlatButton {
        text: qsTr("Remove")
        Layout.preferredHeight: d.defaultHeight
        Layout.fillWidth: true
        Layout.topMargin: d.defaultSpacing
        visible: root.mode === HoldingTypes.Mode.Update
        type: StatusBaseButton.Type.Danger

        onClicked: root.removeClicked()
    }
}
