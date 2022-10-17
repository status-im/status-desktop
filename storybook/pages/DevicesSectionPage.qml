import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import AppLayouts.Profile.views 1.0
import AppLayouts.Profile.stores 1.0

import Storybook 1.0

import utils 1.0

SplitView {
    id: root
    Logs { id: logs }

    function findModel(data, field, model_id) {
        for (let i = 0; i < data.count; i++) {
            let item = data.get(i)
            if (item[field] === model_id) {
                return item
            }
        }
    }

    property var model: QtObject {
        property bool isDeviceSetup: false
    }

    property ListModel devicesList: ListModel {
        ListElement {
            installationId: "installation-id-1"
            isCurrentDevice: true
            enabled: true
            name: "device name 1"
        }
        ListElement {
            installationId: "installation-id-2"
            isCurrentDevice: false
            enabled: true
            name: "device name 2"
        }
        ListElement {
            installationId: "installation-id-3"
            isCurrentDevice: false
            enabled: false
            name: "device name 3"
        }
    }


    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        DevicesView {
            SplitView.fillWidth: true
            SplitView.fillHeight: true
            contentWidth: parent.width

            devicesList: root.devicesList

            devicesStore: DevicesStore {
                isDeviceSetup: model.isDeviceSetup

                function setName(name) {
                    logs.logEvent("deviceStore::setName", ["name"], arguments)
                    findModel(root.devicesList, "installationId", "installation-id-1").name = name
                    model.isDeviceSetup = true
                }

                function advertise() {
                    logs.logEvent("deviceStore::advertise")
                }

                function enableDevice(installationId, devicePairedSwitch) {
                    logs.logEvent("deviceStore::setName", ["installationId", "devicePairedSwitch"], arguments)
                }

                function syncAll() {
                    logs.logEvent("deviceStore::syncAll")
                }
            }
        }

        LogsAndControlsPanel {
            id: logsAndControlsPanel

            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 200

            logsView.logText: logs.logText
        }
    }

    Control {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300

        font.pixelSize: 13

        ColumnLayout {
            anchors.fill: parent

            ListView {
                anchors.fill: parent
                model: devicesList

                Flow {
                    width: parent.width
                    height: 60

                    CheckBox {
                        text: "isDeviceSetup"
                        checked: model.isDeviceSetup
                        onToggled: model.isDeviceSetup = !model.isDeviceSetup
                    }
                }

                delegate: Rectangle {
                    width: parent.width
                    height: column.implicitHeight

                    ColumnLayout {
                        id: column

                        width: parent.width
                        spacing: 2

                        Label {
                            text: "installationId"
                            font.weight: Font.Bold
                        }

                        TextField {
                            Layout.fillWidth: true
                            text: model.installationId
                            onTextChanged: model.installationId = text
                        }

                        Label {
                            text: "name"
                            font.weight: Font.Bold
                        }

                        TextField {
                            Layout.fillWidth: true
                            text: model.name
                            onTextChanged: model.name = text
                        }

                        Flow {
                            Layout.fillWidth: true

                            CheckBox {
                                text: "isCurrentDevice"
                                checked: model.isCurrentDevice
                                onToggled: model.isCurrentDevice = !model.isCurrentDevice
                            }
                        }

                        Flow {
                            Layout.fillWidth: true

                            CheckBox {
                                text: "enabled"
                                checked: model.enabled
                                onToggled: model.enabled = !model.isCurrentDevice
                            }
                        }
                    }
                }
            }
        }
    }
}
