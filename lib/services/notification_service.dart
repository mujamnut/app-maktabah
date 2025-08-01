import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  final _client = Supabase.instance.client;

  // Dapatkan semua notifications untuk admin
  Future<List<Map<String, dynamic>>> getAdminNotifications() async {
    try {
      final response = await _client
          .from('notifications')
          .select('*')
          .eq('is_read', false)
          .order('created_at', ascending: false);

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
      return [];
    }
  }

  // Dapatkan jumlah notifications yang belum dibaca
  Future<int> getUnreadNotificationCount() async {
    try {
      final response =
          await _client.from('notifications').select('id').eq('is_read', false);

      return (response as List).length;
    } catch (e) {
      debugPrint('Error fetching notification count: $e');
      return 0;
    }
  }

  // Tandakan notification sebagai telah dibaca
  Future<void> markAsRead(String notificationId) async {
    try {
      await _client
          .from('notifications')
          .update({'is_read': true}).eq('id', notificationId);
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  // Tandakan semua notifications sebagai telah dibaca
  Future<void> markAllAsRead() async {
    try {
      await _client
          .from('notifications')
          .update({'is_read': true}).eq('is_read', false);
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }

  // Buat notification baru (dipanggil apabila buku ditambah)
  Future<void> createBookAddedNotification({
    required String bookTitle,
    required String addedBy,
    required String bookId,
    required String userId,
  }) async {
    try {
      await _client.from('notifications').insert({
        'type': 'book_added',
        'title': 'Buku Baru Ditambah',
        'message': 'Buku "$bookTitle" telah ditambah oleh $addedBy',
        'book_id': bookId,
        'added_by': addedBy,
        'user_id': userId,
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error creating notification: $e');
    }
  }

  // Dapatkan real-time updates untuk notifications
  RealtimeChannel subscribeToNotifications(
      Function(List<Map<String, dynamic>>) onUpdate) {
    final channel = _client.channel('notifications').on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(
        event: 'INSERT',
        schema: 'public',
        table: 'notifications',
      ),
      (payload, [ref]) {
        // Refresh notifications apabila ada yang baru
        getAdminNotifications().then(onUpdate);
      },
    );

    channel.subscribe();
    return channel;
  }
}
