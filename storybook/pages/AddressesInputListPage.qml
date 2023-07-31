import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import AppLayouts.Communities.controls 1.0

import Storybook 1.0
import Models 1.0

SplitView {
    orientation: Qt.Vertical

    Logs { id: logs }

    Pane {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        Rectangle {
            anchors.fill: parent
            color: "lightgray"
        }

        AddressesInputList {
            width: 500
            anchors.centerIn: parent

            enabled: isEnabledCheckBox.checked

            model: AddressesModel {
                id: addressesModel
            }

            onAddAddressesRequested: {
                addressesModel.addAddressesFromString(addresses)
                clearInput()
                positionListAtEnd()
            }

            onRemoveAddressRequested: addressesModel.remove(index)
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 160

        logsView.logText: logs.logText

        ColumnLayout {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            CheckBox {
                id: isEnabledCheckBox

                text: "Enabled"
                checked: true
            }

            Button {
                text: "Clear"

                onClicked: addressesModel.clear()
            }
        }
    }
}

// category: Components
