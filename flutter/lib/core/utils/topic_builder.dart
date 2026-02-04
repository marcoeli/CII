class TopicBuilder {
  static String base(String tenantId, String homeId) {
    return 'home/$tenantId/$homeId';
  }

  static String devicesStatusWildcard(String tenantId, String homeId) {
    return '${base(tenantId, homeId)}/device/+/status';
  }

  static String resourceMetaWildcard(String tenantId, String homeId) {
    return '${base(tenantId, homeId)}/meta/resource/#';
  }

  static String resourceLeafWildcard(
    String tenantId,
    String homeId,
    String leaf,
  ) {
    // leaf: state, data, config
    return '${base(tenantId, homeId)}/r/+/$leaf';
  }

  static String resourceCommand(
    String tenantId,
    String homeId,
    String resourceId,
  ) {
    return '${base(tenantId, homeId)}/r/$resourceId/command';
  }

  static String eventsWildcard(String tenantId, String homeId) {
    return '${base(tenantId, homeId)}/event/#';
  }
}
