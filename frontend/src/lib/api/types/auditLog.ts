export interface AuditLogActor {
  uuid: string;
  email: string;
  first_name: string;
  last_name: string;
}

export interface AuditLogAuditable {
  type: string;
  uuid: string | null;
}

export interface AuditLog {
  uuid: string;
  action: string;
  changes: Record<string, unknown>;
  ip_address?: string | null;
  actor: AuditLogActor;
  auditable?: AuditLogAuditable | null;
  created_at: string;
}
