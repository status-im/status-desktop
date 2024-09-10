import QtQuick 2.15
import QtQuick.Controls 2.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

StatusBaseText {
    // Fixed height as a workaround for the
    // https://bugreports.qt.io/browse/QTBUG-62411 bug
    // causing improper first item positioning in some cases
    // (overlapping with the section delegate)
    height: 50

    color: Theme.palette.baseColor1
    padding: Style.current.padding
    bottomPadding: 0

    elide: Text.ElideRight
}
