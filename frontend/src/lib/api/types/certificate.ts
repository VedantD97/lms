export interface Certificate {
  uuid: string;
  certificate_number: string;
  issued_at: string;
  revoked_at?: string | null;
  revoked?: boolean;
  enrollment_uuid?: string;
  completed_at?: string | null;
  course: {
    uuid: string;
    title: string;
    slug: string;
  };
  student?: {
    uuid: string;
    first_name: string;
    last_name: string;
    email: string;
  };
}

export interface EnrollmentCertificate {
  uuid: string;
  certificate_number: string;
  issued_at: string;
}
