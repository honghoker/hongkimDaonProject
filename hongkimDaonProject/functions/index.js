
const functions = require("firebase-functions");
const admin = require('firebase-admin');
admin.initializeApp();
const databaseStore = admin.firestore();

exports.sendTodayMessage = functions.pubsub.schedule('every 10 minutes').onRun(async (context) => {
    const query = await databaseStore.collection('user').get();
    try {
        return query.forEach(async eachGroup => {
            // 알림 받을지 말지 먼저 체크
            var notificationCheck = eachGroup.data()[''];
            var notificationTime = eachGroup.data()[''];
            if (notificationCheck == true) {
                // if 현재시간 == notificationTime 이면 알림보내기
                var payload = {
                    "notification": {
                        "title": "다온",
                        "body": "오늘의 다온이 도착했습니다",
                        "sound": "false",
                    },
                    "data": {
                        'click_action': 'FLUTTER_NOTIFICATION_CLICK',
                        'id': '1',
                        'status': 'done',
                        // "action": action
                    }
                }
                var result = admin.messaging().sendToDevice(eachGroup.data()["fcmToken"], payload)
                return result
            }
        })
  
    }
    catch (err) {
        throw new functions.https.HttpsError('invalid-argument', "some message");
    }
})

exports.withdrawal = functions.auth.user().onDelete((user) => {
    const uid = user.uid
    databaseStore.collection("user").doc(uid).delete();
    databaseStore.collection("diary").where("uid", "==", uid).get().then((querySnapshot) => {
        querySnapshot.docs.forEach((diarySnapshot) => {
            const imageUrl = diarySnapshot.get("imageUrl")
            const path = decodeURIComponent(imageUrl.split("o/")[1].split("?")[0]);

            if (imageUrl != null && imageUrl != "") { 
                admin.storage().bucket().file(path).delete()
            }
            databaseStore.collection("diary").doc(diarySnapshot.id).delete();
        })
    }); 
});