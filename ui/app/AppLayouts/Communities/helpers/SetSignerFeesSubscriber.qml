import QtQuick 2.15
/*!
    \qmltype SetSignerFeesSubscriber
    \inherits QtObject
    \brief Helper object that holds the subscriber properties and the published properties for the fee computation.
*/

SingleFeeSubscriber {
    id: root

    required property int chainId
    required property string contractAddress
    required property string accountAddress
    required property bool enabled
}
