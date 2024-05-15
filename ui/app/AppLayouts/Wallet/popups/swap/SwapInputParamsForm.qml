import QtQuick 2.13

import utils 1.0

/* This is used so that there is an easy way to fill in the data
needed to launch the Swap Modal with pre-filled requisites. */
QtObject {
    id: root
    property int selectedAccountIndex: 0
    property int selectedNetworkChainId: -1
    property string fromTokensKey: ""
    property string fromTokenAmount: ""
    property string toTokenKey: ""
}

