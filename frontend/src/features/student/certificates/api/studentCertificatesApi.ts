import { apiGet } from "@/lib/api/client";
import type { Certificate } from "@/lib/api/types/certificate";

const base = "/student";

export async function fetchStudentCertificates() {
  return apiGet<Certificate[]>(`${base}/certificates`);
}

export async function fetchStudentCertificate(uuid: string) {
  return apiGet<Certificate>(`${base}/certificates/${uuid}`);
}
