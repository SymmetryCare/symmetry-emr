class ResidenceTypeData{
  final int id;
  final String detail;
  final String description;

  ResidenceTypeData({
    required this.id,
    required this.detail,
    required this.description,
});
}

class RelatedPartiesRoleData{
  final int roleId;
  final String roleName;
  final String roleDiscription;

  RelatedPartiesRoleData({required this.roleId, required this.roleName, required this.roleDiscription});
}

class RelatedPatiesTypeData{
  final int typeId;
  final String typeName;
  final String typeDiscription;
  RelatedPatiesTypeData({required this.typeId, required this.typeName, required this.typeDiscription});
}