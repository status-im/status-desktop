import QtQuick 2.14
import QtQuick.Layouts 1.14
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1

GridLayout {
    columns: 6
    columnSpacing: 5
    rowSpacing: 5
    property ThemePalette theme

    StatusLoadingIndicator {
        color: parent.theme.directColor4
    }

    StatusLetterIdenticon {
        name: "#status"
    }
}
