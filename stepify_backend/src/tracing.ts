import { NodeSDK } from "@opentelemetry/sdk-node";
import { getNodeAutoInstrumentations } from "@opentelemetry/auto-instrumentations-node";

// For production, you would configure an exporter like Jaeger, Zipkin, or OTLP.
// We keep it empty/console-based locally, or just omit the exporter to let the SDK initialize.

export const otelSDK = new NodeSDK({
  traceExporter: process.env.NODE_ENV === "production" ? undefined : undefined, // Replace with new OTLPTraceExporter()
  instrumentations: [
    getNodeAutoInstrumentations({
      // Configure specific instrumentations here if needed
      "@opentelemetry/instrumentation-fs": {
        enabled: false, // Too noisy
      },
      "@opentelemetry/instrumentation-net": {
        enabled: false,
      },
    }),
  ],
  serviceName: "stepify-backend",
});

// Optionally handle graceful shutdown
process.on("SIGTERM", () => {
  otelSDK
    .shutdown()
    .then(
      // eslint-disable-next-line no-console
      () => console.info("OpenTelemetry SDK shut down successfully"),
      // eslint-disable-next-line no-console
      (err) => console.error("Error shutting down OpenTelemetry SDK", err),
    )
    .finally(() => process.exit(0));
});
