// Mock of src/app/modules/main/wallet_section/networks/view.nim
import QtQuick 2.15

QtObject {
    readonly property string contextPropertyName: "networksModule"

    //
    // Silence warnings
    readonly property ListModel flatNetworks: ListModel {}
}
