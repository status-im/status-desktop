import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import AppLayouts.Communities.controls

import Storybook
import Models

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
