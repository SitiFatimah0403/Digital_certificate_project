String getRedirectRoute(String role) {
  switch (role) {
    case 'Admin':
      return '/adminDashboard';
    case 'CA':
      return '/caDashboard';
    case 'Client' :
      return '/clientDashboard';
    case 'Viewer' :
      return '/viewerDashboard';
    default:
      return '/recipientDashboard';
  }
}
