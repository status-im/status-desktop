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

        Timer {
            id: timer

            interval: 1000

            onTriggered: {
                addressesModel.addAddressesFromString(
                            addressesSelectorPanel.text)
                addressesSelectorPanel.clearInput()
                addressesSelectorPanel.positionListAtEnd()
            }
        }

        AddressesSelectorPanel {
            id: addressesSelectorPanel

            anchors.centerIn: parent
            width: 500

            model: AddressesModel {
                id: addressesModel
            }

            Binding on loading { value: isLoadingCheckBox.checked }
            Binding on loading { value: timer.running }

            onAddAddressesRequested: timer.start()
            onRemoveAddressRequested: addressesModel.remove(index)
        }
    }

    LogsAndControlsPanel {
        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 160

        logsView.logText: logs.logText

        ColumnLayout {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            CheckBox {
                id: isLoadingCheckBox

                text: "Is loading"
            }

            Button {
                text: "Clear"

                onClicked: addressesModel.clear()
            }
        }
    }
}

// category: Components
