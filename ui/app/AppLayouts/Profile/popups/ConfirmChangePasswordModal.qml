import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.12
import QtQml.Models 2.15


import utils 1.0
import shared 1.0
import shared.views 1.0
import shared.panels 1.0
import shared.controls 1.0
import shared.stores 1.0

import StatusQ.Core 0.1
import StatusQ.Popups.Dialog 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

import "../views"

StatusDialog {
    id: root

    signal changePasswordRequested()
    // Currently this modal handles only the happy path
    // The error is handled in the caller
    function passwordSuccessfulyChanged() {
        d.dbEncryptionInProgress = false;
        d.passwordChanged = true;
    }

    QtObject {
        id: d

        function reset() {
            d.dbEncryptionInProgress = false;
            d.passwordChanged = false;
        }

        property bool passwordChanged: false
        property bool dbEncryptionInProgress: false
    }

    onClosed: {
        d.reset();
    }

    width: 480
    height: 546
    closePolicy: d.passwordChanged ||  d.dbEncryptionInProgress ? Popup.NoAutoClose : Popup.CloseOnEscape | Popup.CloseOnPressOutside

    Column {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 20
        StatusBaseText {
            width: parent.width
            wrapMode: Text.WordWrap
            text: qsTr("Your data must now be re-encrypted with your new password. This process may take some time, during which you won’t be able to interact with the app. Do not quit the app or turn off your device. Doing so will lead to data corruption, loss of your Status profile and the inability to restart Status.")
        }

        Item {
            width: parent.width
            height: 76

            Rectangle {
                anchors.fill: parent
                visible: d.passwordChanged
                border.color: Theme.palette.successColor1
                color: Theme.palette.successColor1
                radius: 8
                opacity: .1
            }

            StatusListItem {
                id: listItem
                anchors.fill: parent
                sensor.enabled: false
                visible: (d.dbEncryptionInProgress || d.passwordChanged)
                title: !d.dbEncryptionInProgress ? qsTr("Re-encryption complete") :
                                                   qsTr("Re-encrypting your data with your new password...")
                subTitle: !d.dbEncryptionInProgress ? qsTr("Restart Status and log in using your new password") :
                                                      qsTr("Do not quit the app of turn off your device")
                statusListItemSubTitle.customColor: !d.passwordChanged ? Style.current.red : Theme.palette.successColor1
                statusListItemIcon.active: d.passwordChanged
                asset.name: "checkmark-circle"
                asset.width: 24
                asset.height: 24
                asset.bgWidth: 0
                asset.bgHeight: 0
                asset.color: Theme.palette.successColor1
                showLoadingIndicator: (d.dbEncryptionInProgress && !d.passwordChanged)
                asset.isLetterIdenticon: false
                border.width: !d.passwordChanged ? 1 : 0
                border.color: Theme.palette.baseColor5
                color: d.passwordChanged ? "transparent" : bgColor
            }
        }
    }

    header: StatusDialogHeader {
        visible: true
        headline.title: qsTr("Change password")
        actions.closeButton.visible: !(d.passwordChanged ||  d.dbEncryptionInProgress)
        actions.closeButton.onClicked: root.close()
    }

    footer: StatusDialogFooter {
        id: footer
        leftButtons: ObjectModel {
            StatusFlatButton {
                text: qsTr("Cancel")  
                visible: !d.dbEncryptionInProgress && !d.passwordChanged
                textColor: Style.current.darkGrey
                onClicked: { root.close(); }
            }
        }
        rightButtons: ObjectModel {
            StatusButton {
                id: submitBtn
                objectName: "changePasswordModalSubmitButton"
                text: !d.dbEncryptionInProgress && !d.passwordChanged ? qsTr("Re-encrypt data using new password") : qsTr("Restart status")
                enabled: !d.dbEncryptionInProgress
                onClicked: {
                    if (d.passwordChanged) {
                        Utils.restartApplication();
                    } else {
                        d.dbEncryptionInProgress = true
                        root.changePasswordRequested()
                    }
                }
            }
        }
    }
}
