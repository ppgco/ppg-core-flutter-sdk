package com.pushpushgo.ppg_core_example

import android.util.Log
import com.pushpushgo.core_sdk.sdk.client.Subscription
import com.pushpushgo.core_sdk.sdk.fcm.FcmMessagingService

/**
 * This file should be implement by developer in other company
 * On this event we should save "subscription" to database.
 */
class FirebaseMessagingService : FcmMessagingService() {
    override fun onNewSubscription(subscription: Subscription) {
        Log.d("onNewSubscription", "Save this data in your database ${subscription.toJSON()}");
    }
}