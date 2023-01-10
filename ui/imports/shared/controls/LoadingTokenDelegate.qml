import QtQuick 2.13
import QtQuick.Controls 2.13

import StatusQ.Popups 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Controls 0.1

import utils 1.0

TokenDelegate {
    id: root

    title: Constants.dummyText
    subTitle: Constants.dummyText
    asset.name: Constants.dummyText
    change24HourPercentage.text: Constants.dummyText
    change24Hour.text: Constants.dummyText
    localeCurrencyBalance.text: Constants.dummyText
    statusListItemSubTitle.loading: true
    statusListItemTitle.loading: true
    statusListItemIcon.loading: true
    change24HourPercentage.loading: true
    change24Hour.loading: true
    localeCurrencyBalance.loading: true
    textColor: Theme.palette.baseColor1
}
