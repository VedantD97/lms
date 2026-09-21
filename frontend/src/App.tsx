import { BrowserRouter, Navigate, Route, Routes } from "react-router-dom";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { AuthProvider } from "@/lib/auth/AuthContext";
import { ProtectedRoute } from "@/lib/auth/ProtectedRoute";
import { RoleGuard } from "@/lib/auth/RoleGuard";
import { AdminLayout, InstructorLayout, StudentLayout } from "@/components/layout/DashboardLayouts";
import { LoginPage } from "@/pages/auth/LoginPage";
import { RegisterPage } from "@/pages/auth/RegisterPage";
import { HomeRedirect } from "@/pages/HomeRedirect";
import { AdminCoursesPage } from "@/pages/admin/AdminCoursesPage";
import { AdminCourseEditorPage } from "@/pages/admin/AdminCourseEditorPage";
import { AdminCategoriesPage } from "@/pages/admin/AdminCategoriesPage";
import { AdminQuizzesPage } from "@/pages/admin/AdminQuizzesPage";
import { AdminCertificatesPage } from "@/pages/admin/AdminCertificatesPage";
import { AdminAnnouncementsPage } from "@/pages/admin/AdminAnnouncementsPage";
import { AdminReviewsPage } from "@/pages/admin/AdminReviewsPage";
import { AdminDashboardPage } from "@/pages/admin/AdminDashboardPage";
import { AdminReportsPage } from "@/pages/admin/AdminReportsPage";
import { AdminAuditLogsPage } from "@/pages/admin/AdminAuditLogsPage";
import { InstructorCoursesPage } from "@/pages/instructor/InstructorCoursesPage";
import { InstructorDashboardPage } from "@/pages/instructor/InstructorDashboardPage";
import { InstructorCourseStudentsPage } from "@/pages/instructor/InstructorCourseStudentsPage";
import { InstructorGradingQueuePage } from "@/pages/instructor/InstructorGradingQueuePage";
import { InstructorCourseEditorPage } from "@/pages/instructor/InstructorCourseEditorPage";
import { InstructorQuizEditorPage } from "@/pages/instructor/InstructorQuizEditorPage";
import { InstructorAssignmentEditorPage } from "@/pages/instructor/InstructorAssignmentEditorPage";
import { StudentMyCoursesPage } from "@/pages/student/StudentMyCoursesPage";
import { StudentDashboardPage } from "@/pages/student/StudentDashboardPage";
import { StudentLessonPage } from "@/pages/student/StudentLessonPage";
import { StudentCatalogPage } from "@/pages/student/StudentCatalogPage";
import { StudentCourseDetailPage } from "@/pages/student/StudentCourseDetailPage";
import { StudentQuizPage } from "@/pages/student/StudentQuizPage";
import { StudentQuizResultsPage } from "@/pages/student/StudentQuizResultsPage";
import { StudentAssignmentPage } from "@/pages/student/StudentAssignmentPage";
import { StudentCertificatesPage } from "@/pages/student/StudentCertificatesPage";
import { StudentNotificationsPage } from "@/pages/student/StudentNotificationsPage";

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 30_000,
      retry: 1,
    },
  },
});

export default function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <AuthProvider>
        <BrowserRouter>
          <Routes>
            <Route path="/login" element={<LoginPage />} />
            <Route path="/register" element={<RegisterPage />} />
            <Route element={<ProtectedRoute />}>
              <Route path="/" element={<HomeRedirect />} />

              <Route path="/admin" element={<RoleGuard roles={["admin", "super_admin"]} />}>
                <Route element={<AdminLayout />}>
                  <Route index element={<Navigate to="dashboard" replace />} />
                  <Route path="dashboard" element={<AdminDashboardPage />} />
                  <Route path="reports" element={<AdminReportsPage />} />
                  <Route path="courses" element={<AdminCoursesPage />} />
                  <Route path="courses/:uuid" element={<AdminCourseEditorPage />} />
                  <Route path="categories" element={<AdminCategoriesPage />} />
                  <Route path="quizzes" element={<AdminQuizzesPage />} />
                  <Route path="certificates" element={<AdminCertificatesPage />} />
                  <Route path="announcements" element={<AdminAnnouncementsPage />} />
                  <Route path="reviews" element={<AdminReviewsPage />} />
                  <Route path="audit-logs" element={<AdminAuditLogsPage />} />
                </Route>
              </Route>

              <Route path="/instructor" element={<RoleGuard roles={["instructor"]} />}>
                <Route element={<InstructorLayout />}>
                  <Route index element={<Navigate to="dashboard" replace />} />
                  <Route path="dashboard" element={<InstructorDashboardPage />} />
                  <Route path="courses" element={<InstructorCoursesPage />} />
                  <Route path="courses/:uuid/students" element={<InstructorCourseStudentsPage />} />
                  <Route path="courses/:uuid" element={<InstructorCourseEditorPage />} />
                  <Route path="grading" element={<InstructorGradingQueuePage />} />
                  <Route path="quizzes/:uuid" element={<InstructorQuizEditorPage />} />
                  <Route path="assignments/:uuid" element={<InstructorAssignmentEditorPage />} />
                </Route>
              </Route>

              <Route path="/student" element={<RoleGuard roles={["student"]} />}>
                <Route element={<StudentLayout />}>
                  <Route index element={<Navigate to="dashboard" replace />} />
                  <Route path="dashboard" element={<StudentDashboardPage />} />
                  <Route path="my-courses" element={<StudentMyCoursesPage />} />
                  <Route path="certificates" element={<StudentCertificatesPage />} />
                  <Route path="notifications" element={<StudentNotificationsPage />} />
                  <Route path="catalog" element={<StudentCatalogPage />} />
                  <Route path="courses/:uuid" element={<StudentCourseDetailPage />} />
                  <Route path="enrollments/:enrollmentUuid/lessons/:lessonUuid" element={<StudentLessonPage />} />
                  <Route path="enrollments/:enrollmentUuid/quizzes/:quizUuid" element={<StudentQuizPage />} />
                  <Route
                    path="enrollments/:enrollmentUuid/quizzes/:quizUuid/results/:attemptUuid"
                    element={<StudentQuizResultsPage />}
                  />
                  <Route
                    path="enrollments/:enrollmentUuid/assignments/:assignmentUuid"
                    element={<StudentAssignmentPage />}
                  />
                </Route>
              </Route>
            </Route>

            <Route path="*" element={<Navigate to="/" replace />} />
          </Routes>
        </BrowserRouter>
      </AuthProvider>
    </QueryClientProvider>
  );
}
