import {
    WebSocketGateway,
    WebSocketServer,
    SubscribeMessage,
    OnGatewayConnection,
    OnGatewayDisconnect,
    ConnectedSocket,
    MessageBody
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { Logger } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@WebSocketGateway({
    cors: { origin: '*' },
    namespace: '/leaderboard',
})
export class LeaderboardGateway implements OnGatewayConnection, OnGatewayDisconnect {
    @WebSocketServer()
    server: Server;

    private readonly logger = new Logger(LeaderboardGateway.name);

    constructor(private prisma: PrismaService) {}

    handleConnection(client: Socket) {
        this.logger.log(`Client connected to leaderboard: ${client.id}`);
    }

    handleDisconnect(client: Socket) {
        this.logger.log(`Client disconnected from leaderboard: ${client.id}`);
    }

    @SubscribeMessage('join_leaderboard')
    async handleJoinLeaderboard(@ConnectedSocket() client: Socket, @MessageBody() data: { userId: string }) {
        client.join('global_leaderboard');
        this.logger.log(`User ${data.userId} joined the global leaderboard channel`);
        
        // Immediately emit current top 10
        const currentLeaders = await this.getTopUsers();
        client.emit('leaderboard_update', currentLeaders);
    }

    /**
     * Call this method from StepsService or ActivitiesService whenever a user logs steps or activities
     */
    async broadcastLeaderboardUpdate() {
        const leaders = await this.getTopUsers();
        this.server.to('global_leaderboard').emit('leaderboard_update', leaders);
    }

    private async getTopUsers() {
        const today = new Date();
        today.setHours(0, 0, 0, 0);

        // Fetch users ordered by today's steps
        const steps = await this.prisma.step.findMany({
            where: { date: today },
            orderBy: { stepCount: 'desc' },
            take: 20,
            include: {
                user: {
                    select: { id: true, name: true, avatarUrl: true, fitnessLevel: true }
                }
            }
        });

        return steps.map((s, index) => ({
            rank: index + 1,
            userId: s.user.id,
            name: s.user.name,
            avatarUrl: s.user.avatarUrl,
            fitnessLevel: s.user.fitnessLevel,
            stepCount: s.stepCount,
            calories: s.caloriesBurned,
        }));
    }
}
