import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/utils/result.dart';
import '../../data/datasources/order_remote_data_source.dart';
import '../../data/repositories/order_repository_impl.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';

/// The orders repository.
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepositoryImpl(OrderRemoteDataSource(ref.watch(dioProvider)));
});

/// Order tracking with polling every 4 seconds.
///
/// - autoDispose: stops by itself when the user leaves the page.
/// - stops when the status reaches Delivered.
/// - if the internet drops for a moment, keeps showing the last known status and tries again.
final orderTrackingProvider = StreamProvider.autoDispose.family<Order, int>((ref, orderId) async* {
  final repository = ref.watch(orderRepositoryProvider);
  var disposed = false;
  ref.onDispose(() => disposed = true);

  Order? last;
  while (!disposed) {
    switch (await repository.getOrder(orderId)) {
      case Success(:final value):
        last = value;
        yield value;
        if (value.status.isFinal) return;
      case ResultFailure(:final failure):
        // The order doesn't exist, or we have no status to show -> show the error
        if (failure is NotFoundFailure || last == null) throw failure;
      // Otherwise it's a short network error -> keep the last status and try again later
    }
    await Future<void>.delayed(AppConfig.trackingPollInterval);
  }
});
