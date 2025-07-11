import QtQuick
/*!
    \qmltype BurnTokenFeesSubscriber
    \inherits QtObject
    \brief Helper object that holds the subscriber properties and the published properties for the fee computation.
*/

SingleFeeSubscriber {
    id: root

    required property string tokenKey
    required property string amount
    required property string accountAddress
    required property bool enabled
}
