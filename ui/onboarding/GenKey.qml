import QtQuick 2.3
import QtQuick.Controls 2.4
import QtQuick.Layouts 1.11
import QtQuick.Window 2.11
import QtQuick.Dialogs 1.3
import "../imports"
import "../shared"

Item {
    property var onClosed: function () {}
    id: genKeyView
    anchors.fill: parent

    Component.onCompleted: {
        genKeyModal.open()
    }

    GenKeyModal {
        property bool wentNext: false
        id: genKeyModal
        onNextClick: function (selectedIndex) {
            wentNext = true
            onboardingModel.setCurrentAccount(selectedIndex)
            createPasswordModal.open()
        }
        onClosed: function () {
            if (!wentNext) {
                genKeyView.onClosed()
            }
        }
    }

    CreatePasswordModal {
        id: createPasswordModal
        onClosed: function () {
            existingKeyView.onClosed()
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;formeditorColor:"#ffffff";height:480;width:640}
}
##^##*/

