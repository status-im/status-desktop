// Mock of src/app/modules/main/wallet_section/networks/view.nim
import QtQuick 2.15

QtObject {
    readonly property string contextPropertyName: "networksModule"

    //
    // Silence warnings
    readonly property ListModel layer1: ListModel {}
    readonly property ListModel layer2: ListModel {}
    readonly property ListModel enabled: ListModel {}
    readonly property ListModel all: ListModel {}
}