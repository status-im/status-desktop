import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import shared.popups

import Storybook

SplitView {

    Item {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        PopupBackground {
            anchors.fill: parent
        }

        Button {
            anchors.centerIn: parent
            text: "Reopen"

            onClicked: popup.open()
        }

        ThirdpartyServicesPopup {
            id: popup

            modal: false
            visible: true
            closePolicy: Popup.CloseOnEscape
            thirdPartyServicesEnabled: ctrlThirdpartyServicesEnabled.checked
            onToggleThirdpartyServicesEnabled: console.warn("onToggleThirdpartyServicesEnabled called ")
            onOpenDiscussPageRequested: console.warn("onOpenDiscussPageRequested called")
            onOpenThirdpartyServicesArticleRequested: console.warn("onOpenThirdpartyServicesArticleRequested called")
        }
    }

    ColumnLayout {
        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 200

        Switch {
            id: ctrlThirdpartyServicesEnabled
            SplitView.minimumWidth: 300
            SplitView.preferredWidth: 300
            text: "Third Party Services Enabled"
            checked: true
        }
    }
}

// category: Popups
// https://www.figma.com/design/idUoxN7OIW2Jpp3PMJ1Rl8/Settings----Desktop-Legacy?node-id=25914-24400&m=dev
