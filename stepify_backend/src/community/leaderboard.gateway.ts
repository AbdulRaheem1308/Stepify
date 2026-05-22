import {
  WebSocketGateway,
  WebSocketServer,
  SubscribeMessage,
  OnGatewayConnection,
  OnGatewayDisconnect,
  ConnectedSocket,
} from "@nestjs/websockets";
import { Server, Socket } from "socket.io";
import { Logger } from "@nestjs/common";
import { PrismaService } from "../prisma/prisma.service";
import { JwtService } from "@nestjs/jwt";
import { ConfigService } from "@nestjs/config";

// Extend socket to store user object
interface AuthenticatedSocket extends Socket {
  user?: any;
}

@WebSocketGateway({
  cors: { origin: "*" },
  namespace: "/leaderboard",
})
export class LeaderboardGateway
  implements OnGatewayConnection, OnGatewayDisconnect
{
  @WebSocketServer()
  server: Server;

  private readonly logger = new Logger(LeaderboardGateway.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
  ) {}

  async handleConnection(client: AuthenticatedSocket) {
    try {
      // Extract JWT from authorization header or handshake auth payload
      const authHeader = client.handshake.headers.authorization;
      const token = authHeader
        ? authHeader.split(" ")[1]
        : client.handshake.auth?.token;

      if (!token) {
        throw new Error("No token provided");
      }

      // Verify the JWT
      const payload = this.jwtService.verify(token, {
        secret: this.configService.get("JWT_SECRET"),
      });

      // Attach user payload to the socket context
      client.user = payload;
      this.logger.log(
        `Client authenticated and connected to leaderboard: ${client.id} (User: ${payload.sub})`,
      );
    } catch (err) {
      this.logger.warn(
        `Unauthorized WebSocket connection attempt: ${client.id}. Disconnecting.`,
      );
      client.disconnect();
    }
  }

  handleDisconnect(client: AuthenticatedSocket) {
    this.logger.log(`Client disconnected from leaderboard: ${client.id}`);
  }

  @SubscribeMessage("join_leaderboard")
  async handleJoinLeaderboard(@ConnectedSocket() client: AuthenticatedSocket) {
    // Rely exclusively on the authenticated user ID from the JWT payload
    const userId = client.user?.sub;

    if (!userId) {
      this.logger.warn(
        "Unauthenticated user attempted to join leaderboard. Rejecting.",
      );
      return;
    }

    client.join("global_leaderboard");
    this.logger.log(`User ${userId} joined the global leaderboard channel`);

    // Immediately emit current top 10
    const currentLeaders = await this.getTopUsers();
    client.emit("leaderboard_update", currentLeaders);
  }

  /**
   * Call this method from StepsService or ActivitiesService whenever a user logs steps or activities
   */
  async broadcastLeaderboardUpdate() {
    const leaders = await this.getTopUsers();
    this.server.to("global_leaderboard").emit("leaderboard_update", leaders);
  }

  private async getTopUsers() {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    // Fetch users ordered by today's steps
    const steps = await this.prisma.step.findMany({
      where: { date: today },
      orderBy: { stepCount: "desc" },
      take: 20,
      include: {
        user: {
          select: { id: true, name: true, avatarUrl: true, fitnessLevel: true },
        },
      },
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
