import QtQuick
/*!
    \qmltype DeployFeesSubscriber
    \inherits QtObject
    \brief Helper object that holds the subscriber properties and the published properties for the fee computation.
*/

SingleFeeSubscriber {
    id: root

    required property string communityId
    required property int chainId
    required property int tokenType
    required property bool isOwnerDeployment
    required property string accountAddress
    required property bool enabled

    property var ownerToken
    property var masterToken
    property var token
}
