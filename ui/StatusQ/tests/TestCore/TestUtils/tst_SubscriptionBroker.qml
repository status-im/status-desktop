import QtQuick 2.15
import QtTest 1.0

import StatusQ.Core.Utils 0.1

import StatusQ.TestHelpers 0.1

TestCase {
    id: testCase
    name: "SubscriptionBroker"

    Component {
        id: subscriptionBrokerComponent
        SubscriptionBroker {
            id: subscriptionBroker

            //Signal spies
            readonly property SignalSpy requestSignalSpy: SignalSpy {
                target: subscriptionBroker
                signalName: "request"
            }
            readonly property SignalSpy subscribedSignalSpy: SignalSpy {
                target: subscriptionBroker
                signalName: "subscribed"
            }
            readonly property SignalSpy unsubscribedSignalSpy: SignalSpy {
                target: subscriptionBroker
                signalName: "unsubscribed"
            }
        }
    }

    Component {
        id: subscriptionComponent
        Subscription {
            id: subscription
        }
    }

    MonitorQtOutput {
        id: qtOuput
    }

    function init() {
        qtOuput.restartCapturing()
    }

    function test_new_instance() {
        const subscriptionBroker = createTemporaryObject(subscriptionBrokerComponent, testCase)
        verify(qtOuput.qtOuput().length === 0, `No output expected. Found:\n"${qtOuput.qtOuput()}"\n`)
        verify(subscriptionBroker.active, "SubscriptionBroker should be active by default")
        verify(subscriptionBroker.requestSignalSpy.valid == true, "request signal should be defined")
        verify(subscriptionBroker.subscribedSignalSpy.valid == true, "subscribed signal should be defined")
        verify(subscriptionBroker.unsubscribedSignalSpy.valid == true, "unsubscribed signal should be defined")
        verify(subscriptionBroker.response != undefined, "response function should be defined")
        verify(subscriptionBroker.subscribe != undefined, "subscribe function should be defined")
        verify(subscriptionBroker.unsubscribe != undefined, "unsubscribe function should be defined")
    }

    function test_subscribe_invalid_subscription() {
        const subscriptionBroker = createTemporaryObject(subscriptionBrokerComponent, testCase)
        subscriptionBroker.subscribe(undefined)
        compare(qtOuput.qtOuput().length, 0, `No output expected. Found:\n"${qtOuput.qtOuput()}"\n`)
        compare(subscriptionBroker.requestSignalSpy.count, 0, "request signal should not be emitted")
        compare(subscriptionBroker.subscribedSignalSpy.count, 0, "subscribed signal should not be emitted")
        compare(subscriptionBroker.unsubscribedSignalSpy.count, 0, "unsubscribed signal should not be emitted")

        const subscriptionAsEmptyObject = {}
        subscriptionBroker.subscribe(subscriptionAsEmptyObject)

        compare(qtOuput.qtOuput().length, 0, `No output expected. Found:\n"${qtOuput.qtOuput()}"\n`)
        compare(subscriptionBroker.requestSignalSpy.count, 0, "request signal should not be emitted")
        compare(subscriptionBroker.subscribedSignalSpy.count, 0, "subscribed signal should not be emitted")
        compare(subscriptionBroker.unsubscribedSignalSpy.count, 0, "unsubscribed signal should not be emitted")
    }

    function test_subscribe_valid_subscription_object() {
        const subscriptionBroker = createTemporaryObject(subscriptionBrokerComponent, testCase)
        const subscription = createTemporaryObject(subscriptionComponent, testCase)
        verify(subscription.subscriptionId != "", "subscription should have an id")

        subscriptionBroker.subscribe(subscription)
        compare(qtOuput.qtOuput().length, 0, `No output expected. Found:\n"${qtOuput.qtOuput()}"\n`)
        compare(subscriptionBroker.subscribedSignalSpy.count, 1, "subscribed signal should be emitted")
        compare(subscriptionBroker.subscribedSignalSpy.signalArguments[0][0], subscription.subscriptionId, "subscribed signal should be emitted with the subscription id")
        compare(subscriptionBroker.unsubscribedSignalSpy.count, 0, "unsubscribed signal should not be emitted")
        compare(subscriptionBroker.requestSignalSpy.count, 0, "request signal should not be emitted. Subscription is inactive by default. Broker is inactive by default.")
        
        subscriptionBroker.unsubscribe(subscription.subscriptionId)
        compare(subscriptionBroker.subscribedSignalSpy.count, 1, "subscribed signal should not be emitted for unsunbscribe")
        compare(subscriptionBroker.unsubscribedSignalSpy.count, 1, "unsubscribed signal should be emitted")
        compare(subscriptionBroker.unsubscribedSignalSpy.signalArguments[0][0], subscription.subscriptionId, "unsubscribed signal should be emitted with the subscription id")
        compare(subscriptionBroker.requestSignalSpy.count, 0, "request signal should not be emitted")
    }

    function test_periodic_request_one_subscription() {
        const subscriptionBroker = createTemporaryObject(subscriptionBrokerComponent, testCase)
        const subscription = createTemporaryObject(subscriptionComponent, testCase, {topic: "topic1", isReady: true, notificationInterval: 50})

        //Enable broker and subscription
        //Verify that request signal is emitted after subscription
        subscriptionBroker.active = true
        subscriptionBroker.subscribe(subscription)
        compare(subscriptionBroker.subscribedSignalSpy.count, 1, "subscribed signal should be emitted")
        compare(subscriptionBroker.requestSignalSpy.count, 1, "request signal should be emitted")
        compare(subscriptionBroker.requestSignalSpy.signalArguments[0][0], subscription.topic, "request signal should be emitted with the subscription topic")

        //Verify that request signal is emitted after notificationInterval
        //The broker expects a response before sending another request
        subscriptionBroker.response(subscription.topic, "responseAsString")
        compare(subscription.response, "responseAsString", "subscription response should be updated")

        //first interval - check for one request every 50ms:
        compare(subscriptionBroker.requestSignalSpy.count, 1, "request signal should not be emitted")
        tryCompare(subscriptionBroker.requestSignalSpy, "count", 2, 90 /*40ms error margin*/, "request signal should be emitted after 50ms. Actual signal count: " + subscriptionBroker.requestSignalSpy.count)
        compare(subscriptionBroker.requestSignalSpy.signalArguments[1][0], subscription.topic, "request signal should be emitted with the subscription topic")

        subscriptionBroker.response(subscription.topic, "responseAsString2")
        compare(subscription.response, "responseAsString2", "subscription response should be updated")

        //second interval - check for one request every 50ms:
        compare(subscriptionBroker.requestSignalSpy.count, 2, "request was emitted before 50ms interval")
        tryCompare(subscriptionBroker.requestSignalSpy, "count", 3, 90 /*40ms error margin*/, "request signal should be emitted after 50ms")
        compare(subscriptionBroker.requestSignalSpy.signalArguments[2][0], subscription.topic, "request signal should be emitted with the subscription topic")
        subscriptionBroker.response(subscription.topic, "responseAsString3")

        //Verify the request is not sent again after unsubscribe
        subscriptionBroker.unsubscribe(subscription.subscriptionId)
        compare(subscriptionBroker.subscribedSignalSpy.count, 1, "subscribed signal should not be emitted for unsunbscribe")
        compare(subscriptionBroker.unsubscribedSignalSpy.count, 1, "unsubscribed signal should be emitted")
        compare(subscriptionBroker.unsubscribedSignalSpy.signalArguments[0][0], subscription.subscriptionId, "unsubscribed signal should be emitted with the subscription id")
        compare(subscriptionBroker.requestSignalSpy.count, 3, "request signal should not be emitted on unsubscribe")
        wait(90)/*40ms error margin*/
        compare(subscriptionBroker.requestSignalSpy.count, 3, "request signal should not be emitted again after unsubscribe")

        //Verify the request is not sent again after disabling the broker
        subscriptionBroker.subscribe(subscription)
        compare(subscriptionBroker.subscribedSignalSpy.count, 2, "subscribed signal should be emitted")
        compare(subscriptionBroker.requestSignalSpy.count, 4, "request signal should be emitted on subscribe")
        subscriptionBroker.response(subscription.topic, "responseAsString4")
        tryCompare(subscriptionBroker.requestSignalSpy, "count", 5, 90 /*40ms error margin*/, "request signal should be emitted")
        subscriptionBroker.response(subscription.topic, "responseAsString5")

        subscriptionBroker.active = false
        compare(subscriptionBroker.requestSignalSpy.count, 5, "request signal should not be emitted after disabling the broker")
        wait(90)/*40ms error margin*/
        compare(subscriptionBroker.requestSignalSpy.count, 5, "request signal should not be emitted again after disabling the broker")

        //Verify the request can be unsubsribed with a disabled broker
        subscriptionBroker.unsubscribe(subscription.subscriptionId)
        compare(subscriptionBroker.subscribedSignalSpy.count, 2, "subscribed signal should not be emitted for unsunbscribe")
        compare(subscriptionBroker.unsubscribedSignalSpy.count, 2, "unsubscribed signal should be emitted")
        compare(subscriptionBroker.unsubscribedSignalSpy.signalArguments[1][0], subscription.subscriptionId, "unsubscribed signal should be emitted with the subscription id")
        compare(subscriptionBroker.requestSignalSpy.count, 5, "request signal should not be emitted on unsubscribe")

        //Verify the request can be subscribed with a disabled broker
        subscriptionBroker.subscribe(subscription)
        compare(subscriptionBroker.subscribedSignalSpy.count, 3, "subscribed signal should be emitted")
        compare(subscriptionBroker.requestSignalSpy.count, 5, "request signal should not be emitted on subscribe")
        wait(90)/*40ms error margin*/
        compare(subscriptionBroker.requestSignalSpy.count, 5, "request signal should not be emitted with a disabled broker")

        //verify the request is sent after enabling the broker
        subscriptionBroker.active = true
        tryCompare(subscriptionBroker.requestSignalSpy, "count", 6, 1/*allow the event loop to be processed and the subscriptionBroker.active = true to be processed */, "request signal should be emitted after enabling the broker")
    }

    function test_periodic_request_multiple_subscriptions() {
        const subscriptionBroker = createTemporaryObject(subscriptionBrokerComponent, testCase)
        const subscription1 = createTemporaryObject(subscriptionComponent, testCase, {topic: "topic1", isReady: true, notificationInterval: 50}) //10 requests in 500ms
        const subscription2 = createTemporaryObject(subscriptionComponent, testCase, {topic: "topic2", isReady: true, notificationInterval: 90}) //5 requests in 500ms
        const subscription3 = createTemporaryObject(subscriptionComponent, testCase, {topic: "topic3", isReady: true, notificationInterval: 130}) //3 requests in 500ms
        const subscription4 = createTemporaryObject(subscriptionComponent, testCase, {topic: "topic4", isReady: true, notificationInterval: 170}) //2 requests in 500ms
        const subscription5 = createTemporaryObject(subscriptionComponent, testCase, {topic: "topic5", isReady: true, notificationInterval: 210}) //2 requests in 500ms
                                                                                                                                                  //TOTAL: 22 requests in 500ms
        var subscription1RequestTimestamp = 0
        var subscription2RequestTimestamp = 0
        var subscription3RequestTimestamp = 0
        var subscription4RequestTimestamp = 0
        var subscription5RequestTimestamp = 0

        var requestCount = 0
        subscriptionBroker.request.connect(function(topic) {
            //sending a unique response for each request
            subscriptionBroker.response(topic, "responseAsString" + Date.now())
        })

        //Enable broker and subscription
        subscriptionBroker.active = true
        subscriptionBroker.subscribe(subscription1)
        subscriptionBroker.subscribe(subscription2)
        subscriptionBroker.subscribe(subscription3)
        subscriptionBroker.subscribe(subscription4)
        subscriptionBroker.subscribe(subscription5)

        //Make sure the interval difference between the subscriptions is at least 30ms
        //This is to make sure interval computation deffects are not hidden by the error margin
        //The usual error margin on Timer is < 10 ms. Setting it to 30 ms should be enough
        const requestIntervalErrorMargin = 30

        subscription1.responseChanged.connect(function() {
            if(subscription1RequestTimestamp !== 0)
                fuzzyCompare(Date.now() - subscription1RequestTimestamp, subscription1.notificationInterval, requestIntervalErrorMargin, "subscription1 request should be sent after notificationInterval")
           
            subscription1RequestTimestamp = Date.now()
        })
        subscription2.responseChanged.connect(function() {
            if(subscription2RequestTimestamp !== 0)
                fuzzyCompare(Date.now() - subscription2RequestTimestamp, subscription2.notificationInterval, requestIntervalErrorMargin, "subscription2 request should be sent after notificationInterval")

            subscription2RequestTimestamp = Date.now()
        })
        subscription3.responseChanged.connect(function() {
            if(subscription3RequestTimestamp !== 0)
                fuzzyCompare(Date.now() - subscription3RequestTimestamp, subscription3.notificationInterval, requestIntervalErrorMargin, "subscription3 request should be sent after notificationInterval")

            subscription3RequestTimestamp = Date.now()
        })
        subscription4.responseChanged.connect(function() {
            if(subscription4RequestTimestamp !== 0)
                fuzzyCompare(Date.now() - subscription4RequestTimestamp, subscription4.notificationInterval, requestIntervalErrorMargin, "subscription4 request should be sent after notificationInterval")

            subscription4RequestTimestamp = Date.now()
        })
        subscription5.responseChanged.connect(function() {
            if(subscription5RequestTimestamp !== 0)
                fuzzyCompare(Date.now() - subscription5RequestTimestamp, subscription5.notificationInterval, requestIntervalErrorMargin, "subscription5 request should be sent after notificationInterval")

            subscription5RequestTimestamp = Date.now()
        })


        ///Verify the request is sent periodically for 500 ms
        ///The test is fuzzy because the timer is not precise
        ///After each wait() the test error margin increases

        //We should have 27 requests in 500ms. Adding an error margin of 100ms => 600ms total
        tryVerify(() => subscriptionBroker.requestSignalSpy.count > 26, 600, "request signal should be emitted  more than 27 times. Actual: " + subscriptionBroker.requestSignalSpy.count)

        //Disable one subscription and verify the request count is reduced
        subscription5.isReady = false
        subscription4.isReady = false

        let previousRequestCount = subscriptionBroker.requestSignalSpy.count

        //We should have 18 requests in 500ms. Adding an error margin of 100ms => 600ms total
        tryVerify(() => subscriptionBroker.requestSignalSpy.count > previousRequestCount + 17/*fuzzy compare. Exact number should be 18*/, 600, "request signal should be emitted more than 14 times. Actual: " + subscriptionBroker.requestSignalSpy.count)

        previousRequestCount = subscriptionBroker.requestSignalSpy.count

        //Leave just one subscription and verify the request count is reduced
        subscription3.isReady = false
        subscription2.isReady = false

        //We should have 10 requests in 500ms. Adding an error margin of 100ms => 600ms total
        tryVerify(() => subscriptionBroker.requestSignalSpy.count > previousRequestCount + 9 /*fuzzy compare. Exact number should be 10*/, 600, "request signal should be emitted more than 8 times. Actual: " + subscriptionBroker.requestSignalSpy.count)
    }

    //Testing how the subscription broker handles the topic changes
    function test_topic_changes() {
        const subscriptionBroker = createTemporaryObject(subscriptionBrokerComponent, testCase)
        const subscription1 = createTemporaryObject(subscriptionComponent, testCase, {topic: "topic1", isReady: true, notificationInterval: 50}) //10 requests in 500ms
        const subscription2 = createTemporaryObject(subscriptionComponent, testCase, {topic: "topic2", isReady: true, notificationInterval: 90}) //5 requests in 500ms
        const subscription3 = createTemporaryObject(subscriptionComponent, testCase, {topic: "topic3", isReady: true, notificationInterval: 130}) //3 requests in 500ms

        subscriptionBroker.active = true
        subscriptionBroker.subscribe(subscription1)
        subscriptionBroker.subscribe(subscription2)
        subscriptionBroker.subscribe(subscription3)

        compare(subscriptionBroker.subscribedSignalSpy.count, 3, "subscribed signal should be emitted")

        subscription1.topic = "topic1Changed"
        compare(subscriptionBroker.requestSignalSpy.count, 4, "request signal should be emitted after changing the topic")
    }
}

