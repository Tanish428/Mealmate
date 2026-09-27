class DonationPartnerModel {
  final String id;
  final String messId;
  final String name;
  final String? contactPhone;
  final String? contactPerson;
  final String? address;
  final String? notes;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  DonationPartnerModel({
    required this.id,
    required this.messId,
    required this.name,
    this.contactPhone,
    this.contactPerson,
    this.address,
    this.notes,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory DonationPartnerModel.fromJson(Map<dynamic, dynamic> json) {
    final createdAtRaw = json['created_at'];
    final updatedAtRaw = json['updated_at'];

    return DonationPartnerModel(
      id: json['id']?.toString() ?? '',
      messId: json['mess_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      contactPhone: json['contact_phone']?.toString(),
      contactPerson: json['contact_person']?.toString(),
      address: json['address']?.toString(),
      notes: json['notes']?.toString(),
      isActive: json['is_active'] is bool ? json['is_active'] as bool : true,
      createdAt: createdAtRaw != null ? DateTime.parse(createdAtRaw.toString()) : DateTime.now(),
      updatedAt: updatedAtRaw != null ? DateTime.parse(updatedAtRaw.toString()) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'mess_id': messId,
      'name': name,
      if (contactPhone != null) 'contact_phone': contactPhone,
      if (contactPerson != null) 'contact_person': contactPerson,
      if (address != null) 'address': address,
      if (notes != null) 'notes': notes,
      'is_active': isActive,
    };
  }

  DonationPartnerModel copyWith({
    String? id,
    String? messId,
    String? name,
    String? contactPhone,
    String? contactPerson,
    String? address,
    String? notes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DonationPartnerModel(
      id: id ?? this.id,
      messId: messId ?? this.messId,
      name: name ?? this.name,
      contactPhone: contactPhone ?? this.contactPhone,
      contactPerson: contactPerson ?? this.contactPerson,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
