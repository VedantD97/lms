import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { fetchAdminCertificates, revokeCertificate } from "@/features/admin/certificates/api/adminCertificatesApi";

export function useAdminCertificates(params?: Record<string, string | number | undefined>) {
  return useQuery({
    queryKey: ["admin", "certificates", params],
    queryFn: () => fetchAdminCertificates(params),
  });
}

export function useRevokeCertificate() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: revokeCertificate,
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["admin", "certificates"] }),
  });
}
