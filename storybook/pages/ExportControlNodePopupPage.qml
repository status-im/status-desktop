import QtQuick 2.15
import QtQuick.Controls 2.15

import AppLayouts.Communities.popups 1.0

import utils 1.0

import Storybook 1.0

SplitView {
    id: root
    orientation: Qt.Vertical

    Logs { id: logs }

    function openDialog() {
        popupComponent.createObject(popupBg)
    }

    Component.onCompleted: openDialog()

    Item {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        PopupBackground {
            id: popupBg
            anchors.fill: parent

            Button {
                anchors.centerIn: parent
                text: "Reopen"

                onClicked: openDialog()
            }
        }
    }

    ListModel {
        id: fakeDevicesModel
        ListElement {
            name: "Device 1 (osx)"
            deviceType: "osx"
            timestamp: 123456789
            isCurrentDevice: true
            enabled: true
        }
        ListElement {
            name: "Device 2 (windows)"
            deviceType: "windows"
            timestamp: 123456789123
            isCurrentDevice: false
            enabled: false
        }
        ListElement {
            name: "Device 3 (android)"
            deviceType: "android"
            timestamp: 0
            isCurrentDevice: false
            enabled: true
        }
        ListElement {
            name: "Device 4 (ios)"
            deviceType: "ios"
            timestamp: 0
            isCurrentDevice: false
            enabled: true
        }
        ListElement {
            name: "Device 5 (desktop)"
            deviceType: "desktop"
            timestamp: 0
            isCurrentDevice: false
            enabled: true
        }
    }

    Component {
        id: popupComponent
        ExportControlNodePopup {
            id: popup
            anchors.centerIn: parent
            modal: false
            visible: true
            closePolicy: Popup.NoAutoClose
            destroyOnClose: true
            community: QtObject {
                property string id: "1"
                property string name: "Socks"
                property var members: { "count": 5 }
                property string image: Style.png("tokens/UNI")
                property string color: "orchid"
            }
            devicesStore: QtObject {
                function loadDevices() {}

                property bool isDeviceSetup: true

                property var devicesModule: QtObject {
                    property bool devicesLoading
                    property bool devicesLoadingError
                }

                property var devicesModel: ctrlHasSyncedDevices.checked ? fakeDevicesModel : null
            }
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 160

        logsView.logText: logs.logText

        Switch {
            id: ctrlHasSyncedDevices
            text: "Has synced devices"
        }
    }
}

// category: Popups

// https://www.figma.com/file/qHfFm7C9LwtXpfdbxssCK3/Kuba%E2%8E%9CDesktop---Communities?type=design&node-id=36894-685070&mode=design&t=6k1ago8SSQ5Ip9J8-0
// https://www.figma.com/file/qHfFm7C9LwtXpfdbxssCK3/Kuba%E2%8E%9CDesktop---Communities?type=design&node-id=37275-289960&mode=design&t=6k1ago8SSQ5Ip9J8-0
// https://www.figma.com/file/qHfFm7C9LwtXpfdbxssCK3/Kuba%E2%8E%9CDesktop---Communities?type=design&node-id=37275-290036&mode=design&t=6k1ago8SSQ5Ip9J8-0
