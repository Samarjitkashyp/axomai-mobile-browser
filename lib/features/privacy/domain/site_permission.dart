import 'dart:convert';

/// Granular permission types requested by websites.
enum PermissionType { camera, microphone, geolocation, notifications }

/// User decision state for a permission.
enum PermissionStatus { prompt, allow, block }

/// Represents a permission granted or denied for a specific web origin.
class SitePermission {
  final String origin;
  final PermissionType type;
  final PermissionStatus status;
  final DateTime updatedAt;

  const SitePermission({
    required this.origin,
    required this.type,
    required this.status,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'origin': origin,
      'type': type.name,
      'status': status.name,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory SitePermission.fromMap(Map<String, dynamic> map) {
    return SitePermission(
      origin: map['origin'] as String,
      type: PermissionType.values.firstWhere(
        (t) => t.name == map['type'],
        orElse: () => PermissionType.geolocation,
      ),
      status: PermissionStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => PermissionStatus.prompt,
      ),
      updatedAt: DateTime.parse(
        map['updatedAt'] as String? ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory SitePermission.fromJson(String source) =>
      SitePermission.fromMap(json.decode(source) as Map<String, dynamic>);
}
