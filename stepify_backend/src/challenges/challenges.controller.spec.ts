import { Test, TestingModule } from "@nestjs/testing";
import { ChallengesController } from "./challenges.controller";
import { ChallengesService } from "./challenges.service";
import { ChallengeStatus } from "./dto/challenge.dto";

describe("ChallengesController", () => {
  let controller: ChallengesController;
  let service: ChallengesService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [ChallengesController],
      providers: [
        {
          provide: ChallengesService,
          useValue: {
            findAll: jest.fn(),
            findNewChallenges: jest.fn(),
            findUserChallenges: jest.fn(),
            findOne: jest.fn(),
            join: jest.fn(),
            updateProgress: jest.fn(),
            seedDemoChallenges: jest.fn(),
            revive: jest.fn(),
            restart: jest.fn(),
          },
        },
      ],
    }).compile();

    controller = module.get<ChallengesController>(ChallengesController);
    service = module.get<ChallengesService>(ChallengesService);
  });

  it("should be defined", () => {
    expect(controller).toBeDefined();
  });

  describe("findAll", () => {
    it("should return all challenges", async () => {
      await controller.findAll();
      expect(service.findAll).toHaveBeenCalled();
    });
  });

  describe("findNew", () => {
    it("should return new challenges", async () => {
      const user = { id: "u1" };
      await controller.findNew(user);
      expect(service.findNewChallenges).toHaveBeenCalledWith("u1");
    });
  });

  describe("findMy", () => {
    it("should return user challenges", async () => {
      const user = { id: "u1" };
      await controller.findMy(user, ChallengeStatus.ONGOING);
      expect(service.findUserChallenges).toHaveBeenCalledWith(
        "u1",
        ChallengeStatus.ONGOING,
      );
    });
  });

  describe("findOngoing", () => {
    it("should return ongoing challenges", async () => {
      const user = { id: "u1" };
      await controller.findOngoing(user);
      expect(service.findUserChallenges).toHaveBeenCalledWith(
        "u1",
        ChallengeStatus.ONGOING,
      );
    });
  });

  describe("findCompleted", () => {
    it("should return completed challenges", async () => {
      const user = { id: "u1" };
      await controller.findCompleted(user);
      expect(service.findUserChallenges).toHaveBeenCalledWith(
        "u1",
        ChallengeStatus.COMPLETED,
      );
    });
  });

  describe("findOne", () => {
    it("should return single challenge", async () => {
      await controller.findOne("c1");
      expect(service.findOne).toHaveBeenCalledWith("c1");
    });
  });

  describe("join", () => {
    it("should join challenge", async () => {
      const user = { id: "u1" };
      await controller.join(user, { challengeId: "c1" });
      expect(service.join).toHaveBeenCalledWith("u1", "c1");
    });
  });

  describe("updateProgress", () => {
    it("should update progress", async () => {
      const user = { id: "u1" };
      await controller.updateProgress(user, {
        challengeId: "c1",
        stepsToAdd: 500,
      });
      expect(service.updateProgress).toHaveBeenCalledWith("u1", "c1", 500);
    });
  });

  describe("seed", () => {
    it("should seed demo challenges", async () => {
      await controller.seed();
      expect(service.seedDemoChallenges).toHaveBeenCalled();
    });
  });

  describe("revive", () => {
    it("should revive a challenge with default COINS method", async () => {
      const user = { id: "u1" };
      await controller.revive(user, "c1", undefined as any);
      expect(service.revive).toHaveBeenCalledWith("u1", "c1", "COINS");
    });

    it("should revive a challenge with AD method", async () => {
      const user = { id: "u1" };
      await controller.revive(user, "c1", "AD");
      expect(service.revive).toHaveBeenCalledWith("u1", "c1", "AD");
    });
  });

  describe("restart", () => {
    it("should restart a challenge", async () => {
      const user = { id: "u1" };
      await controller.restart(user, "c1");
      expect(service.restart).toHaveBeenCalledWith("u1", "c1");
    });
  });
});
