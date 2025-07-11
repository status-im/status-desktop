import QtQuick
import QtQuick.Controls

import StatusQ.Core
import StatusQ.Core.Theme

import utils

StatusBaseText {
    // Fixed height as a workaround for the
    // https://bugreports.qt.io/browse/QTBUG-62411 bug
    // causing improper first item positioning in some cases
    // (overlapping with the section delegate)
    height: 50

    color: Theme.palette.baseColor1
    padding: Theme.padding
    bottomPadding: 0

    elide: Text.ElideRight
}
