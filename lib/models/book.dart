// lib/models/book.dart
// import 'package:flutter/foundation.dart';

// ignore_for_file: non_constant_identifier_names

class Book {
  final String id;
  final String title;
  final String? author;
  final String? description;
  final String? coverUrl;
  final String? category;
  final String? isbn;
  final String? status;
  final String? location;
  final String? coverColor;
  final int? copies;
  final int? totalCopies;
  final DateTime? dateAdded;
  final double? price;
  final double? cost_price;
  final bool is_deleted;

  Book({
    required this.id,
    required this.title,
    this.author,
    this.description,
    this.coverUrl,
    this.category,
    this.isbn,
    this.status,
    this.location,
    this.coverColor,
    this.copies,
    this.totalCopies,
    this.dateAdded,
    this.price,
    this.cost_price,
    this.is_deleted = false,
  });

  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? description,
    String? coverUrl,
    String? category,
    String? isbn,
    String? status,
    String? location,
    String? coverColor,
    int? copies,
    int? totalCopies,
    DateTime? dateAdded,
    double? price,
    double? cost_price,
    bool? is_deleted,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      description: description ?? this.description,
      coverUrl: coverUrl ?? this.coverUrl,
      category: category ?? this.category,
      isbn: isbn ?? this.isbn,
      status: status ?? this.status,
      location: location ?? this.location,
      coverColor: coverColor ?? this.coverColor,
      copies: copies ?? this.copies,
      totalCopies: totalCopies ?? this.totalCopies,
      dateAdded: dateAdded ?? this.dateAdded,
      price: price ?? this.price,
      cost_price: cost_price ?? this.cost_price,
      is_deleted: is_deleted ?? this.is_deleted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'description': description,
      'coverUrl': coverUrl,
      'category': category,
      'isbn': isbn,
      'status': status,
      'location': location,
      'coverColor': coverColor,
      'copies': copies,
      'totalCopies': totalCopies,
      'dateAdded': dateAdded?.toIso8601String(),
      'price': price,
      'cost_price': cost_price,
      'is_deleted': is_deleted,
    };
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      author: map['author'],
      description: map['description'],
      coverUrl: map['coverUrl'],
      category: map['category'],
      isbn: map['isbn'],
      status: map['status'],
      location: map['location'],
      coverColor: map['coverColor'],
      copies: map['copies'],
      totalCopies: map['totalCopies'],
      dateAdded:
          map['dateAdded'] != null ? DateTime.parse(map['dateAdded']) : null,
      price: map['price'] != null ? (map['price'] as num).toDouble() : null,
      cost_price: map['cost_price'] != null
          ? (map['cost_price'] as num).toDouble()
          : null,
      is_deleted: map['is_deleted'] == true,
    );
  }
}
