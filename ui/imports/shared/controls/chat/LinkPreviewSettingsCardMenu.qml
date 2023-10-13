import StatusQ.Popups 0.1

StatusMenu {
    id: root

    signal enableLinkPreviewForThisMessage
    signal enableLinkPreview
    signal disableLinkPreview

    hideDisabledItems: false

    StatusAction {
        text: qsTr("Link previews")
        enabled: false
    }

    StatusAction {
        text: qsTr("Show for this message")
        icon.name: "show"
        onTriggered: root.enableLinkPreviewForThisMessage()
    }

    StatusAction {
        text: qsTr("Always show previews")
        icon.name: "show"
        onTriggered: root.enableLinkPreview()
    }

    StatusMenuSeparator { }

    StatusAction {
        text: qsTr("Never show previews")
        icon.name: "hide"
        type: StatusAction.Type.Danger
        onTriggered: root.disableLinkPreview()
    }
}
