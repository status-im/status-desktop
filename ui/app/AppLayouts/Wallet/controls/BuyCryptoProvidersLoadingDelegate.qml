import QtQuick 2.15

import utils 1.0

BuyCryptoProvidersDelegate {
    name: Constants.dummyText
    logoUrl: Constants.dummyText
    urlsNeedParameters: false
    fees: Constants.dummyText

    statusListItemSubTitle.loading: true
    statusListItemTitle.loading: true
    statusListItemIcon.loading: true

    loading: true
    enabled: false
}
