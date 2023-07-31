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
