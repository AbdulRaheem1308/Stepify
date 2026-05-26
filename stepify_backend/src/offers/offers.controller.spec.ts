import { Test, TestingModule } from "@nestjs/testing";
import { OffersController } from "./offers.controller";
import { OffersService } from "./offers.service";

describe("OffersController", () => {
  let controller: OffersController;
  let service: OffersService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [OffersController],
      providers: [
        {
          provide: OffersService,
          useValue: {
            findAllActive: jest.fn(),
            getUserOffers: jest.fn(),
            startOffer: jest.fn(),
            completeOffer: jest.fn(),
            createOffer: jest.fn(),
          },
        },
      ],
    }).compile();

    controller = module.get<OffersController>(OffersController);
    service = module.get<OffersService>(OffersService);
  });

  it("should be defined", () => {
    expect(controller).toBeDefined();
  });

  describe("findAll", () => {
    it("should find all active offers", async () => {
      await controller.findAll();
      expect(service.findAllActive).toHaveBeenCalled();
    });
  });

  describe("getMyOffers", () => {
    it("should get user offers without status", async () => {
      const user = { id: "u1" };
      await controller.getMyOffers(user);
      expect(service.getUserOffers).toHaveBeenCalledWith("u1", undefined);
    });

    it("should get user offers with status", async () => {
      const user = { id: "u1" };
      await controller.getMyOffers(user, "ACTIVE");
      expect(service.getUserOffers).toHaveBeenCalledWith("u1", "ACTIVE");
    });
  });

  describe("startOffer", () => {
    it("should start an offer", async () => {
      const user = { id: "u1" };
      await controller.startOffer(user, "o1");
      expect(service.startOffer).toHaveBeenCalledWith("u1", "o1");
    });
  });

  describe("completeOffer", () => {
    it("should complete an offer", async () => {
      const user = { id: "u1" };
      await controller.completeOffer(user, "o1");
      expect(service.completeOffer).toHaveBeenCalledWith("u1", "o1");
    });
  });

  describe("createOffer", () => {
    it("should create an offer", async () => {
      const dto = { title: "Offer 1", rewardCoins: 10 } as any;
      await controller.createOffer(dto);
      expect(service.createOffer).toHaveBeenCalledWith(dto);
    });
  });
});
