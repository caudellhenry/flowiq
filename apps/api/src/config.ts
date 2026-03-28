import { Type } from "@sinclair/typebox";

export const envSchema = {
  type: "object",
  required: ["PORT", "DATABASE_URL"],
  properties: {
    NODE_ENV: {
      type: "string",
      default: "development",
    },
    PORT: {
      type: "integer",
      default: 3001,
    },
    HOST: {
      type: "string",
      default: "0.0.0.0",
    },
    DATABASE_URL: {
      type: "string",
    },
    REDIS_URL: {
      type: "string",
      default: "redis://localhost:6379",
    },
    CLERK_SECRET_KEY: {
      type: "string",
      default: "",
    },
    CORS_ORIGIN: {
      type: "string",
      default: "http://localhost:3000",
    },
  },
};

declare module "fastify" {
  interface FastifyInstance {
    config: {
      NODE_ENV: string;
      PORT: number;
      HOST: string;
      DATABASE_URL: string;
      REDIS_URL: string;
      CLERK_SECRET_KEY: string;
      CORS_ORIGIN: string;
    };
  }
}
