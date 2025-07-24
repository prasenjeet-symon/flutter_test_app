class ApiService {
  // Simulated API delay
  Future<void> _simulateDelay() async => await Future.delayed(const Duration(seconds: 1));

  // Fetch profile overview
  Future<Map<String, String>> fetchProfileOverview() async {
    try {
      await _simulateDelay();
      return {'orgs': '0', 'goals': '0', 'connections': '120', 'followers': '350', 'joinedOrgs': '0', 'groups': '5', 'posts': '42', 'following': '180'};
    } catch (e) {
      throw Exception('Failed to fetch profile overview: $e');
    }
  }

  // Fetch goals
  Future<List<String>> fetchGoals() async {
    try {
      await _simulateDelay();
      return ['Launch a non-profit by 2026|2026-12-31', 'Mentor 100 young professionals|2025-12-31'];
    } catch (e) {
      throw Exception('Failed to fetch goals: $e');
    }
  }

  // Fetch social links
  Future<List<Map<String, String>>> fetchSocialLinks() async {
    try {
      await _simulateDelay();
      return [
        {'platform': 'LinkedIn', 'url': 'https://linkedin.com/in/johndoe'},
        {'platform': 'Twitter', 'url': 'https://twitter.com/johndoe'},
      ];
    } catch (e) {
      throw Exception('Failed to fetch social links: $e');
    }
  }

  // Simulate adding a social link
  Future<void> addSocialLink(String url) async {
    try {
      await _simulateDelay();
      // Simulate success
    } catch (e) {
      throw Exception('Failed to add social link: $e');
    }
  }

  // Simulate importing LinkedIn profile
  Future<void> importLinkedInProfile(String url) async {
    try {
      await _simulateDelay();
      // Simulate success
    } catch (e) {
      throw Exception('Failed to import LinkedIn profile: $e');
    }
  }
}
