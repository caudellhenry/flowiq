// Shared FlowIQ types

export type UserRole = "owner" | "admin" | "member" | "viewer";

export interface Company {
  id: string;
  name: string;
  plan: "free" | "starter" | "pro" | "enterprise";
  createdAt: string;
}

export interface User {
  id: string;
  companyId: string;
  clerkId: string;
  role: UserRole;
  email: string;
  name: string;
  createdAt: string;
  updatedAt: string;
}

export interface Document {
  id: string;
  companyId: string;
  title: string;
  status: "pending" | "processing" | "ready" | "error";
  metadata: Record<string, unknown>;
  createdById: string;
  createdAt: string;
  updatedAt: string;
}

export interface Workflow {
  id: string;
  companyId: string;
  documentId: string;
  steps: WorkflowStep[];
  status: "idle" | "running" | "completed" | "failed";
  createdAt: string;
  updatedAt: string;
}

export interface WorkflowStep {
  id: string;
  type: string;
  config: Record<string, unknown>;
  status: "pending" | "running" | "completed" | "failed";
}

export interface AuditLog {
  id: string;
  companyId: string;
  userId: string;
  action: string;
  resourceType: string;
  resourceId: string;
  createdAt: string;
}

export interface ApiResponse<T = unknown> {
  data: T;
  error?: string;
}

export interface PaginatedResponse<T = unknown> {
  data: T[];
  total: number;
  page: number;
  pageSize: number;
}
