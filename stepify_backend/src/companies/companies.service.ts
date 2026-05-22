import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from "@nestjs/common";
import { PrismaService } from "../prisma/prisma.service";
import { CreateCompanyDto } from "./dto/company.dto";
import * as crypto from "node:crypto";

@Injectable()
export class CompaniesService {
  constructor(private readonly prisma: PrismaService) {}

  async createCompany(data: CreateCompanyDto) {
    return this.prisma.company.create({
      data: {
        name: data.name,
        domain: data.domain,
        inviteCode:
          data.inviteCode ||
          crypto.randomBytes(4).toString("hex").toUpperCase(),
        logoUrl: data.logoUrl,
      },
    });
  }

  async findAll() {
    return this.prisma.company.findMany();
  }

  async joinCompany(joinCode: string, userId: string) {
    const company = await this.prisma.company.findUnique({
      where: { inviteCode: joinCode },
    });

    if (!company) {
      throw new NotFoundException("Invalid company code");
    }

    // Check if already a member
    const existing = await this.prisma.companyMember.findUnique({
      where: { userId },
    });

    if (existing) {
      if (existing.companyId === company.id) return existing;
      throw new BadRequestException("User already belongs to a company");
    }

    return this.prisma.companyMember.create({
      data: {
        companyId: company.id,
        userId: userId,
        role: "EMPLOYEE",
      },
      include: {
        company: true,
      },
    });
  }

  async getCompanyLeaderboard(companyId: string) {
    // Aggregating steps from CompanyMember
    // In a real scenario, we might sync these values periodically
    // For now, we'll fetch members and their steps

    // We can also just query CompanyMember stats if we maintained them
    // But since `totalSteps` on CompanyMember is a cache, we assume it's updated.

    // Let's implement a live-ish fetch for demo
    // Fetch all members, and for each, sum their logs (expensive but accurate for small scale)
    // Or stick to the cached `totalSteps` field which must be updated.

    return this.prisma.companyMember.findMany({
      where: { companyId },
      orderBy: { totalSteps: "desc" },
      take: 20,
      include: {
        user: {
          select: {
            name: true,
            avatarUrl: true,
          },
        },
      },
    });
  }

  async getUserCompany(userId: string) {
    return this.prisma.companyMember.findUnique({
      where: { userId },
      include: {
        company: true,
        department: true,
      },
    });
  }
}
