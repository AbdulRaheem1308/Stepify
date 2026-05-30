import { Test, TestingModule } from "@nestjs/testing";
import { DevicesController } from "./devices.controller";
import { DevicesService } from "./devices.service";

describe("DevicesController", () => {
  let controller: DevicesController;
  let service: DevicesService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [DevicesController],
      providers: [
        {
          provide: DevicesService,
          useValue: {
            getUserDevices: jest.fn(),
            addDevice: jest.fn(),
            syncDevice: jest.fn(),
            removeDevice: jest.fn(),
          },
        },
      ],
    }).compile();

    controller = module.get<DevicesController>(DevicesController);
    service = module.get<DevicesService>(DevicesService);
  });

  it("should be defined", () => {
    expect(controller).toBeDefined();
  });

  describe("getDevices", () => {
    it("should get user devices", async () => {
      const user = { id: "u1" };
      await controller.getDevices(user);
      expect(service.getUserDevices).toHaveBeenCalledWith("u1");
    });
  });

  describe("addDevice", () => {
    it("should add device", async () => {
      const user = { id: "u1" };
      const body = {
        type: "APPLE_WATCH",
        model: "Series 7",
        deviceIdentifier: "id123",
      };
      await controller.addDevice(user, body as any);
      expect(service.addDevice).toHaveBeenCalledWith("u1", body);
    });
  });

  describe("syncDevice", () => {
    it("should sync device", async () => {
      const user = { id: "u1" };
      await controller.syncDevice(user, "d1");
      expect(service.syncDevice).toHaveBeenCalledWith("u1", "d1");
    });
  });

  describe("removeDevice", () => {
    it("should remove device", async () => {
      const user = { id: "u1" };
      await controller.removeDevice(user, "d1");
      expect(service.removeDevice).toHaveBeenCalledWith("u1", "d1");
    });
  });
});
