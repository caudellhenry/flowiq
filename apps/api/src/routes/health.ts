import type { FastifyInstance } from "fastify";

export async function healthRoutes(app: FastifyInstance): Promise<void> {
  app.get("/health", async (_request, reply) => {
    return reply.send({
      status: "ok",
      service: "flowiq-api",
      timestamp: new Date().toISOString(),
      version: process.env.npm_package_version ?? "0.0.1",
    });
  });
}
