import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls

Column {
    spacing: 8

    StatusWalletColorSelect {
        model: Theme.palette.userCustomizationColors
    }
}
