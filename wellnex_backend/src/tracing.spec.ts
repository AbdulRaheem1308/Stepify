import { NodeSDK } from "@opentelemetry/sdk-node";
import { otelSDK } from "./tracing";

jest.mock("@opentelemetry/sdk-node", () => {
  return {
    NodeSDK: jest.fn().mockImplementation(() => {
      return {
        shutdown: jest.fn().mockResolvedValue(undefined),
      };
    }),
  };
});

describe("Tracing", () => {
  let exitSpy: jest.SpyInstance;
  let consoleInfoSpy: jest.SpyInstance;
  let consoleErrorSpy: jest.SpyInstance;

  beforeEach(() => {
    exitSpy = jest.spyOn(process, "exit").mockImplementation((() => {}) as any);
    consoleInfoSpy = jest.spyOn(console, "info").mockImplementation();
    consoleErrorSpy = jest.spyOn(console, "error").mockImplementation();
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it("should initialize NodeSDK", () => {
    expect(NodeSDK).toHaveBeenCalled();
    expect(otelSDK).toBeDefined();
  });

  it("should handle graceful shutdown on SIGTERM successfully", async () => {
    const shutdownMock = jest.fn().mockResolvedValue(undefined);
    (otelSDK.shutdown as jest.Mock) = shutdownMock;

    // Simulate SIGTERM event
    const sigtermListeners = process.listeners("SIGTERM");
    const listener = sigtermListeners[sigtermListeners.length - 1]; // get the last added listener
    listener("SIGTERM");

    // Wait for the microtask queue to drain (the .then and .finally)
    await new Promise(process.nextTick);

    expect(shutdownMock).toHaveBeenCalled();
    expect(consoleInfoSpy).toHaveBeenCalledWith(
      "OpenTelemetry SDK shut down successfully",
    );
    expect(exitSpy).toHaveBeenCalledWith(0);
  });

  it("should handle graceful shutdown on SIGTERM with error", async () => {
    const error = new Error("Shutdown failed");
    const shutdownMock = jest.fn().mockRejectedValue(error);
    (otelSDK.shutdown as jest.Mock) = shutdownMock;

    // Simulate SIGTERM event
    const sigtermListeners = process.listeners("SIGTERM");
    const listener = sigtermListeners[sigtermListeners.length - 1]; // get the last added listener
    listener("SIGTERM");

    // Wait for the microtask queue to drain (the .then and .finally)
    await new Promise(process.nextTick);

    expect(shutdownMock).toHaveBeenCalled();
    expect(consoleErrorSpy).toHaveBeenCalledWith(
      "Error shutting down OpenTelemetry SDK",
      error,
    );
    expect(exitSpy).toHaveBeenCalledWith(0);
  });
});
