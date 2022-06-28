import QtQuick 2.3
import shared.controls 1.0
import shared 1.0
import shared.panels 1.0

import utils 1.0

SVGImage {
    id: root
    width: 10
    height: 10

    property int trustStatus: Constants.trustStatus.unknown

    source: {
        switch(trustStatus) {
            case Constants.trustStatus.trusted:
                return Style.svg("verified");
            case Constants.trustStatus.untrustworthy:
                return Style.svg("untrustworthy");
            default:
                return "";
        }
    }
}