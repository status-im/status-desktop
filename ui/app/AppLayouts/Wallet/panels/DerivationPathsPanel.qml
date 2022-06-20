import QtQuick 2.12
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1

import utils 1.0
import "../stores"

ColumnLayout {
    id: derivationPathSelect

    property string path: ""

    function reset() {
        derivationPathInput.text = _internal.defaultDerivationPath
    }

    QtObject {
        id: _internal
        property var userInputTimer: Timer {
            // 1 second wait after each key press
            interval: 1000
            running: false
            onTriggered: {
                derivationPathSelect.path =  derivationPathInput.text
            }
        }
        property bool pathError: Utils.isInvalidPath(RootStore.derivedAddressesError)
        property bool derivationAddressLoading: RootStore.derivedAddressesLoading
        property string defaultDerivationPath: "m/44'/60'/0'/0"
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
            defaultLeftPadding: 0
            defaultRightPadding: 0
            defaultTopPadding: 0
            defaultBottomPadding: 0
            color: "transparent"
            onClicked: derivationPathSelect.reset()
        }
    }
    StatusBaseInput {
        id: derivationPathInput
        Layout.preferredHeight: Style.dp(64)
        Layout.preferredWidth: parent.width
        text: _internal.defaultDerivationPath
        color: _internal.pathError ? Theme.palette.dangerColor1 : Theme.palette.directColor1
        rightComponent: _internal.derivationAddressLoading ? loadingIcon : loadedIcon

        onTextChanged: _internal.userInputTimer.start()

        Component {
            id: loadedIcon
            StatusIcon {
                icon: _internal.pathError ? "cancel" : "checkmark"
                height: Style.dp(14)
                width: Style.dp(14)
                color: _internal.pathError ? Theme.palette.dangerColor1 : Theme.palette.primaryColor1
            }
        }
        Component {
            id: loadingIcon
            StatusLoadingIndicator {
                color: Theme.palette.directColor4
            }
        }
    }
}

