import 'dart:async';
 
import 'package:flutter/rendering.dart';
import 'package:grpc/grpc.dart';
import 'generated/source/proto/recorderService/dart/recorder_service.pbgrpc.dart';
 
class RecorderClient {
  ClientChannel channel;
  RecorderServiceClient stub;
 
  Future<void> openChannels(List<String> args) async {
    debugPrint('opening channels');
    channel = ClientChannel('127.0.0.1',
        port: 10000,
        options:
        const ChannelOptions(credentials: ChannelCredentials.insecure()));
    debugPrint('channel defined');
    stub = RecorderServiceClient(channel,
        options: CallOptions(timeout: Duration(seconds: 30)));
    debugPrint('recorder service client created');
    StreamController<FrameProcessingRequest> buffer = StreamController();

    await stub.openFrameProcessingStream(buffer.stream.map(processFrames)).pipe(buffer);
    debugPrint('stream is open');
    await channel.shutdown();
  }
 
  FrameProcessingResponse processFrames(FrameProcessingRequest req) {
    return null;
  }
}