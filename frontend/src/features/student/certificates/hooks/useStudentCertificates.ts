import { useQuery } from "@tanstack/react-query";
import { fetchStudentCertificate, fetchStudentCertificates } from "@/features/student/certificates/api/studentCertificatesApi";

export function useStudentCertificates() {
  return useQuery({
    queryKey: ["student", "certificates"],
    queryFn: async () => (await fetchStudentCertificates()).data,
  });
}

export function useStudentCertificate(uuid: string) {
  return useQuery({
    queryKey: ["student", "certificates", uuid],
    queryFn: async () => (await fetchStudentCertificate(uuid)).data,
    enabled: Boolean(uuid),
  });
}
