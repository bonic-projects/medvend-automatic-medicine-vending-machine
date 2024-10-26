import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart'; // Agora Video View import
import 'package:stacked/stacked.dart';
import 'videocall_viewmodel.dart';

class VideoCallView extends StatelessWidget {
  final String patientId;
  final String roomName;
  final bool isDoctor;

  VideoCallView({
    Key? key,
    required this.patientId,
    required this.roomName,
    required this.isDoctor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<VideoCallViewModel>.reactive(
      viewModelBuilder: () => VideoCallViewModel(),
      onModelReady: (viewModel) =>
          viewModel.initialize(patientId, roomName, isDoctor),
      builder: (context, viewModel, child) => Scaffold(
        appBar: AppBar(
          title: Text("Video Call: Doctor and Patient"),
        ),
        body: Column(
          children: [
            // Remote video (shown when the remote user joins)
            Expanded(
              child: viewModel.remoteUid != null
                  ? AgoraVideoView(
                      controller: VideoViewController.remote(
                        rtcEngine: viewModel.engine,
                        canvas: VideoCanvas(uid: viewModel.remoteUid!),
                        connection: RtcConnection(
                          channelId: viewModel.roomName!,
                        ), // Fix: required connection argument
                      ),
                    )
                  : Center(child: Text("Waiting for remote user...")),
            ),
            // Local video (always shown)
            Expanded(
              child: AgoraVideoView(
                controller: VideoViewController(
                  rtcEngine: viewModel.engine,
                  canvas: const VideoCanvas(uid: 0), // Local user ID
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: () =>
                      viewModel.initialize(patientId, roomName, isDoctor),
                  child: Text("Join Video Call"),
                ),
                ElevatedButton(
                  onPressed: viewModel.endVideoCall,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: Text("End Call"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
