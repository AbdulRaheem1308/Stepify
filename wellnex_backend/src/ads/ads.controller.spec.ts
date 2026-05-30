import { Test, TestingModule } from "@nestjs/testing";
import { AdsController } from "./ads.controller";
import { AdsService } from "./ads.service";
import { GetAdHistoryDto } from "./dto/get-ad-history.dto";

describe("AdsController", () => {
  let controller: AdsController;
  let service: AdsService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [AdsController],
      providers: [
        {
          provide: AdsService,
          useValue: {
            checkCanWatchAd: jest.fn(),
            claimAdReward: jest.fn(),
            getAdHistory: jest.fn(),
          },
        },
      ],
    }).compile();

    controller = module.get<AdsController>(AdsController);
    service = module.get<AdsService>(AdsService);
  });

  it("should be defined", () => {
    expect(controller).toBeDefined();
  });

  describe("canWatchAd", () => {
    it("should check if user can watch ad", async () => {
      const user = { id: "u1" };
      await controller.canWatchAd(user);
      expect(service.checkCanWatchAd).toHaveBeenCalledWith("u1");
    });
  });

  describe("claimReward", () => {
    it("should claim ad reward", async () => {
      const user = { id: "u1" };
      const dto = { adType: "VIDEO", adUnitId: "unit1" };
      await controller.claimReward(user, dto as any);
      expect(service.claimAdReward).toHaveBeenCalledWith(
        "u1",
        "VIDEO",
        "unit1",
      );
    });
  });

  describe("getHistory", () => {
    it("should get ad history", async () => {
      const user = { id: "u1" };
      const query = new GetAdHistoryDto();
      query.page = 1;
      query.limit = 10;
      await controller.getHistory(user, query);
      expect(service.getAdHistory).toHaveBeenCalledWith("u1", 1, 10);
    });
  });
});
