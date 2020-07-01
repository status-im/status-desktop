import QtQuick 2.13

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
            genKeyView.onClosed()
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;formeditorColor:"#ffffff";height:480;width:640}
}
##^##*/
