import { Controller, Get, Post, Delete, Param, Body, UseGuards, Request } from '@nestjs/common';
import { DevicesService } from './devices.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';

@Controller('devices')
@UseGuards(JwtAuthGuard)
export class DevicesController {
    constructor(private readonly devicesService: DevicesService) { }

    // GET /api/v1/devices - Get user's devices
    @Get()
    async getDevices(@CurrentUser() user: any) {
        return this.devicesService.getUserDevices(user.id);
    }

    // POST /api/v1/devices - Add a new device
    @Post()
    async addDevice(
        @CurrentUser() user: any,
        @Body() body: { name: string; type: string; identifier?: string },
    ) {
        return this.devicesService.addDevice(user.id, body);
    }

    // POST /api/v1/devices/:id/sync - Mark device as synced
    @Post(':id/sync')
    async syncDevice(@CurrentUser() user: any, @Param('id') deviceId: string) {
        return this.devicesService.syncDevice(user.id, deviceId);
    }

    // DELETE /api/v1/devices/:id - Remove device
    @Delete(':id')
    async removeDevice(@CurrentUser() user: any, @Param('id') deviceId: string) {
        return this.devicesService.removeDevice(user.id, deviceId);
    }
}
