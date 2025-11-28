import QtQuick

import StatusQ.Core.Theme

import shared.controls
import shared
import shared.panels

import utils

SVGImage {
    id: root
    width: visible ?  10 : 0
    height: visible ?  10 : 0

    property int trustStatus: Constants.trustStatus.unknown

    source: {
        switch(trustStatus) {
            case Constants.trustStatus.trusted:
                return Assets.svg("verified");
            case Constants.trustStatus.untrustworthy:
                return Assets.svg("untrustworthy");
            default:
                return "";
        }
    }
}
