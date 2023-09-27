import QtQuick 2.15
/*!
    \qmltype SelfDestructFeesSubscriber
    \inherits QtObject
    \brief Helper object that holds the subscriber properties and the published properties for the fee computation.
*/

SingleFeeSubscriber {
    id: root

    required property string tokenKey
    /**
    * walletsAndAmounts - array of following structure is expected:
    * [
    *   {
    *      walletAddress: string
    *      amount: int
    *   }
    * ]
    */
    required property var walletsAndAmounts
    required property string accountAddress
    required property bool enabled
}
