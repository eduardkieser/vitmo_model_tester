///
//  Generated code. Do not modify.
//  source: admin_interface_service.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type

import 'dart:async' as $async;

import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'admin_interface_service.pb.dart' as $0;
export 'admin_interface_service.pb.dart';

class AdminInterfaceServiceClient extends $grpc.Client {
  static final _$openVideoStream =
      $grpc.ClientMethod<$0.VideoStreamResponse, $0.VideoStreamResquest>(
          '/admin_interface_service.AdminInterfaceService/OpenVideoStream',
          ($0.VideoStreamResponse value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.VideoStreamResquest.fromBuffer(value));
  static final _$getDeviceList =
      $grpc.ClientMethod<$0.DeviceListRequest, $0.DeviceListResponse>(
          '/admin_interface_service.AdminInterfaceService/GetDeviceList',
          ($0.DeviceListRequest value) => value.writeToBuffer(),
          ($core.List<$core.int> value) =>
              $0.DeviceListResponse.fromBuffer(value));

  AdminInterfaceServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions options})
      : super(channel, options: options);

  $grpc.ResponseStream<$0.VideoStreamResquest> openVideoStream(
      $async.Stream<$0.VideoStreamResponse> request,
      {$grpc.CallOptions options}) {
    final call = $createCall(_$openVideoStream, request, options: options);
    return $grpc.ResponseStream(call);
  }

  $grpc.ResponseFuture<$0.DeviceListResponse> getDeviceList(
      $0.DeviceListRequest request,
      {$grpc.CallOptions options}) {
    final call = $createCall(
        _$getDeviceList, $async.Stream.fromIterable([request]),
        options: options);
    return $grpc.ResponseFuture(call);
  }
}

abstract class AdminInterfaceServiceBase extends $grpc.Service {
  $core.String get $name => 'admin_interface_service.AdminInterfaceService';

  AdminInterfaceServiceBase() {
    $addMethod(
        $grpc.ServiceMethod<$0.VideoStreamResponse, $0.VideoStreamResquest>(
            'OpenVideoStream',
            openVideoStream,
            true,
            true,
            ($core.List<$core.int> value) =>
                $0.VideoStreamResponse.fromBuffer(value),
            ($0.VideoStreamResquest value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DeviceListRequest, $0.DeviceListResponse>(
        'GetDeviceList',
        getDeviceList_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.DeviceListRequest.fromBuffer(value),
        ($0.DeviceListResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.DeviceListResponse> getDeviceList_Pre($grpc.ServiceCall call,
      $async.Future<$0.DeviceListRequest> request) async {
    return getDeviceList(call, await request);
  }

  $async.Stream<$0.VideoStreamResquest> openVideoStream(
      $grpc.ServiceCall call, $async.Stream<$0.VideoStreamResponse> request);
  $async.Future<$0.DeviceListResponse> getDeviceList(
      $grpc.ServiceCall call, $0.DeviceListRequest request);
}
