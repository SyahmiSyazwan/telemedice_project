import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';

class JitsiService {
  final JitsiMeet jitsiMeet = JitsiMeet();

  Future<void> joinMeeting({
    required String roomName,
    required String userName,
    String? email,
    String? subject,
  }) async {
    try {
      var options = JitsiMeetConferenceOptions(
        serverURL: "https://meet.jit.si",
        room: roomName,
        configOverrides: {
          "startWithAudioMuted": false,
          "startWithVideoMuted": false,
          "subject": subject ?? "Telemedicine Appointment",
        },
        featureFlags: {
          "unsaferoomwarning.enabled": false,
        },
        userInfo: JitsiMeetUserInfo(
          displayName: userName,
          email: email,
        ),
      );

      await jitsiMeet.join(options);
    } catch (e) {
      print("Error joining Jitsi meeting: $e");
      rethrow;
    }
  }
}
