import shared.popups

ConfirmationDialog {
    required property string symbol
    required property string name
    required property string icon

    width: 520

    confirmButtonLabel: qsTr("Hide asset")
    cancelBtnType: ""
    showCancelButton: true
    headerSettings.title: qsTr("Hide %1 (%2)").arg(name).arg(symbol)
    headerSettings.asset.name: icon
    confirmationText: qsTr("Are you sure you want to hide %1 (%2)? You will no longer see or be able to interact with this asset anywhere inside Status.")
        .arg(name).arg(symbol)

    onCancelButtonClicked: close()
}
