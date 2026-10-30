/// Ограничения семьи: бесплатный режим и премиум.
const int freeFamilyMemberLimit = 2;
const int premiumFamilyMemberLimit = 10;

/// Сколько медиафайлов доступно без премиума.
const int freeFamilyMediaLimit = 30;

int familyMemberLimit({required bool premium}) =>
    premium ? premiumFamilyMemberLimit : freeFamilyMemberLimit;
