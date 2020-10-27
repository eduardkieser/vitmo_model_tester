///
//  Generated code. Do not modify.
//  source: recorder_service.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type

import 'dart:async' as $async;

import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'recorder_service.pb.dart' as $0;
export 'recorder_service.pb.dart';

class RecorderServiceClient extends $grpc.Client {
  static final _$openCreateRecordingSessionStream = $grpc.ClientMethod<
          $0.CreateRecordingSessionResponse, $0.CreateRecordingSessionRequest>(
      '/recorder_service.RecorderService/OpenCreateRecordingSessionStream',
      ($0.CreateRecordingSessionResponse value) => value.writeToBuffer(),
      ($core.List<$core.int> value) =>
          $0.CreateRecordingSessionRequest.fromBuffer(value));
  static final _$openModifyRecordingSessionStream = $grpc.ClientMethod<
          $0.ModifyRecordingSessionResponse, $0.ModifyRecordingSessionRequest>(
      '/recorder_service.RecorderService/OpenModifyRecordingSessionStream',
      ($0.ModifyRecordingSessionResponse value) => value.writeToBuffer(),
      ($core.List<$core.int> value) =>
          $0.ModifyRecordingSessionRequest.fromBuffer(value));
  static final _$openCloseRecordingSessionStream = $grpc.ClientMethod<
          $0.CloseRecordingSessionResponse, $0.CloseRecordingSessionRequest>(
      '/recorder_service.RecorderService/OpenCloseRecordingSessionStream',
      ($0.CloseRecordingSessionResponse value) => value.writeToBuffer(),
      ($core.List<$core.int> value) =>
          $0.CloseRecordingSessionRequest.fromBuffer(value));
  static final _$openDescribeRecordingSessionsStream = $grpc.ClientMethod<
          $0.DescribeRecordingSessionsResponse,
          $0.DescribeRecordingSessionsRequest>(
      '/recorder_service.RecorderService/OpenDescribeRecordingSessionsStream',
      ($0.DescribeRecordingSessionsResponse value) => value.writeToBuffer(),
      ($core.List<$core.int> value) =>
          $0.DescribeRecordingSessionsRequest.fromBuffer(value));
  static final _$openFrameProcessingStream =
      $grpc.ClientMethod<$0.FrameProcessingResponse, $0.FrameProcessingRequest>(
          '/recorder_service.RecorderService/OpenFrameProcessingStream',
          ($0.FrameProcessingResponse value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.FrameProcessingRequest.fromBuffer(value));
  static final _$openCreateVideoSessionStream = $grpc.ClientMethod<
          $0.CreateVideoSessionResponse, $0.CreateVideoSessionRequest>(
      '/recorder_service.RecorderService/OpenCreateVideoSessionStream',
      ($0.CreateVideoSessionResponse value) => value.writeToBuffer(),
      ($core.List<$core.int> value) =>
          $0.CreateVideoSessionRequest.fromBuffer(value));
  static final _$openCloseVideoSessionStream = $grpc.ClientMethod<
          $0.CloseVideoSessionResponse, $0.CloseVideoSessionRequest>(
      '/recorder_service.RecorderService/OpenCloseVideoSessionStream',
      ($0.CloseVideoSessionResponse value) => value.writeToBuffer(),
      ($core.List<$core.int> value) =>
          $0.CloseVideoSessionRequest.fromBuffer(value));
  static final _$uploadVideo =
      $grpc.ClientMethod<$0.VideoDataUnit, $0.UploadVideoResponse>(
          '/recorder_service.RecorderService/UploadVideo',
          ($0.VideoDataUnit value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.UploadVideoResponse.fromBuffer(value));
  static final _$publishMetrics =
      $grpc.ClientMethod<$0.Metrics, $0.PublishMetricsResponse>(
          '/recorder_service.RecorderService/PublishMetrics',
          ($0.Metrics value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.PublishMetricsResponse.fromBuffer(value));

  RecorderServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions options})
      : super(channel, options: options);

  $grpc.ResponseStream<$0.CreateRecordingSessionRequest>
      openCreateRecordingSessionStream(
          $async.Stream<$0.CreateRecordingSessionResponse> request,
          {$grpc.CallOptions options}) {
    final call = $createCall(_$openCreateRecordingSessionStream, request,
        options: options);
    return $grpc.ResponseStream(call);
  }

  $grpc.ResponseStream<$0.ModifyRecordingSessionRequest>
      openModifyRecordingSessionStream(
          $async.Stream<$0.ModifyRecordingSessionResponse> request,
          {$grpc.CallOptions options}) {
    final call = $createCall(_$openModifyRecordingSessionStream, request,
        options: options);
    return $grpc.ResponseStream(call);
  }

  $grpc.ResponseStream<$0.CloseRecordingSessionRequest>
      openCloseRecordingSessionStream(
          $async.Stream<$0.CloseRecordingSessionResponse> request,
          {$grpc.CallOptions options}) {
    final call = $createCall(_$openCloseRecordingSessionStream, request,
        options: options);
    return $grpc.ResponseStream(call);
  }

  $grpc.ResponseStream<$0.DescribeRecordingSessionsRequest>
      openDescribeRecordingSessionsStream(
          $async.Stream<$0.DescribeRecordingSessionsResponse> request,
          {$grpc.CallOptions options}) {
    final call = $createCall(_$openDescribeRecordingSessionsStream, request,
        options: options);
    return $grpc.ResponseStream(call);
  }

  $grpc.ResponseStream<$0.FrameProcessingRequest> openFrameProcessingStream(
      $async.Stream<$0.FrameProcessingResponse> request,
      {$grpc.CallOptions options}) {
    final call =
        $createCall(_$openFrameProcessingStream, request, options: options);
    return $grpc.ResponseStream(call);
  }

  $grpc.ResponseStream<$0.CreateVideoSessionRequest>
      openCreateVideoSessionStream(
          $async.Stream<$0.CreateVideoSessionResponse> request,
          {$grpc.CallOptions options}) {
    final call =
        $createCall(_$openCreateVideoSessionStream, request, options: options);
    return $grpc.ResponseStream(call);
  }

  $grpc.ResponseStream<$0.CloseVideoSessionRequest> openCloseVideoSessionStream(
      $async.Stream<$0.CloseVideoSessionResponse> request,
      {$grpc.CallOptions options}) {
    final call =
        $createCall(_$openCloseVideoSessionStream, request, options: options);
    return $grpc.ResponseStream(call);
  }

  $grpc.ResponseFuture<$0.UploadVideoResponse> uploadVideo(
      $0.VideoDataUnit request,
      {$grpc.CallOptions options}) {
    final call = $createCall(
        _$uploadVideo, $async.Stream.fromIterable([request]),
        options: options);
    return $grpc.ResponseFuture(call);
  }

  $grpc.ResponseFuture<$0.PublishMetricsResponse> publishMetrics(
      $0.Metrics request,
      {$grpc.CallOptions options}) {
    final call = $createCall(
        _$publishMetrics, $async.Stream.fromIterable([request]),
        options: options);
    return $grpc.ResponseFuture(call);
  }
}

abstract class RecorderServiceBase extends $grpc.Service {
  $core.String get $name => 'recorder_service.RecorderService';

  RecorderServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.CreateRecordingSessionResponse,
            $0.CreateRecordingSessionRequest>(
        'OpenCreateRecordingSessionStream',
        openCreateRecordingSessionStream,
        true,
        true,
        ($core.List<$core.int> value) =>
            $0.CreateRecordingSessionResponse.fromBuffer(value),
        ($0.CreateRecordingSessionRequest value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ModifyRecordingSessionResponse,
            $0.ModifyRecordingSessionRequest>(
        'OpenModifyRecordingSessionStream',
        openModifyRecordingSessionStream,
        true,
        true,
        ($core.List<$core.int> value) =>
            $0.ModifyRecordingSessionResponse.fromBuffer(value),
        ($0.ModifyRecordingSessionRequest value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CloseRecordingSessionResponse,
            $0.CloseRecordingSessionRequest>(
        'OpenCloseRecordingSessionStream',
        openCloseRecordingSessionStream,
        true,
        true,
        ($core.List<$core.int> value) =>
            $0.CloseRecordingSessionResponse.fromBuffer(value),
        ($0.CloseRecordingSessionRequest value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DescribeRecordingSessionsResponse,
            $0.DescribeRecordingSessionsRequest>(
        'OpenDescribeRecordingSessionsStream',
        openDescribeRecordingSessionsStream,
        true,
        true,
        ($core.List<$core.int> value) =>
            $0.DescribeRecordingSessionsResponse.fromBuffer(value),
        ($0.DescribeRecordingSessionsRequest value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.FrameProcessingResponse,
            $0.FrameProcessingRequest>(
        'OpenFrameProcessingStream',
        openFrameProcessingStream,
        true,
        true,
        ($core.List<$core.int> value) =>
            $0.FrameProcessingResponse.fromBuffer(value),
        ($0.FrameProcessingRequest value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CreateVideoSessionResponse,
            $0.CreateVideoSessionRequest>(
        'OpenCreateVideoSessionStream',
        openCreateVideoSessionStream,
        true,
        true,
        ($core.List<$core.int> value) =>
            $0.CreateVideoSessionResponse.fromBuffer(value),
        ($0.CreateVideoSessionRequest value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.CloseVideoSessionResponse,
            $0.CloseVideoSessionRequest>(
        'OpenCloseVideoSessionStream',
        openCloseVideoSessionStream,
        true,
        true,
        ($core.List<$core.int> value) =>
            $0.CloseVideoSessionResponse.fromBuffer(value),
        ($0.CloseVideoSessionRequest value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.VideoDataUnit, $0.UploadVideoResponse>(
        'UploadVideo',
        uploadVideo_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.VideoDataUnit.fromBuffer(value),
        ($0.UploadVideoResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.Metrics, $0.PublishMetricsResponse>(
        'PublishMetrics',
        publishMetrics_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.Metrics.fromBuffer(value),
        ($0.PublishMetricsResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.UploadVideoResponse> uploadVideo_Pre(
      $grpc.ServiceCall call, $async.Future<$0.VideoDataUnit> request) async {
    return uploadVideo(call, await request);
  }

  $async.Future<$0.PublishMetricsResponse> publishMetrics_Pre(
      $grpc.ServiceCall call, $async.Future<$0.Metrics> request) async {
    return publishMetrics(call, await request);
  }

  $async.Stream<$0.CreateRecordingSessionRequest>
      openCreateRecordingSessionStream($grpc.ServiceCall call,
          $async.Stream<$0.CreateRecordingSessionResponse> request);
  $async.Stream<$0.ModifyRecordingSessionRequest>
      openModifyRecordingSessionStream($grpc.ServiceCall call,
          $async.Stream<$0.ModifyRecordingSessionResponse> request);
  $async.Stream<$0.CloseRecordingSessionRequest>
      openCloseRecordingSessionStream($grpc.ServiceCall call,
          $async.Stream<$0.CloseRecordingSessionResponse> request);
  $async.Stream<$0.DescribeRecordingSessionsRequest>
      openDescribeRecordingSessionsStream($grpc.ServiceCall call,
          $async.Stream<$0.DescribeRecordingSessionsResponse> request);
  $async.Stream<$0.FrameProcessingRequest> openFrameProcessingStream(
      $grpc.ServiceCall call,
      $async.Stream<$0.FrameProcessingResponse> request);
  $async.Stream<$0.CreateVideoSessionRequest> openCreateVideoSessionStream(
      $grpc.ServiceCall call,
      $async.Stream<$0.CreateVideoSessionResponse> request);
  $async.Stream<$0.CloseVideoSessionRequest> openCloseVideoSessionStream(
      $grpc.ServiceCall call,
      $async.Stream<$0.CloseVideoSessionResponse> request);
  $async.Future<$0.UploadVideoResponse> uploadVideo(
      $grpc.ServiceCall call, $0.VideoDataUnit request);
  $async.Future<$0.PublishMetricsResponse> publishMetrics(
      $grpc.ServiceCall call, $0.Metrics request);
}
