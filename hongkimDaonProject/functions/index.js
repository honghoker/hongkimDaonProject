
const functions = require("firebase-functions");
const admin = require('firebase-admin');
admin.initializeApp();
const databaseStore = admin.firestore();

exports.sendTodayMessage = functions.region("asia-northeast3").pubsub.schedule('*/10 * * * *').timeZone("Asia/Seoul").onRun(async (context) => {    
    const query = await databaseStore.collection('user').get();
    try {
        return query.forEach(async eachGroup => {
            // 알림 받을지 말지 먼저 체크
            var notificationCheck = eachGroup.data()['notification'];
            var notificationTime = eachGroup.data()['notificationTime'];
            if (notificationCheck == true) {
                // if 현재시간 == notificationTime 이면 알림보내기
                var nowHoursTime = admin.firestore.Timestamp.now().toDate().getHours();
                var nowMinuteTime = admin.firestore.Timestamp.now().toDate().getMinutes();
                var MinuteTime = nowMinuteTime
                if (nowMinuteTime < 10) {
                    MinuteTime = "0" + nowMinuteTime 
                }
                var koreaHoursTime = nowHoursTime + 9
                if (koreaHoursTime >= 24) {
                    koreaHoursTime = koreaHoursTime - 24
                    var hoursTime = "0" + koreaHoursTime
                    var timeString = hoursTime + ":" + MinuteTime
                    if (timeString.toString() === notificationTime){
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
                }
                else {
                    if (koreaHoursTime < 10) {
                        var hoursTime = "0" + koreaHoursTime
                        var timeString = hoursTime + ":" + MinuteTime
                        if (timeString.toString() === notificationTime){
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
                    }
                    else{
                        var timeString = koreaHoursTime + ":" + MinuteTime
                        if (timeString.toString() === notificationTime){
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
                    }
                }

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

exports.sendTodayMessageOneTest = functions.region("asia-northeast3").pubsub.schedule('*/1 * * * *').timeZone("Asia/Seoul").onRun(async (context) => {
    var nowHoursTime = admin.firestore.Timestamp.now().toDate().getHours();
    var nowMinuteTime = admin.firestore.Timestamp.now().toDate().getMinutes();
    var koreaHoursTime = nowHoursTime + 9
    if (koreaHoursTime >= 24) {
        koreaHoursTime = koreaHoursTime - 24
        var hoursTime = "0" + koreaHoursTime
        var timeString = hoursTime + ":" + nowMinuteTime
    }
    else {
        if (koreaHoursTime < 10) {
            var hoursTime = "0" + koreaHoursTime
        }
        else{

        }
    }
    // 0  1  2  3  4  5  6  7  8  9 10 11 12 13 14  15 16 17 18 19 20 21 22 23
    // 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23  24 25 26 27 28 29 30 31 32  
    //                                               0  1  2  3  4  5  6  7  8
})
