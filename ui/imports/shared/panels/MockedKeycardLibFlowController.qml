import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Controls 0.1

RowLayout {
    id: root

    property var relatedModule

    StatusButton {
        text: qsTr("Plugin R")

        onClicked: {
            if (!!root.relatedModule) {
                root.relatedModule.pluginMockedReaderAction()
            }
        }
    }

    StatusButton {
        text: qsTr("Unplug R")

        onClicked: {
            if (!!root.relatedModule) {
                root.relatedModule.unplugMockedReaderAction()
            }
        }
    }

    StatusButton {
        text: qsTr("Ins Kc 1")

        onClicked: {
            if (!!root.relatedModule) {
                root.relatedModule.insertMockedKeycardAction(1)
            }
        }
    }

    StatusButton {
        text: qsTr("Ins Kc 2")

        onClicked: {
            if (!!root.relatedModule) {
                root.relatedModule.insertMockedKeycardAction(2)
            }
        }
    }

    StatusButton {
        text: qsTr("Remove Kc")

        onClicked: {
            if (!!root.relatedModule) {
                root.relatedModule.removeMockedKeycardAction()
            }
        }
    }

    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: 1
    }
}
