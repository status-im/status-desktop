import QtQuick 2.15
import QtQuick.Controls 2.15

Dialog {
    anchors.centerIn: Overlay.overlay

    title: "Figma token not set"
    standardButtons: Dialog.Ok

    Label {
        text: "Please set Figma personal token in \"Settings\""
    }
}
