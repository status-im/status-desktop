import QtQuick 2.12
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Controls.Validators 0.1
import StatusQ.Components 0.1

import utils 1.0
import "../stores"

ColumnLayout {
    id: derivationPathSelect

    property string path: ""
    property bool useFullyCustomPath: true

    function reset() {
        if (derivationPathSelect.useFullyCustomPath) {
            derivationPathFullyCustomInput.text = _internal.customDerivationRootPath
        }
        else {
            derivationPathStatusDefaultInput.text = _internal.defaultDerivationIndex
        }
        if (!_internal.userInputTimer.running) {
            _internal.userInputTimer.start()
        }
    }

    QtObject {
        id: _internal
        readonly property string defaultDerivationIndex: "1"
        property var userInputTimer: Timer {
            // 1 second wait after each key press
            interval: 1000
            running: false
            onTriggered: {
                if (derivationPathSelect.useFullyCustomPath) {
                    derivationPathSelect.path = derivationPathFullyCustomInput.text
                }
                else {
                    if (derivationPathStatusDefaultInput.text === "") {
                        return
                    }
                    derivationPathSelect.path = _internal.defaultDerivationRootPath + derivationPathStatusDefaultInput.text
                }
            }
        }
        property bool pathError: Utils.isInvalidPath(RootStore.derivedAddressesError)
        property bool derivationAddressLoading: RootStore.derivedAddressesLoading
        property string customDerivationRootPath: "m/44'/60'/0'/0"
        property string defaultDerivationRootPath: "m/44'/60'/0'/0/"
    }

    Component {
        id: loadedIcon
        StatusIcon {
            icon: _internal.pathError ? "cancel" : "checkmark"
            height: 14
            width: 14
            color: _internal.pathError ? Theme.palette.dangerColor1 : Theme.palette.primaryColor1
        }
    }
    Component {
        id: loadingIcon
        StatusLoadingIndicator {
            color: Theme.palette.directColor4
        }
    }

    Component {
        id: fixedLeftPart
        StatusBaseText {
            rightPadding: 0
            text: _internal.defaultDerivationRootPath
            color: Theme.palette.baseColor1
            font: derivationPathStatusDefaultInput.font
        }
    }

    spacing: 7

    RowLayout {
        StatusBaseText {
            id: inputLabel
            Layout.alignment: Qt.AlignTop
            Layout.fillWidth: true
            text: qsTr("Derivation Path")
            font.pixelSize: 15
        }
        StatusButton {
            id: resetButton
            Layout.alignment: Qt.AlignTop
            size: StatusBaseButton.Size.Tiny
            text: qsTr("Reset")
            font.pixelSize: 15
            padding: 0
            normalColor: "transparent"
            onClicked: derivationPathSelect.reset()
        }
    }
    StatusInput {
        id: derivationPathFullyCustomInput
        Layout.preferredHeight: 64
        Layout.preferredWidth: parent.width
        visible: derivationPathSelect.useFullyCustomPath
        maximumHeight: 64
        text: _internal.customDerivationRootPath
        input.color: _internal.pathError ? Theme.palette.dangerColor1 : Theme.palette.directColor1
        input.rightComponent: _internal.derivationAddressLoading ? loadingIcon : loadedIcon
        onTextChanged: _internal.userInputTimer.start()
    }
    StatusInput {
        id: derivationPathStatusDefaultInput
        Layout.preferredHeight: 64
        Layout.preferredWidth: parent.width
        visible: !derivationPathSelect.useFullyCustomPath
        maximumHeight: 64
        text: _internal.defaultDerivationIndex
        input.color: _internal.pathError ? Theme.palette.dangerColor1 : Theme.palette.directColor1
        input.rightComponent: _internal.derivationAddressLoading ? loadingIcon : loadedIcon
        input.leftComponent: fixedLeftPart
        onTextChanged: _internal.userInputTimer.start()
        validationMode: StatusInput.ValidationMode.IgnoreInvalidInput
        validators: [
            StatusRegularExpressionValidator {
                regularExpression: /^[0-9]{0,9}$/
                errorMessage: ""
            }
        ]
    }
}

