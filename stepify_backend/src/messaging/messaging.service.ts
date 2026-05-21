import { Injectable, OnModuleInit } from "@nestjs/common";
import { PrismaService } from "../prisma/prisma.service";

@Injectable()
export class MessagingService implements OnModuleInit {
  constructor(private prisma: PrismaService) {}

  async onModuleInit() {
    // Seed mock messages if empty
    const count = await this.prisma.conversation.count();
    if (count === 0) {
      // Create a system conversation or example
      // Ideally we need users first. Skipping strict seeding for messaging as it depends on user IDs.
      // But we can create a 'Welcome Bot' user if needed.
    }
  }

  async getConversations(userId: string) {
    return this.prisma.conversation.findMany({
      where: {
        participants: {
          some: { userId },
        },
      },
      include: {
        participants: {
          include: { user: true },
        },
        messages: {
          orderBy: { createdAt: "desc" },
          take: 1,
        },
      },
    });
  }

  async getMessages(conversationId: string) {
    return this.prisma.message.findMany({
      where: { conversationId },
      orderBy: { createdAt: "asc" },
      include: { sender: true },
    });
  }

  async startConversation(userId: string, otherUserId: string) {
    // Check existing
    const existing = await this.prisma.conversation.findFirst({
      where: {
        participants: {
          every: {
            userId: { in: [userId, otherUserId] },
          },
        },
      },
    });

    if (existing) return existing;

    return this.prisma.conversation.create({
      data: {
        participants: {
          create: [{ userId }, { userId: otherUserId }],
        },
      },
    });
  }

  async sendMessage(conversationId: string, senderId: string, content: string) {
    return this.prisma.message.create({
      data: {
        conversationId,
        senderId,
        content,
      },
    });
  }

  /**
   * Checks if a user is a participant in a conversation.
   */
  async isParticipant(
    conversationId: string,
    userId: string,
  ): Promise<boolean> {
    const participant = await this.prisma.conversationParticipant.findUnique({
      where: {
        conversationId_userId: {
          conversationId,
          userId,
        },
      },
    });
    return !!participant;
  }
}
