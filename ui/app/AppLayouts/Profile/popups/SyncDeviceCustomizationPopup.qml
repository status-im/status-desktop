import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtQml.Models 2.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1
import StatusQ.Popups.Dialog 0.1
import StatusQ.Core.Utils 0.1

import shared.controls 1.0

import "../stores"

StatusDialog {
    id: root

    property var devicesStore
    property var advancedStore
    property var deviceModel

    readonly property string deviceName: d.deviceName

    title: qsTr("Personalize %1").arg(deviceModel.name)
    width: implicitWidth
    padding: 16

    QtObject {
        id: d
        property string deviceName: ""

        function saveNewName() {
            if (!nameInput.valid)
                return
            root.devicesStore.setInstallationName(root.deviceModel.installationId, nameInput.text.trim())
            root.close()
        }
    }

    onOpened: {
        nameInput.text = deviceModel.name
        nameInput.forceActiveFocus()
    }

    contentItem: ColumnLayout {
        spacing: 8
        StatusInput {
            id: nameInput
            Layout.fillWidth: true
            label: qsTr("Device name")
            validators: [
                StatusValidator {
                    errorMessage: qsTr("Device name can not be empty")
                    validate: (value) => {
                                  return value.trim() !== ""
                              }
                }

            ]
            Keys.onReturnPressed: {
                d.saveNewName()
            }
        }
        StatusInput {
            id: idInput
            Layout.fillWidth: true
            label: qsTr("Installation ID")
            enabled: false
            text: root.deviceModel.installationId
            visible: root.advancedStore.isDebugEnabled
        }
    }

     footer: StatusDialogFooter {
        rightButtons: ObjectModel {
            StatusButton {
                text: qsTr("Done")
                enabled: nameInput.valid
                onClicked : {
                    d.saveNewName()
                }
            }
        }
    }
}
