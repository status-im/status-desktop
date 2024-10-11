import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import AppLayouts.Profile.popups 1.0

import Storybook 1.0

SplitView {
    PopupBackground {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        Button {
            id: reopenButton
            anchors.centerIn: parent
            text: "Reopen"

            onClicked: modal.open()
        }

        ConfirmChangePasswordModal {
            id: modal

            visible: true
            modal: false

            onChangePasswordRequested: passwordChangedTimer.start()

            Timer {
                id: passwordChangedTimer

                interval: 2000
                repeat: false
                onTriggered: {
                    if (successFlow.checked) {
                        modal.passwordSuccessfulyChanged()
                    } else {
                        modal.close()
                    }
                }
            }
        }
    }

    LogsAndControlsPanel {
        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 200
        SplitView.preferredWidth: 300

        ColumnLayout {
            CheckBox {
                id: successFlow
                text: "%1 in 2 seconds".arg(successFlow.checked ? "Success" : "Error")
                checked: true
            }
        }
    }
}

// category: Popups

// https://www.figma.com/file/d0G7m8X6ELjQlFOEKQpn1g/Profile-WIP?type=design&node-id=11-111195&mode=design&t=j3guZtz78wkceVda-0
