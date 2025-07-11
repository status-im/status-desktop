import QtQuick
import QtQuick.Controls

Dialog {
    anchors.centerIn: Overlay.overlay

    title: "Figma token not set"
    standardButtons: Dialog.Ok

    Label {
        text: "Please set Figma personal token in \"Settings\""
    }
}
