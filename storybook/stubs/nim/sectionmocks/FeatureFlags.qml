// Mock of src/app/global/feature_flags.nim
import QtQuick 2.15

QtObject {
    readonly property string contextPropertyName: "featureFlagsRootContextProperty"

    //
    // Silence warnings
    readonly property bool dappsEnabled: true
}
