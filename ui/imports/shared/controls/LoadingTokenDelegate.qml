import QtQuick 2.15

import StatusQ.Core.Theme 0.1

import utils 1.0

TokenDelegate {
    id: root

    title: Constants.dummyText
    subTitle: Constants.dummyText
    asset.name: Constants.dummyText

    currencyBalance.text: Constants.dummyText
    currencyBalance.loading: true
    change24HourPercentage.text: Constants.dummyText
    change24HourPercentage.loading: true
    currencyPrice.text: Constants.dummyText
    currencyPrice.loading: true

    statusListItemSubTitle.loading: true
    statusListItemTitle.loading: true
    statusListItemIcon.loading: true

    textColor: Theme.palette.baseColor1
    enabled: false
}
