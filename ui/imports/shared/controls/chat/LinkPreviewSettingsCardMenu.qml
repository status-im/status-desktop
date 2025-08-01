import StatusQ.Popups

StatusMenu {
    id: root

    signal enableLinkPreviewForThisMessage
    signal enableLinkPreview
    signal disableLinkPreview

    hideDisabledItems: false

    StatusMenuHeadline {
        text: qsTr("Link previews")
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
