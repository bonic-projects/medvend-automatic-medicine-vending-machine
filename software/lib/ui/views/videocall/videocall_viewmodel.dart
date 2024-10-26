import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:stacked/stacked.dart';
import 'package:medvend/app/app.logger.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:medvend/app/app.locator.dart';

class VideoCallViewModel extends BaseViewModel {
  final log = getLogger('VideoCallViewModel');
  final _navigationService = locator<NavigationService>();

  late RtcEngine engine;
  int? remoteUid; // To store the UID of the remote user
  String? patientId;
  String? roomName;
  bool isDoctor = false;

  Future<void> initialize(
      String patientId, String roomName, bool isDoctor) async {
    this.patientId = patientId;
    this.roomName = roomName;
    this.isDoctor = isDoctor;

    log.i("Initialized video call for room $roomName with patient $patientId.");

    await _initializeAgora(); // Initialize Agora SDK
  }

  Future<void> _initializeAgora() async {
    engine = createAgoraRtcEngine();
    await engine.initialize(
        RtcEngineContext(appId: 'aeb974c13211454ebcf214d3495442d6'));

    engine.registerEventHandler(
      RtcEngineEventHandler(
        onUserJoined: (RtcConnection connection, int uid, int elapsed) {
          // Add `elapsed`
          log.i(
              "Remote user $uid joined after $elapsed ms."); // Log the time taken to join
          remoteUid = uid; // Store the remote UID
          notifyListeners(); // Notify UI to update when remote user joins
        },
        onUserOffline:
            (RtcConnection connection, int uid, UserOfflineReasonType reason) {
          log.i("Remote user $uid left. Reason: $reason");
          remoteUid = null; // Clear remote UID when the remote user leaves
          notifyListeners(); // Update the UI
        },
        onError: (ErrorCodeType errorCode, String errorMessage) {
          // Ensure both parameters are used
          log.e("Agora SDK Error: $errorCode - $errorMessage");
        },
      ),
    );

    // Enable both video and audio
    await engine.enableVideo();
    await engine.enableAudio(); // Enable audio
    await engine.startPreview();

    log.i("Joining channel $roomName.");

    // Join the channel with the token (token can be empty for now)
    await engine.joinChannel(
      token: '', // Provide Agora token if needed
      channelId: roomName!,
      uid: 0, // Local user ID (0 will let Agora assign an ID)
      options: ChannelMediaOptions(),
    );
  }

  Future<void> endVideoCall() async {
    log.i("Ending video call.");
    if (engine != null) {
      await engine.leaveChannel();
      await engine.stopPreview();
      await engine.release();
    }
    _navigationService.back();
  }

  @override
  void dispose() {
    if (engine != null) {
      engine.release();
    }
    super.dispose();
  }
}
