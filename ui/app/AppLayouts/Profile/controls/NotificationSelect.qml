import QtQuick 2.13
import QtQuick.Controls 2.13

import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

import utils 1.0

Item {
    id: root

    signal sendAlertsClicked()
    signal deliverQuietlyClicked()
    signal turnOffClicked()

    property string selected: Constants.settingsSection.notifications.sendAlertsValue

    implicitWidth: button.width
    implicitHeight: button.height

    QtObject {
        id: d
        readonly property string sendAlertsText: qsTr("Send Alerts")
        readonly property string deliverQuietlyText: qsTr("Deliver Quietly")
        readonly property string turnOffText: qsTr("Turn Off")
    }

    StatusButton {
        id: button
        text: root.selected === Constants.settingsSection.notifications.turnOffValue? d.turnOffText :
                                                                                      root.selected === Constants.settingsSection.notifications.deliverQuietlyValue? d.deliverQuietlyText :
                                                                                                                                                                     d.sendAlertsText
        icon.name: "chevron-down"

        onClicked: {
            if (selectMenu.opened) {
                selectMenu.close()
            } else {
                selectMenu.popup(button.x, button.y + button.height + 8)
            }
        }
    }

    StatusMenu {
        id: selectMenu
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
        width: parent.width
        clip: true

        StatusAction {
            text: d.sendAlertsText
            onTriggered: {
                root.sendAlertsClicked()
            }
        }

        StatusAction {
            text: d.deliverQuietlyText
            onTriggered: {
                root.deliverQuietlyClicked()
            }
        }

        StatusAction {
            text: d.turnOffText
            onTriggered: {
                root.turnOffClicked()
            }
        }
    }
}
