import { Test, TestingModule } from "@nestjs/testing";
import { StepsController } from "./steps.controller";
import { StepsService } from "./steps.service";
import { SyncStepsDto } from "./dto/steps.dto";

describe("StepsController", () => {
  let controller: StepsController;
  let service: StepsService;

  const mockStepsService = {
    syncSteps: jest.fn(),
    getTodaySteps: jest.fn(),
    getHistory: jest.fn(),
    getWeeklySummary: jest.fn(),
    getMonthlySummary: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [StepsController],
      providers: [{ provide: StepsService, useValue: mockStepsService }],
    }).compile();

    controller = module.get<StepsController>(StepsController);
    service = module.get<StepsService>(StepsService);
    jest.clearAllMocks();
  });

  it("should be defined", () => {
    expect(controller).toBeDefined();
  });

  it("should sync steps", async () => {
    const dto: SyncStepsDto = {
      deviceIdentifier: "dev1",
      stepCount: 100,
      date: new Date().toISOString(),
      source: "manual",
    };
    mockStepsService.syncSteps.mockResolvedValue({ id: "step1" });
    const res = await controller.syncSteps({ id: "u1" }, dto);
    expect(res).toEqual({ id: "step1" });
    expect(service.syncSteps).toHaveBeenCalledWith("u1", dto);
  });

  it("should get today steps", async () => {
    mockStepsService.getTodaySteps.mockResolvedValue({ stepCount: 100 });
    const res = await controller.getTodaySteps({ id: "u1" });
    expect(res).toEqual({ stepCount: 100 });
    expect(service.getTodaySteps).toHaveBeenCalledWith("u1");
  });

  it("should get history with default pagination", async () => {
    mockStepsService.getHistory.mockResolvedValue({ data: [] });
    await controller.getHistory({ id: "u1" });
    expect(service.getHistory).toHaveBeenCalledWith("u1", 1, 30);
  });

  it("should get history with provided pagination", async () => {
    mockStepsService.getHistory.mockResolvedValue({ data: [] });
    await controller.getHistory({ id: "u1" }, "2", "10");
    expect(service.getHistory).toHaveBeenCalledWith("u1", 2, 10);
  });

  it("should get history with invalid pagination gracefully", async () => {
    mockStepsService.getHistory.mockResolvedValue({ data: [] });
    await controller.getHistory({ id: "u1" }, "abc", "xyz");
    expect(service.getHistory).toHaveBeenCalledWith("u1", 1, 30);
  });

  it("should get weekly summary", async () => {
    mockStepsService.getWeeklySummary.mockResolvedValue({ totalSteps: 1000 });
    const res = await controller.getWeeklySummary({ id: "u1" });
    expect(res).toEqual({ totalSteps: 1000 });
  });

  it("should get monthly summary without dates", async () => {
    mockStepsService.getMonthlySummary.mockResolvedValue({ totalSteps: 5000 });
    await controller.getMonthlySummary({ id: "u1" });
    expect(service.getMonthlySummary).toHaveBeenCalledWith(
      "u1",
      undefined,
      undefined,
    );
  });

  it("should get monthly summary with dates", async () => {
    mockStepsService.getMonthlySummary.mockResolvedValue({ totalSteps: 5000 });
    await controller.getMonthlySummary({ id: "u1" }, 2023, 5);
    expect(service.getMonthlySummary).toHaveBeenCalledWith("u1", 2023, 5);
  });
});
