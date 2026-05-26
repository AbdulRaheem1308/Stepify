import express from "express";
import cors from "cors";
import dotenv from "dotenv";
import apiRouter from "./routes";
import { adminAuthGuard } from "./middleware/auth";
import { errorHandler } from "./middleware/error";

// Load environment variables
dotenv.config();

const app = express();
const port = process.env.ADMIN_PORT || 4000;

// CORS setup
app.use(cors({
  origin: "*",
  methods: ["GET", "POST", "PUT", "DELETE"],
  allowedHeaders: ["Content-Type", "x-admin-api-key"]
}));

app.use(express.json());

// Apply Admin Authentication Guard Globally
app.use(adminAuthGuard);

// Register Router Layer
app.use("/api/admin", apiRouter);

// Global Error Handler Middleware
app.use(errorHandler);

// Bootstrap
app.listen(port, () => {
  console.log(`🚀 Standalone Modular Admin API running on http://localhost:${port}`);
});
