import 'package:little_heroes_mobile/features/home/data/models/framework_model.dart';

class LearningFramework {
  static List<FrameworkModel> getFramework() {
    return [
      // Domain: Approaches to Learning
      FrameworkModel(
        domain: 'Approaches to Learning',
        domainCode: 'AL',
        description: 'How children approach learning tasks and solve problems',
        categories: [
          CategoryModel(
            id: 'al_1',
            name: 'Initiative and Planning', // This is the name
            code: 'AL1', // This is the code
            description:
                'Child shows initiative and ability to plan activities',
            levels: [
              LevelModel(
                level: 0,
                description:
                    'Child turns toward or away from an object or person.',
                indicator: 'Shows basic awareness',
              ),
              LevelModel(
                level: 1,
                description: 'Child continues moving or acting until reaching a desired object or person.',
                indicator: 'Shows persistence',
              ),
              LevelModel(
                level: 2,
                description: 'Child shows an intention using one or two words.',
                indicator: 'Uses simple language',
              ),
              LevelModel(
                level: 3,
                description:
                    'Child states a simple plan and follows through with it.',
                indicator: 'States and follows a plan',
              ),
              LevelModel(
                level: 4,
                description:
                    'Child makes and completes two or more unrelated plans.',
                indicator: 'Multi-step planning',
              ),
              LevelModel(
                level: 5,
                description: 'Child stays with a self-made plan for a substantial period of time.',
                indicator: 'Sustained engagement',
              ),
            ],
          ),
          CategoryModel(
            id: 'al_2',
            name: 'Problem Solving with Materials',
            code: 'AL2',
            description: 'Child\'s ability to solve problems using materials',
            levels: [
              LevelModel(
                level: 0,
                description: 'Child moves eyes, head, or hands toward a desired object or person.',
                indicator: 'Shows interest',
              ),
              LevelModel(
                level: 1,
                description:
                    'Child repeats an action, even when it is not working.',
                indicator: 'Repeats actions',
              ),
              LevelModel(
                level: 2,
                description: 'Child asks for help when solving a problem.',
                indicator: 'Asks for help',
              ),
              LevelModel(
                level: 3,
                description: 'Child verbally identifies a problem.',
                indicator: 'Identifies problems',
              ),
              LevelModel(
                level: 4,
                description:
                    'Child persists with one idea or tries several ideas.',
                indicator: 'Problem solves independently',
              ),
              LevelModel(
                level: 5,
                description: 'Child helps another child solve a problem.',
                indicator: 'Helps others',
              ),
            ],
          ),
          CategoryModel(
            id: 'al_3',
            name: 'Reflection',
            code: 'AL3',
            description: 'Child\'s ability to reflect on experiences',
            levels: [
              LevelModel(
                level: 0,
                description: 'Child returns attention to an object or event of interest.',
                indicator: 'Shows recall',
              ),
              LevelModel(
                level: 1,
                description: 'Child shows that he or she wants something to happen again.',
                indicator: 'Shows preference',
              ),
              LevelModel(
                level: 2,
                description: 'Child returns to a place where something wanted or previously played with is located.',
                indicator: 'Spatial recall',
              ),
              LevelModel(
                level: 3,
                description:
                    'Child says one thing he or she did soon after the event.',
                indicator: 'Simple recall',
              ),
              LevelModel(
                level: 4,
                description: 'Child recalls three or more things done.',
                indicator: 'Detailed recall',
              ),
              LevelModel(
                level: 5,
                description: 'Child independently recalls the sequence of three or more actions.',
                indicator: 'Sequential recall',
              ),
            ],
          ),
        ],
      ),
      // Domain: Social-Emotional Development
      FrameworkModel(
        domain: 'Social-Emotional Development',
        domainCode: 'SE',
        description: 'How children manage emotions and build relationships',
        categories: [
          CategoryModel(
            id: 'se_1',
            name: 'Emotional Expression and Regulation',
            code: 'SE1',
            description: 'Child\'s ability to express and regulate emotions',
            levels: [
              LevelModel(
                level: 0,
                description: 'Child expresses emotions through facial expressions and/or body movements.',
                indicator: 'Non-verbal expression',
              ),
              LevelModel(
                level: 1,
                description: 'Child responds to emotional experiences in recognizable ways.',
                indicator: 'Responds to emotions',
              ),
              LevelModel(
                level: 2,
                description:
                    'Child begins to communicate or identify feelings.',
                indicator: 'Communicates feelings',
              ),
              LevelModel(
                level: 3,
                description: 'Child names or describes personal feelings.',
                indicator: 'Names feelings',
              ),
              LevelModel(
                level: 4,
                description: 'Child recognizes and responds appropriately to feelings in self and others.',
                indicator: 'Empathy',
              ),
              LevelModel(
                level: 5,
                description: 'Child increasingly regulates emotions and uses appropriate strategies.',
                indicator: 'Self-regulation',
              ),
            ],
          ),
          CategoryModel(
            id: 'se_2',
            name: 'Building Relationships with Adults',
            code: 'SE2',
            description: 'Child\'s ability to build relationships with adults',
            levels: [
              LevelModel(
                level: 0,
                description: 'Child shows awareness of familiar adults.',
                indicator: 'Awareness',
              ),
              LevelModel(
                level: 1,
                description: 'Child seeks comfort, attention, or interaction from an adult.',
                indicator: 'Seeks interaction',
              ),
              LevelModel(
                level: 2,
                description: 'Child responds to familiar adults through gestures, sounds, or simple communication.',
                indicator: 'Responds to adults',
              ),
              LevelModel(
                level: 3,
                description: 'Child participates in positive interactions and communication with adults.',
                indicator: 'Positive interactions',
              ),
              LevelModel(
                level: 4,
                description: 'Child develops trusting relationships and works cooperatively with adults.',
                indicator: 'Trusting relationships',
              ),
              LevelModel(
                level: 5,
                description: 'Child independently maintains positive, respectful, and purposeful relationships with adults.',
                indicator: 'Independent relationships',
              ),
            ],
          ),
          CategoryModel(
            id: 'se_3',
            name: 'Building Relationships with Other Children',
            code: 'SE3',
            description: 'Child\'s ability to build relationships with peers',
            levels: [
              LevelModel(
                level: 0,
                description:
                    'Child notices or shows interest in other children.',
                indicator: 'Notices peers',
              ),
              LevelModel(
                level: 1,
                description:
                    'Child stays near or observes other children during play.',
                indicator: 'Observes peers',
              ),
              LevelModel(
                level: 2,
                description: 'Child responds to another child through actions, gestures, or simple communication.',
                indicator: 'Responds to peers',
              ),
              LevelModel(
                level: 3,
                description:
                    'Child plays or interacts directly with another child.',
                indicator: 'Direct interaction',
              ),
              LevelModel(
                level: 4,
                description: 'Child cooperates, shares ideas, and participates in sustained play with peers.',
                indicator: 'Cooperative play',
              ),
              LevelModel(
                level: 5,
                description: 'Child builds and maintains positive friendships and cooperative relationships.',
                indicator: 'Positive friendships',
              ),
            ],
          ),
          CategoryModel(
            id: 'se_4',
            name: 'Community and Classroom Participation',
            code: 'SE4',
            description: 'Child\'s participation in community and classroom',
            levels: [
              LevelModel(
                level: 0,
                description: 'Child shows awareness of people and routines.',
                indicator: 'Awareness of environment',
              ),
              LevelModel(
                level: 1,
                description: 'Child begins participating in familiar routines with adult support.',
                indicator: 'Participates with support',
              ),
              LevelModel(
                level: 2,
                description: 'Child follows simple routines or expectations.',
                indicator: 'Follows routines',
              ),
              LevelModel(
                level: 3,
                description: 'Child participates in group activities and shared classroom routines.',
                indicator: 'Group participation',
              ),
              LevelModel(
                level: 4,
                description: 'Child understands that group members have roles and responsibilities.',
                indicator: 'Understands roles',
              ),
              LevelModel(
                level: 5,
                description: 'Child contributes independently and responsibly to the classroom or community.',
                indicator: 'Independent contribution',
              ),
            ],
          ),
          CategoryModel(
            id: 'se_5',
            name: 'Conflict Resolution',
            code: 'SE5',
            description: 'Child\'s ability to resolve conflicts',
            levels: [
              LevelModel(
                level: 0,
                description:
                    'Child reacts when a conflict or social problem occurs.',
                indicator: 'Reacts to conflict',
              ),
              LevelModel(
                level: 1,
                description: 'Child seeks adult help during a conflict.',
                indicator: 'Seeks adult help',
              ),
              LevelModel(
                level: 2,
                description: 'Child communicates a problem or disagreement using actions or simple words.',
                indicator: 'Communicates conflict',
              ),
              LevelModel(
                level: 3,
                description: 'Child identifies the conflict and begins expressing a possible solution.',
                indicator: 'Identifies solutions',
              ),
              LevelModel(
                level: 4,
                description: 'Child participates with others in finding and trying a solution.',
                indicator: 'Collaborative problem solving',
              ),
              LevelModel(
                level: 5,
                description: 'Child independently uses appropriate problem-solving and negotiation strategies.',
                indicator: 'Independent conflict resolution',
              ),
            ],
          ),
        ],
      ),
    ];
  }

  // Server to Framework mapping
  static final Map<String, String> _serverCompetencyMap = {
    'GG': 'AL1', // Geography -> Initiative and Planning
    'Initiative and Planning': 'AL1',
    'Problem Solving with Materials': 'AL2',
    'Reflection': 'AL3',
    'Emotional Expression and Regulation': 'SE1',
    'Building Relationships with Adults': 'SE2',
    'Building Relationships with Other Children': 'SE3',
    'Community and Classroom Participation': 'SE4',
    'Conflict Resolution': 'SE5',
    // Add more mappings as needed
  };

  // Framework to Server mapping (reverse)
  static final Map<String, String> _frameworkToServerMap = {
    'AL1': 'Initiative and Planning',
    'AL2': 'Problem Solving with Materials',
    'AL3': 'Reflection',
    'SE1': 'Emotional Expression and Regulation',
    'SE2': 'Building Relationships with Adults',
    'SE3': 'Building Relationships with Other Children',
    'SE4': 'Community and Classroom Participation',
    'SE5': 'Conflict Resolution',
  };

  // Get server competency from framework code
  static String getServerCompetency(String frameworkCode) {
    return _frameworkToServerMap[frameworkCode] ?? frameworkCode;
  }

  // Get framework code from server competency
  static String getFrameworkCode(String serverCompetency) {
    return _serverCompetencyMap[serverCompetency] ?? serverCompetency;
  }

  // Helper method to get a category by its code
  static CategoryModel? getCategoryByCode(String code) {
    for (var domain in getFramework()) {
      for (var category in domain.categories) {
        if (category.code == code) {
          return category;
        }
      }
    }
    return null;
  }

  // Helper method to get a category by its name
  static CategoryModel? getCategoryByName(String name) {
    for (var domain in getFramework()) {
      for (var category in domain.categories) {
        if (category.name == name) {
          return category;
        }
      }
    }
    return null;
  }

  // Helper method to get all categories as a flat list
  static List<CategoryModel> getAllCategories() {
    final List<CategoryModel> categories = [];
    for (var domain in getFramework()) {
      categories.addAll(domain.categories);
    }
    return categories;
  }

  // Helper method to get a domain by its code
  static FrameworkModel? getDomainByCode(String code) {
    for (var domain in getFramework()) {
      if (domain.domainCode == code) {
        return domain;
      }
    }
    return null;
  }
}
