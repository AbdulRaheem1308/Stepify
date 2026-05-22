import {
  Controller,
  Get,
  Post,
  Delete,
  Param,
  Body,
  UseGuards,
} from "@nestjs/common";
import { DevicesService } from "./devices.service";
import { JwtAuthGuard } from "../auth/guards/jwt-auth.guard";
import { CurrentUser } from "../auth/decorators/current-user.decorator";
import { AddDeviceDto } from "./dto/device.dto";
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
} from "@nestjs/swagger";

@ApiTags("Devices")
@ApiBearerAuth()
@Controller("devices")
@UseGuards(JwtAuthGuard)
export class DevicesController {
  constructor(private readonly devicesService: DevicesService) {}

  @Get()
  @ApiOperation({ summary: "Get user's connected devices" })
  @ApiResponse({
    status: 200,
    description: "Returns list of connected devices",
  })
  async getDevices(@CurrentUser() user: any) {
    return this.devicesService.getUserDevices(user.id);
  }

  @Post()
  @ApiOperation({ summary: "Add a new device" })
  @ApiResponse({ status: 201, description: "Device added successfully" })
  async addDevice(@CurrentUser() user: any, @Body() body: AddDeviceDto) {
    return this.devicesService.addDevice(user.id, body);
  }

  @Post(":id/sync")
  @ApiOperation({ summary: "Mark device as synced" })
  @ApiResponse({ status: 201, description: "Device sync time updated" })
  async syncDevice(@CurrentUser() user: any, @Param("id") deviceId: string) {
    return this.devicesService.syncDevice(user.id, deviceId);
  }

  @Delete(":id")
  @ApiOperation({ summary: "Remove device" })
  @ApiResponse({ status: 200, description: "Device deactivated successfully" })
  async removeDevice(@CurrentUser() user: any, @Param("id") deviceId: string) {
    return this.devicesService.removeDevice(user.id, deviceId);
  }
}
