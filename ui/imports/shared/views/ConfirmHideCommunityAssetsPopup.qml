import shared.popups

ConfirmationDialog {
    required property string name
    required property string icon

    width: 520

    confirmButtonLabel: qsTr("Hide '%1' assets").arg(name)
    cancelBtnType: ""
    showCancelButton: true
    headerSettings.title: qsTr("Hide %1 community assets").arg(name)
    headerSettings.asset.name: icon
    confirmationText: qsTr("Are you sure you want to hide all community assets minted by %1? You will no longer see or be able to interact with these assets anywhere inside Status.").arg(name)

    onCancelButtonClicked: close()
}
