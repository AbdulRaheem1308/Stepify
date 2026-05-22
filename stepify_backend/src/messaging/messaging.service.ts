import { Injectable, OnModuleInit } from "@nestjs/common";
import { PrismaService } from "../prisma/prisma.service";

@Injectable()
export class MessagingService implements OnModuleInit {
  constructor(private readonly prisma: PrismaService) {}

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
    // Defense in Depth: Verify participant
    const isParticipant = await this.isParticipant(conversationId, senderId);
    if (!isParticipant) {
      throw new Error("Sender is not a participant of this conversation");
    }

    // Atomic insert and conversation update
    return this.prisma.$transaction(async (tx) => {
      const message = await tx.message.create({
        data: {
          conversationId,
          senderId,
          content,
        },
      });

      // Update conversation timestamp
      await tx.conversation.update({
        where: { id: conversationId },
        data: { updatedAt: new Date() },
      });

      return message;
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
