// lib/providers/news_provider.dart
// Manages the carousel news/law-update announcements shown on the dashboard.
// Synchronizes in real time with Cloud Firestore ('app_announcements' collection).

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class NewsItem {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final String iconName;
  final int iconColorHex;
  final String tag; // e.g. "New Law", "Circular", "Amendment", "Alert", "Notice"
  final int order;
  final DateTime? updatedAt;

  const NewsItem({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.iconName = 'info',
    required this.iconColorHex,
    required this.tag,
    this.order = 0,
    this.updatedAt,
  });

  static IconData iconFromName(String? name) {
    switch (name?.toLowerCase().trim()) {
      case 'gavel':
        return Icons.gavel_rounded;
      case 'shield':
        return Icons.shield_rounded;
      case 'videocam':
        return Icons.videocam_rounded;
      case 'security':
        return Icons.security_rounded;
      case 'campaign':
        return Icons.campaign_rounded;
      case 'warning':
        return Icons.warning_amber_rounded;
      case 'policy':
        return Icons.policy_rounded;
      case 'article':
        return Icons.article_rounded;
      case 'local_police':
        return Icons.local_police_rounded;
      case 'handshake':
        return Icons.handshake_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  static String nameFromIcon(IconData icon) {
    if (icon == Icons.gavel_rounded) return 'gavel';
    if (icon == Icons.shield_rounded) return 'shield';
    if (icon == Icons.videocam_rounded) return 'videocam';
    if (icon == Icons.security_rounded) return 'security';
    if (icon == Icons.campaign_rounded) return 'campaign';
    if (icon == Icons.warning_amber_rounded) return 'warning';
    if (icon == Icons.policy_rounded) return 'policy';
    if (icon == Icons.article_rounded) return 'article';
    if (icon == Icons.local_police_rounded) return 'local_police';
    if (icon == Icons.handshake_rounded) return 'handshake';
    return 'info';
  }

  factory NewsItem.fromMap(String docId, Map<String, dynamic> map) {
    final iconStr = map['iconName'] as String? ?? 'info';
    DateTime? updated;
    if (map['updatedAt'] is Timestamp) {
      updated = (map['updatedAt'] as Timestamp).toDate();
    } else if (map['updatedAt'] is String) {
      updated = DateTime.tryParse(map['updatedAt'] as String);
    }

    return NewsItem(
      id: docId,
      title: map['title'] as String? ?? 'Announcement',
      description: map['description'] as String? ?? '',
      iconName: iconStr,
      icon: iconFromName(iconStr),
      iconColorHex: (map['iconColorHex'] as num?)?.toInt() ?? 0xFF00838F,
      tag: map['tag'] as String? ?? 'Notice',
      order: (map['order'] as num?)?.toInt() ?? 0,
      updatedAt: updated,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'iconName': iconName,
      'iconColorHex': iconColorHex,
      'tag': tag,
      'order': order,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  NewsItem copyWith({
    String? id,
    String? title,
    String? description,
    IconData? icon,
    String? iconName,
    int? iconColorHex,
    String? tag,
    int? order,
    DateTime? updatedAt,
  }) {
    return NewsItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      iconName: iconName ?? this.iconName,
      iconColorHex: iconColorHex ?? this.iconColorHex,
      tag: tag ?? this.tag,
      order: order ?? this.order,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class NewsProvider extends ChangeNotifier {
  static const List<NewsItem> defaultNewsItems = [
    NewsItem(
      id: 'default_1',
      title: 'BNSS 2023 — New Criminal Procedure Code',
      description:
          'Bharatiya Nagarik Suraksha Sanhita (BNSS) replaces CrPC with stricter timelines for investigation and trial.',
      icon: Icons.gavel_rounded,
      iconName: 'gavel',
      iconColorHex: 0xFF1A237E,
      tag: 'New Law',
      order: 1,
    ),
    NewsItem(
      id: 'default_2',
      title: 'POCSO Amendment — Stricter Penalties',
      description:
          'Recent amendments to POCSO Act 2012 prescribe enhanced punishment for repeat offenders and faster trial timelines.',
      icon: Icons.shield_rounded,
      iconName: 'shield',
      iconColorHex: 0xFF00838F,
      tag: 'Amendment',
      order: 2,
    ),
    NewsItem(
      id: 'default_3',
      title: 'Circular: Body Camera Mandate',
      description:
          'All field officers must wear body cameras during raids and arrests effective 1st May. Submit usage reports weekly.',
      icon: Icons.videocam_rounded,
      iconName: 'videocam',
      iconColorHex: 0xFFE65100,
      tag: 'Circular',
      order: 3,
    ),
    NewsItem(
      id: 'default_4',
      title: 'Cyber Crime Awareness — New SOP',
      description:
          'Updated Standard Operating Procedure for cybercrime investigation units. First responders must complete e-training.',
      icon: Icons.security_rounded,
      iconName: 'security',
      iconColorHex: 0xFF1B5E20,
      tag: 'Awareness',
      order: 4,
    ),
  ];

  List<NewsItem> _items = List.of(defaultNewsItems);
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;
  bool _isLoading = false;
  String? _errorMessage;

  NewsProvider() {
    _initFirestoreListener();
  }

  List<NewsItem> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _initFirestoreListener() {
    try {
      final collection =
          FirebaseFirestore.instance.collection('app_announcements');
      _subscription = collection
          .orderBy('order')
          .snapshots()
          .listen(
            (snapshot) {
              if (snapshot.docs.isNotEmpty) {
                _items = snapshot.docs
                    .map((doc) => NewsItem.fromMap(doc.id, doc.data()))
                    .toList();
              } else {
                // If Firestore is empty, retain local defaults
                _items = List.of(defaultNewsItems);
              }
              _errorMessage = null;
              notifyListeners();
            },
            onError: (err) {
              if (kDebugMode) {
                debugPrint('[NewsProvider] Firestore listener fallback: $err');
              }
              _items = List.of(defaultNewsItems);
              _errorMessage = null;
              notifyListeners();
            },
          );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[NewsProvider] Initialization error: $e');
      }
    }
  }

  /// Master Admin creates a new announcement
  Future<void> addAnnouncement(NewsItem item) async {
    try {
      _isLoading = true;
      notifyListeners();

      final collection =
          FirebaseFirestore.instance.collection('app_announcements');
      final docRef = await collection.add(item.toMap());

      // Optimistic local update
      _items.add(item.copyWith(id: docRef.id));
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Master Admin updates an existing announcement
  Future<void> updateAnnouncement(NewsItem item) async {
    try {
      _isLoading = true;
      notifyListeners();

      final collection =
          FirebaseFirestore.instance.collection('app_announcements');
      await collection.doc(item.id).set(item.toMap(), SetOptions(merge: true));

      final idx = _items.indexWhere((i) => i.id == item.id);
      if (idx >= 0) {
        _items[idx] = item;
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Master Admin deletes an announcement
  Future<void> deleteAnnouncement(String id) async {
    try {
      _isLoading = true;
      notifyListeners();

      final collection =
          FirebaseFirestore.instance.collection('app_announcements');
      await collection.doc(id).delete();

      _items.removeWhere((i) => i.id == id);
      if (_items.isEmpty) {
        _items = List.of(defaultNewsItems);
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Seed defaults into Firestore if Master Admin wants to populate or reset
  Future<void> seedDefaultsToFirestore() async {
    try {
      _isLoading = true;
      notifyListeners();

      final collection =
          FirebaseFirestore.instance.collection('app_announcements');
      final existing = await collection.get();
      for (final doc in existing.docs) {
        await doc.reference.delete();
      }

      for (final def in defaultNewsItems) {
        await collection.add(def.toMap());
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
