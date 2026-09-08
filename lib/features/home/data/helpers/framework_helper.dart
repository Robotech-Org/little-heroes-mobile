import '../models/competency_model.dart';
import '../models/level_model.dart';

class FrameworkHelper {
  // Get all competencies grouped by domain
  static Map<String, List<CompetencyModel>> getDomainGroups(
    List<CompetencyModel> competencies,
  ) {
    final Map<String, List<CompetencyModel>> domainMap = {};

    for (var competency in competencies) {
      if (!domainMap.containsKey(competency.domain)) {
        domainMap[competency.domain] = [];
      }
      domainMap[competency.domain]!.add(competency);
    }

    // Sort each domain's competencies by sequence
    for (var key in domainMap.keys) {
      domainMap[key]!.sort((a, b) => a.sequence.compareTo(b.sequence));
    }

    return domainMap;
  }

  // Get domain icon
  static String getDomainIcon(String domainName) {
    switch (domainName) {
      case 'Approaches to Learning':
        return '🧠';
      case 'Social and Emotional Development':
        return '❤️';
      case 'Physical Development and Health':
        return '💪';
      case 'Language, Literacy and Communication':
        return '📚';
      case 'Mathematics':
        return '🔢';
      case 'Creative Art':
        return '🎨';
      case 'Science and Technology':
        return '🔬';
      case 'Social Studies':
        return '🌍';
      default:
        return '📋';
    }
  }
}
