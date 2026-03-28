import { describe, it, expect } from "vitest";
import Fastify from "fastify";
import { healthRoutes } from "./routes/health.js";

describe("Health endpoint", () => {
  it("returns 200 with status ok", async () => {
    const app = Fastify({ logger: false });
    await app.register(healthRoutes);

    const response = await app.inject({
      method: "GET",
      url: "/health",
    });

    expect(response.statusCode).toBe(200);
    const body = JSON.parse(response.body);
    expect(body.status).toBe("ok");
    expect(body.service).toBe("flowiq-api");
    expect(body.timestamp).toBeDefined();
  });
});
