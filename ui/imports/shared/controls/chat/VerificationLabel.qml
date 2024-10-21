import QtQuick 2.15

import StatusQ.Core.Theme 0.1

import shared.controls 1.0
import shared 1.0
import shared.panels 1.0

import utils 1.0

SVGImage {
    id: root
    width: visible ?  10 : 0
    height: visible ?  10 : 0

    property int trustStatus: Constants.trustStatus.unknown

    source: {
        switch(trustStatus) {
            case Constants.trustStatus.trusted:
                return Theme.svg("verified");
            case Constants.trustStatus.untrustworthy:
                return Theme.svg("untrustworthy");
            default:
                return "";
        }
    }
}
