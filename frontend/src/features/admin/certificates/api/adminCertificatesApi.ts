import { apiGet, apiPost } from "@/lib/api/client";
import type { Certificate } from "@/lib/api/types/certificate";

const base = "/admin";

export async function fetchAdminCertificates(params?: Record<string, string | number | undefined>) {
  return apiGet<Certificate[]>(`${base}/certificates`, params);
}

export async function revokeCertificate(uuid: string) {
  return apiPost<Certificate>(`${base}/certificates/${uuid}/revoke`);
}
