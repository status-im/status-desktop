import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"

ModalPopup {
    id: popup
    title: qsTr("Fleet")

    property string newFleet: "";
    
    Column {
        id: column
        spacing: Style.current.padding
        width: parent.width

        ConfirmationDialog {
            id: confirmDialog
            title: qsTr("Warning!")
            confirmationText: qsTr("Change fleet to %1").arg(newFleet)
            onConfirmButtonClicked: profileModel.fleets.setFleet(newFleet)

            onClosed: {
                let currFleet = profileModel.fleets.fleet
                radioProd.checked = currFleet == Constants.eth_prod
                radioStaging.checked = currFleet == Constants.eth_staging
                radioTest.checked = currFleet == Constants.eth_test
            }
        }

        ButtonGroup { id: fleetSettings }

        RowLayout {
            width: parent.width
            StyledText {
                text: Constants.eth_prod
                font.pixelSize: 15
            }
            StatusRadioButton {
                id: radioProd
                Layout.alignment: Qt.AlignRight
                ButtonGroup.group: fleetSettings
                rightPadding: 0
                checked: profileModel.fleets.fleet === Constants.eth_prod
                onClicked: {
                    if (profileModel.fleets.fleet === Constants.eth_prod) return;
                    newFleet = Constants.eth_prod;
                    confirmDialog.open();
                }
            }
        }

        RowLayout {
            width: parent.width
            StyledText {
                text: Constants.eth_staging
                font.pixelSize: 15
            }
            StatusRadioButton {
                id: radioStaging
                Layout.alignment: Qt.AlignRight
                ButtonGroup.group: fleetSettings
                rightPadding: 0
                checked: profileModel.fleets.fleet === Constants.eth_staging
                onClicked: {
                    if (profileModel.fleets.fleet === Constants.eth_staging) return;
                    newFleet = Constants.eth_staging;
                    confirmDialog.open();
                }
            }
        }

        RowLayout {
            width: parent.width
            StyledText {
                text: Constants.eth_test
                font.pixelSize: 15
            }
            StatusRadioButton {
                id: radioTest
                Layout.alignment: Qt.AlignRight
                ButtonGroup.group: fleetSettings
                rightPadding: 0
                checked: profileModel.fleets.fleet === Constants.eth_test
                onClicked: {
                    if (profileModel.fleets.fleet === Constants.eth_test) {
                        return;
                    }
                    newFleet = Constants.eth_test;
                    confirmDialog.open();
                }
            }
        }
    }
}
