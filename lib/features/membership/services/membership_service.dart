class MembershipService {
  Future<Map<String, dynamic>?> getMembershipInfo() async {
    return null;
  }

  Future<List<Map<String, dynamic>>> getMembershipPlans() async {
    return [];
  }

  Future<bool> purchaseMembership(String planId) async {
    return false;
  }

  Future<bool> cancelMembership() async {
    return false;
  }
}