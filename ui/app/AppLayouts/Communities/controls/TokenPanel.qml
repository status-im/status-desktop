import QtQuick 2.15
import QtQuick.Layouts 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

import shared.controls 1.0

import utils 1.0


ColumnLayout {
    id: root

    property int mode: HoldingTypes.Mode.Add
    property alias tokenName: item.name
    property alias tokenShortName: item.shortName
    property alias tokenAmount: item.amount
    property alias tokenImage: item.iconSource
    property alias amountText: amountInput.text
    property alias amount: amountInput.amount
    property alias multiplierIndex: amountInput.multiplierIndex
    property alias tokenCategoryText: tokenLabel.text
    property alias networkLabelText: d.networkLabelText
    property alias addOrUpdateButtonEnabled: addOrUpdateButton.enabled
    property alias allowDecimals: amountInput.allowDecimals
    readonly property bool amountValid: amountInput.valid && !!amountInput.text

    property var networksModel

    signal addClicked
    signal updateClicked
    signal removeClicked

    function setAmount(amount, multiplierIndex = 0) {
        console.assert(typeof amount === "string")
        amountInput.setAmount(amount, multiplierIndex)
    }

    QtObject {
        id: d

        // values from design
        readonly property int defaultHeight: 44
        readonly property int defaultSpacing: 8

        property string networkLabelText: qsTr("Network for airdrop")
    }

    component CustomText: StatusBaseText {
        color: Theme.palette.baseColor1
        font.pixelSize: 12
        elide: Text.ElideRight

        Layout.fillWidth: true
        Layout.alignment: Qt.AlignVCenter
        Layout.leftMargin: d.defaultSpacing
    }

    spacing: d.defaultSpacing

    CustomText {
        id: tokenLabel

        Layout.topMargin: 2 * d.defaultSpacing
    }

    TokenItem {
        id: item

        Layout.fillWidth: true
        enabled: false
    }

    Loader {
        id: networksComboBoxLoader

        active: !!root.networksModel
        visible: active

        Layout.fillWidth: true
        Layout.topMargin: 14
        Layout.bottomMargin: d.defaultSpacing

        sourceComponent: ColumnLayout {
            spacing: 10

            property alias currentAmount: inlineNetworksComboBox.currentAmount
            property alias currentMultiplierIndex:
                inlineNetworksComboBox.currentMultiplierIndex
            property alias currentInfiniteAmount:
                inlineNetworksComboBox.currentInfiniteAmount

            CustomText {
                id: networkLabel

                text: d.networkLabelText

                color: Theme.palette.baseColor1
                font.pixelSize: 12
                elide: Text.ElideRight
            }

            InlineNetworksComboBox {
                id: inlineNetworksComboBox

                Layout.fillWidth: true

                model: root.networksModel
            }
        }
    }

    AmountInput {
        id: amountInput

        locale: LocaleUtils.userInputLocale

        Layout.fillWidth: true
        Layout.bottomMargin: (validationError !== "") ? root.spacing * 2 : 0
        customHeight: d.defaultHeight
        allowDecimals: true
        keepHeight: true

        validateMaximumAmount:
            !!networksComboBoxLoader.item &&
            !networksComboBoxLoader.item.currentInfiniteAmount

        maximumAmount: !!networksComboBoxLoader.item
                       ? networksComboBoxLoader.item.currentAmount : "0"

        multiplierIndex: !!networksComboBoxLoader.item
                         ? networksComboBoxLoader.item.currentMultiplierIndex : 0

        onKeyPressed: {
            if(!addOrUpdateButton.enabled)
                return

            if(event.key === Qt.Key_Enter || event.key === Qt.Key_Return)
                addOrUpdateButton.clicked()
        }
        onVisibleChanged: {
            if(visible)
                forceActiveFocus()
        }
        Component.onCompleted: {
            if(visible)
                forceActiveFocus()
        }
    }

    StatusButton {
        id: addOrUpdateButton

        text: root.mode === HoldingTypes.Mode.Add ? qsTr("Add")
                                                  : qsTr("Update")
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
        visible: root.mode === HoldingTypes.Mode.UpdateOrRemove
        type: StatusBaseButton.Type.Danger

        onClicked: root.removeClicked()
    }
}
