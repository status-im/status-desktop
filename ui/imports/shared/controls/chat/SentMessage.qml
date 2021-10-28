import QtQuick 2.3
import shared.panels 1.0

import utils 1.0

SVGImage {
    id: sentMessage
    width: visible ? 9 : 0
    height: visible ? 9 : 0
    source: visible ? Style.svg("check") : ""
}
