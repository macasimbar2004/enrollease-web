import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Filter criteria for different data types
class FilterCriteria {
  final String? searchQuery;
  final Map<String, dynamic>? fieldFilters;
  final List<String>? multiSelectFilters;
  final Map<String, List<String>>? multiFieldFilters;
  final String? sortBy;
  final bool sortDescending;
  final int? limit;

  const FilterCriteria({
    this.searchQuery,
    this.fieldFilters,
    this.multiSelectFilters,
    this.multiFieldFilters,
    this.sortBy,
    this.sortDescending = false,
    this.limit,
  });

  FilterCriteria copyWith({
    String? searchQuery,
    Map<String, dynamic>? fieldFilters,
    List<String>? multiSelectFilters,
    Map<String, List<String>>? multiFieldFilters,
    String? sortBy,
    bool? sortDescending,
    int? limit,
  }) {
    return FilterCriteria(
      searchQuery: searchQuery ?? this.searchQuery,
      fieldFilters: fieldFilters ?? this.fieldFilters,
      multiSelectFilters: multiSelectFilters ?? this.multiSelectFilters,
      multiFieldFilters: multiFieldFilters ?? this.multiFieldFilters,
      sortBy: sortBy ?? this.sortBy,
      sortDescending: sortDescending ?? this.sortDescending,
      limit: limit ?? this.limit,
    );
  }
}

/// Filter result with metadata
class FilterResult<T> {
  final List<T> data;
  final int totalCount;
  final int filteredCount;
  final bool hasMore;
  final String? error;

  const FilterResult({
    required this.data,
    required this.totalCount,
    required this.filteredCount,
    this.hasMore = false,
    this.error,
  });
}

/// Centralized filter management system for the application
class FilterManager {
  static const String _debugTag = 'FilterManager';

  /// Apply filters to a Firestore query
  static Query<Map<String, dynamic>> applyFilters(
    CollectionReference<Map<String, dynamic>> collection,
    FilterCriteria criteria,
  ) {
    Query<Map<String, dynamic>> query = collection;

    // Apply field filters (exact matches)
    if (criteria.fieldFilters != null) {
      for (final entry in criteria.fieldFilters!.entries) {
        if (entry.value != null) {
          query = query.where(entry.key, isEqualTo: entry.value);
        }
      }
    }

    // Apply multi-field filters (array-contains-any)
    if (criteria.multiFieldFilters != null) {
      for (final entry in criteria.multiFieldFilters!.entries) {
        if (entry.value.isNotEmpty) {
          query = query.where(entry.key, arrayContainsAny: entry.value);
        }
      }
    }

    // Apply sorting
    if (criteria.sortBy != null) {
      query = query.orderBy(criteria.sortBy!, descending: criteria.sortDescending);
    }

    // Apply limit
    if (criteria.limit != null) {
      query = query.limit(criteria.limit!);
    }

    return query;
  }

  /// Apply client-side filters to data
  static List<Map<String, dynamic>> applyClientSideFilters(
    List<Map<String, dynamic>> data,
    FilterCriteria criteria,
  ) {
    if (criteria.searchQuery == null || criteria.searchQuery!.trim().isEmpty) {
      return data;
    }

    final query = criteria.searchQuery!.trim().toLowerCase();
    final searchableFields = _getSearchableFields(data);

    return data.where((item) {
      return searchableFields.any((field) {
        final value = item[field]?.toString().toLowerCase() ?? '';
        return value.contains(query);
      });
    }).toList();
  }

  /// Get searchable fields from data structure
  static List<String> _getSearchableFields(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return [];

    final firstItem = data.first;
    final searchableFields = <String>[];

    // Common searchable fields across different collections
    final commonFields = [
      'id', 'firstName', 'lastName', 'fullName', 'fullname',
      'email', 'contact', 'phoneNumber', 'contactNumber',
      'userName', 'regNo', 'studentFullName', 'content',
      'title', 'type', 'status', 'userType', 'gradeLevel',
      'enrollingGrade', 'gradeLevelToApply'
    ];

    for (final field in commonFields) {
      if (firstItem.containsKey(field)) {
        searchableFields.add(field);
      }
    }

    return searchableFields;
  }

  /// Create a stream-based filter for real-time updates
  static Stream<List<Map<String, dynamic>>> createFilteredStream(
    CollectionReference<Map<String, dynamic>> collection,
    FilterCriteria criteria,
  ) {
    return applyFilters(collection, criteria).snapshots().map((snapshot) {
      final data = snapshot.docs.map((doc) {
        final docData = doc.data();
        docData['documentId'] = doc.id;
        return docData;
      }).toList();

      // Apply client-side filters (search query)
      return applyClientSideFilters(data, criteria);
    }).handleError((error) {
      if (kDebugMode) {
        print('$_debugTag: Error in filtered stream: $error');
      }
      return <Map<String, dynamic>>[];
    });
  }

  /// Create a paginated filter stream
  static Stream<FilterResult<Map<String, dynamic>>> createPaginatedFilterStream(
    CollectionReference<Map<String, dynamic>> collection,
    FilterCriteria criteria,
    int pageSize,
  ) {
    return applyFilters(collection, criteria)
        .limit(pageSize)
        .snapshots()
        .map((snapshot) {
      final data = snapshot.docs.map((doc) {
        final docData = doc.data();
        docData['documentId'] = doc.id;
        return docData;
      }).toList();

      final filteredData = applyClientSideFilters(data, criteria);
      final hasMore = snapshot.docs.length == pageSize;

      return FilterResult<Map<String, dynamic>>(
        data: filteredData,
        totalCount: snapshot.docs.length,
        filteredCount: filteredData.length,
        hasMore: hasMore,
      );
    }).handleError((error) {
      if (kDebugMode) {
        print('$_debugTag: Error in paginated stream: $error');
      }
      return const FilterResult<Map<String, dynamic>>(
        data: [],
        totalCount: 0,
        filteredCount: 0,
        error: 'Failed to load data',
      );
    });
  }

  /// Validate filter criteria
  static String? validateCriteria(FilterCriteria criteria) {
    // Check for conflicting filters
    if (criteria.fieldFilters != null && criteria.multiFieldFilters != null) {
      final conflictingFields = criteria.fieldFilters!.keys
          .toSet()
          .intersection(criteria.multiFieldFilters!.keys.toSet());
      
      if (conflictingFields.isNotEmpty) {
        return 'Conflicting filters for fields: ${conflictingFields.join(', ')}';
      }
    }

    // Check search query length
    if (criteria.searchQuery != null && criteria.searchQuery!.length < 2) {
      return 'Search query must be at least 2 characters long';
    }

    return null;
  }

  /// Create filter criteria for faculty/staff
  static FilterCriteria createFacultyStaffCriteria({
    String? searchQuery,
    String? userType,
    List<String>? roles,
    String? status,
    String sortBy = 'id',
    bool sortDescending = false,
  }) {
    final fieldFilters = <String, dynamic>{};
    final multiFieldFilters = <String, List<String>>{};

    if (userType != null && userType != 'All') {
      fieldFilters['userType'] = userType;
    }

    if (status != null && status != 'All') {
      fieldFilters['status'] = status;
    }

    if (roles != null && roles.isNotEmpty) {
      multiFieldFilters['roles'] = roles;
    }

    return FilterCriteria(
      searchQuery: searchQuery,
      fieldFilters: fieldFilters.isNotEmpty ? fieldFilters : null,
      multiFieldFilters: multiFieldFilters.isNotEmpty ? multiFieldFilters : null,
      sortBy: sortBy,
      sortDescending: sortDescending,
    );
  }

  /// Create filter criteria for students
  static FilterCriteria createStudentsCriteria({
    String? searchQuery,
    String? gradeLevel,
    String? status,
    String sortBy = 'lastName',
    bool sortDescending = false,
  }) {
    final fieldFilters = <String, dynamic>{};

    if (gradeLevel != null && gradeLevel != 'All') {
      fieldFilters['gradeLevel'] = gradeLevel;
    }

    if (status != null && status != 'All') {
      fieldFilters['status'] = status;
    }

    return FilterCriteria(
      searchQuery: searchQuery,
      fieldFilters: fieldFilters.isNotEmpty ? fieldFilters : null,
      sortBy: sortBy,
      sortDescending: sortDescending,
    );
  }

  /// Create filter criteria for enrollments
  static FilterCriteria createEnrollmentsCriteria({
    String? searchQuery,
    String? status,
    String? gradeLevel,
    String sortBy = 'timestamp',
    bool sortDescending = true,
  }) {
    final fieldFilters = <String, dynamic>{};

    if (status != null && status != 'All') {
      fieldFilters['status'] = status;
    }

    if (gradeLevel != null && gradeLevel != 'All') {
      fieldFilters['enrollingGrade'] = gradeLevel;
    }

    return FilterCriteria(
      searchQuery: searchQuery,
      fieldFilters: fieldFilters.isNotEmpty ? fieldFilters : null,
      sortBy: sortBy,
      sortDescending: sortDescending,
    );
  }
}
