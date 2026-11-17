import 'package:church_app/app/data/models/family_model.dart';
import 'package:church_app/app/data/models/house_model.dart';
import 'package:church_app/app/data/models/member_model.dart';
import 'package:church_app/app/modules/directory/controllers/directory_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final family = FamilyModel(
    name: 'Kalarickal',
    houses: [
      HouseModel(
        name: 'Rose Villa',
        members: [
          MemberModel(name: 'Thomas Mathew', phone: '9846012345'),
          MemberModel(name: 'Annie Thomas'),
        ],
      ),
      HouseModel(
        name: 'Bethel',
        members: [MemberModel(name: 'Joseph Kurian')],
      ),
    ],
  );

  group('DirectoryController.familyMatches', () {
    test('matches by family name, ignoring case', () {
      expect(DirectoryController.familyMatches(family, 'kalari'), isTrue);
    });

    test('matches by house name', () {
      expect(DirectoryController.familyMatches(family, 'rose'), isTrue);
      expect(DirectoryController.familyMatches(family, 'BETHEL'), isTrue);
    });

    test('matches by member name and phone', () {
      expect(DirectoryController.familyMatches(family, 'annie'), isTrue);
      expect(DirectoryController.familyMatches(family, 'joseph'), isTrue);
      expect(DirectoryController.familyMatches(family, '98460'), isTrue);
    });

    test('ignores surrounding spaces and matches all for empty query', () {
      expect(DirectoryController.familyMatches(family, '  annie  '), isTrue);
      expect(DirectoryController.familyMatches(family, ''), isTrue);
    });

    test('does not match unrelated text', () {
      expect(DirectoryController.familyMatches(family, 'xavier'), isFalse);
    });

    test('matches members listed directly on the family', () {
      final flat = FamilyModel(
        name: 'Puthenpura',
        members: [MemberModel(name: 'Mary George')],
      );
      expect(DirectoryController.familyMatches(flat, 'mary'), isTrue);
    });
  });

  group('DirectoryController.houseMatches', () {
    test('only the house containing the member matches', () {
      final rose = family.houses![0];
      final bethel = family.houses![1];
      expect(DirectoryController.houseMatches(rose, 'joseph'), isFalse);
      expect(DirectoryController.houseMatches(bethel, 'joseph'), isTrue);
    });
  });
}
