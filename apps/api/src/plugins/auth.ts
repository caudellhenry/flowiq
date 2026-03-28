import fp from "fastify-plugin";
import type { FastifyPluginAsync, FastifyRequest, FastifyReply } from "fastify";
import { createClerkClient, verifyToken } from "@clerk/backend";
import { prisma } from "@flowiq/db";
import type { User, Company, UserRole } from "@flowiq/db";

declare module "fastify" {
  interface FastifyRequest {
    auth: {
      userId: string;
      orgId: string | null;
      orgRole: string | null;
      sessionId: string;
    } | null;
    currentUser: User | null;
    currentCompany: Company | null;
  }
}

const authPlugin: FastifyPluginAsync = async (app) => {
  // createClerkClient retained for future API operations (users, orgs, etc.)
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  const _clerk = createClerkClient({ secretKey: app.config.CLERK_SECRET_KEY });

  app.decorateRequest("auth", null);
  app.decorateRequest("currentUser", null);
  app.decorateRequest("currentCompany", null);

  // Parse Clerk JWT on every request — does not reject missing tokens
  app.addHook("onRequest", async (request: FastifyRequest) => {
    const token = request.headers.authorization?.replace("Bearer ", "");
    if (!token) return;

    try {
      const payload = await verifyToken(token, {
        secretKey: app.config.CLERK_SECRET_KEY,
      });
      request.auth = {
        userId: payload.sub,
        orgId: (payload.org_id as string | undefined) ?? null,
        orgRole: (payload.org_role as string | undefined) ?? null,
        sessionId: payload.sid,
      };
    } catch {
      // Invalid / expired token — auth remains null
    }
  });
};

export default fp(authPlugin, { name: "clerk-auth" });

/**
 * Fastify preHandler: rejects unauthenticated requests and attaches
 * currentUser + currentCompany to the request for downstream use.
 */
export async function requireAuth(
  request: FastifyRequest,
  reply: FastifyReply
): Promise<void> {
  if (!request.auth) {
    return reply.code(401).send({ error: "Unauthorized" });
  }

  const user = await prisma.user.findUnique({
    where: { clerkId: request.auth.userId },
    include: { company: true },
  });

  if (!user) {
    return reply.code(401).send({ error: "User not provisioned" });
  }

  request.currentUser = user;
  request.currentCompany = (user as User & { company: Company }).company;
}

/**
 * Returns a Fastify preHandler that enforces one of the given roles.
 * Must be chained after requireAuth (or call requireAuth internally).
 */
export function requireRole(...roles: UserRole[]) {
  return async function (
    request: FastifyRequest,
    reply: FastifyReply
  ): Promise<void> {
    await requireAuth(request, reply);
    if (reply.sent) return; // requireAuth already replied

    if (!request.currentUser || !roles.includes(request.currentUser.role)) {
      return reply.code(403).send({ error: "Forbidden" });
    }
  };
}
