import 'competency_model.dart';

class FrameworkDomainGroup {
  final String domain;
  final List<CompetencyModel> competencies;

  FrameworkDomainGroup({required this.domain, required this.competencies});

  factory FrameworkDomainGroup.fromCompetencies(
    List<CompetencyModel> competencies,
  ) {
    final domainMap = <String, List<CompetencyModel>>{};

    for (var competency in competencies) {
      if (!domainMap.containsKey(competency.domain)) {
        domainMap[competency.domain] = [];
      }
      domainMap[competency.domain]!.add(competency);
    }

    return FrameworkDomainGroup(
      domain: domainMap.keys.first,
      competencies: domainMap.values.first,
    );
  }

  static List<FrameworkDomainGroup> groupByDomain(
    List<CompetencyModel> competencies,
  ) {
    final domainMap = <String, List<CompetencyModel>>{};

    for (var competency in competencies) {
      if (!domainMap.containsKey(competency.domain)) {
        domainMap[competency.domain] = [];
      }
      domainMap[competency.domain]!.add(competency);
    }

    return domainMap.entries.map((entry) {
      return FrameworkDomainGroup(domain: entry.key, competencies: entry.value);
    }).toList();
  }
}
