import { WebSocketGateway, WebSocketServer, SubscribeMessage, OnGatewayConnection, OnGatewayDisconnect } from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { Logger } from '@nestjs/common';

@WebSocketGateway({
    cors: {
        origin: '*', // Allow all origins for the Flutter client and Web dashboard
    },
    namespace: 'leaderboard',
})
export class LeaderboardGateway implements OnGatewayConnection, OnGatewayDisconnect {
    @WebSocketServer()
    server: Server;

    private readonly logger = new Logger(LeaderboardGateway.name);

    handleConnection(client: Socket) {
        this.logger.log(`🔌 Client connected to Leaderboard WS: ${client.id}`);
    }

    handleDisconnect(client: Socket) {
        this.logger.log(`🔌 Client disconnected from Leaderboard WS: ${client.id}`);
    }

    /**
     * Broadcasts leaderboard updates for a specific company
     */
    broadcastLeaderboardUpdate(companyId: string, leaderboardData: any) {
        this.logger.log(`📢 Broadcasting leaderboard update for company ${companyId}`);
        this.server.emit(`update:${companyId}`, leaderboardData);
    }

    /**
     * Broadcasts global leaderboard updates
     */
    broadcastGlobalLeaderboardUpdate(leaderboardData: any) {
        this.logger.log(`📢 Broadcasting global leaderboard update`);
        this.server.emit('global_update', leaderboardData);
    }

    @SubscribeMessage('ping')
    handlePing(client: Socket): string {
        return 'pong';
    }
}
