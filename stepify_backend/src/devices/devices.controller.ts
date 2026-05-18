import { Controller, Get, Post, Delete, Param, Body, UseGuards, Request } from '@nestjs/common';
import { DevicesService } from './devices.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('devices')
@UseGuards(JwtAuthGuard)
export class DevicesController {
    constructor(private readonly devicesService: DevicesService) { }

    // GET /api/v1/devices - Get user's devices
    @Get()
    async getDevices(@Request() req: any) {
        return this.devicesService.getUserDevices(req.user.sub);
    }

    // POST /api/v1/devices - Add a new device
    @Post()
    async addDevice(
        @Request() req: any,
        @Body() body: { name: string; type: string; identifier?: string },
    ) {
        return this.devicesService.addDevice(req.user.sub, body);
    }

    // POST /api/v1/devices/:id/sync - Mark device as synced
    @Post(':id/sync')
    async syncDevice(@Request() req: any, @Param('id') deviceId: string) {
        return this.devicesService.syncDevice(req.user.sub, deviceId);
    }

    // DELETE /api/v1/devices/:id - Remove device
    @Delete(':id')
    async removeDevice(@Request() req: any, @Param('id') deviceId: string) {
        return this.devicesService.removeDevice(req.user.sub, deviceId);
    }
}
