import { Injectable } from "@nestjs/common";
import { PrismaService } from "../prisma/prisma.service";
import { AddDeviceDto } from "./dto/device.dto";

@Injectable()
export class DevicesService {
  constructor(private readonly prisma: PrismaService) {}

  // Get user's connected devices (Screen 15)
  async getUserDevices(userId: string) {
    return this.prisma.device.findMany({
      where: { userId, isActive: true },
      orderBy: { createdAt: "desc" },
    });
  }

  // Add a new device
  async addDevice(userId: string, data: AddDeviceDto) {
    return this.prisma.device.create({
      data: {
        userId,
        name: data.name,
        type: data.type,
        identifier: data.identifier,
      },
    });
  }

  // Sync device (update last synced time)
  async syncDevice(userId: string, deviceId: string) {
    const device = await this.prisma.device.findFirst({
      where: { id: deviceId, userId },
    });

    if (!device) {
      throw new Error("Device not found");
    }

    return this.prisma.device.update({
      where: { id: deviceId },
      data: { lastSyncedAt: new Date() },
    });
  }

  // Remove a device
  async removeDevice(userId: string, deviceId: string) {
    return this.prisma.device.updateMany({
      where: { id: deviceId, userId },
      data: { isActive: false },
    });
  }

  // Get device by identifier (for sync validation)
  async findByIdentifier(userId: string, identifier: string) {
    return this.prisma.device.findFirst({
      where: { userId, identifier, isActive: true },
    });
  }
}
