pragma Singleton

import QtQuick 2.15

import StatusQ.Internal 0.1 as Internal

QtObject {
    function escapeHtml(unsafe) {
        return Internal.StringUtils.escapeHtml(unsafe)
    }
}
