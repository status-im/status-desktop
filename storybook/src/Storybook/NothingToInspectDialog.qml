import QtQuick
import QtQuick.Controls

Dialog {
    id: root

    property string pageName

    anchors.centerIn: Overlay.overlay
    width: contentItem.implicitWidth + leftPadding + rightPadding

    title: "No items to inspect found"
    standardButtons: Dialog.Ok
    modal: true

    contentItem: Label {
        text: '
Tips:\n\
•   For inline components use naming convention of adding\n\
    "Custom" at the begining (like Custom'+root.pageName+')\n\
•   For popups set closePolicy to "Popup.NoAutoClose"\n\
'
    }
}
