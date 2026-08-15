//String baseUri = 'https://yashagroapp.in';
class ApiRoutes {
  //static String baseUri = 'https://dev-api.yashagroapp.in';
  static String baseUri = 'https://yashagroapp.in';
  static String chatRoomsEndpoint = '/api/chats/v2/rooms';
  static String chatHistoryEndpoint = '/api/chats/expertchat/v2/history/';
  static String startChatEndpoint = '/api/chats/start';
  static String sendMessageEndpoint = '/api/chats/send';
  static String userProfileEndpoint = '/api/auth/profile';
  static String plotsEndpoint = '/api/plots/';
  static String plotDetailsEndpoint = '/api/plots-details/';
  static String cropsEndpoint = '/api/crops';
  static String cropVarietiesEndpoint = '/api/crops/crop-varieties/';
  static String pruningTypesEndpoint = '/api/crops/pruningtype';
  static String plantationTypesEndpoint = '/api/crops/plantation';
  static String employeeTargetRangeEndpoint = '/api/employee-target-range';
  static String employeeCompletedTargetsEndpoint =
      '/api/employee-completed-targets';
  static String sendOtpEndpoint = '/api/auth/send-otp';
  static String verifyOtpEndpoint = '/api/auth/verify-otp';
  static String labReportsEndpoint = '/api/lab-reports-expert/';
  static String authEndpoint = '/api/auth';
  static String expertWorkEndpoint = '/api/expertwork?user_id=';
  static String createVisitEndpoint = '/api/visit/create';

  // Visit Request Endpoints
  static String approveVisitRequestEndpoint =
      '/api/visit-request/approve/'; // + {request_id}
  static String rejectVisitRequestEndpoint =
      '/api/visit-request/reject/'; // + {request_id}
  static String getAllVisitsEndpoint = '/api/visits';
  static String getMyVisitsEndpoint = '/api/my-visits';
  static String getTodayVisitsEndpoint = '/api/today-visits';
  static String getVisitDetailsEndpoint = '/api/visit/'; // + {id}
  static String updateVisitStatusEndpoint = '/api/visit/status/'; // + {id}
  static String getVisitStatusHistoryEndpoint =
      '/api/visit-status-history/'; // + {visit_id}
  static String getUpcomingVisitsEndpoint = '/api/upcoming-visits';

  // Visit Feedback Endpoints
  static String submitVisitFeedbackEndpoint = '/api/visit-feedback';
  static String updateVisitFeedbackEndpoint = '/api/visit-feedback/'; // + {id}
  static String getVisitFeedbackEndpoint =
      '/api/visit-feedback/'; // + {visit_id}
  static String getMyFeedbacksEndpoint = '/api/my-feedbacks';

  // Employee Tracking Endpoints
  static String startWorkEndpoint = '/api/employee/start-work';
  static String endWorkEndpoint = '/api/employee/end-work';
  static String locationEndpoint = '/api/employee/location';
  static String currentWorkStatusEndpoint = '/api/employee/current-status';
  static String employeeDashboardEndpoint = '/api/employee-dashboard';
  static String employeeDashboardTodaySummaryEndpoint =
      '/api/employee-dashboard/today-summary';
  static String employeeDashboardMonthSummaryEndpoint =
      '/api/employee-dashboard/month-summary';
  static String employeeRouteHistoryEndpoint = '/api/employee-route-history';
  static String marketerMarkVisitEndpoint = '/api/emp-mark-visit';

  // Manager Endpoints
  static String assignEmployeeEndpoint = '/api/manager/assign-employee';
  static String assignEmployeesEndpoint = '/api/manager/assign-employees';
  static String managerAssignmentsEndpoint = '/api/manager/assignments';
  static String assignTargetEndpoint = '/api/manager-target/create';
  static String updateTargetEndpoint = '/api/manager-target/update/'; // + {id}
  static String deleteTargetEndpoint = '/api/manager-target/delete/'; // + {id}
  static String getEmployeeTargetsEndpoint =
      '/api/manager-target/manager/'; // + {employee_id}
  static String myTargetsEndpoint = '/api/manager-target/my-targets';
  static String employeeManagerEndpoint =
      '/api/employee/'; // + {employee_id}/manager
  static String myEmployeesEndpoint = '/api/manager/my-employees';
  static String managerEmployeesEndpoint =
      '/api/manager/'; // + {manager_id}/employees
  static String removeEmployeeEndpoint = '/api/manager/remove-employee';
  static String changeManagerEndpoint = '/api/manager/change-manager';

  // Admin Endpoints
  static String adminUsersEndpoint = '/api/admin/users';
}
