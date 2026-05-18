import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';


@Injectable()
export class CommunityService {
    constructor(private prisma: PrismaService) { }

    // Get community feed (Screen 19)
    async getFeed(limit = 20, cursor?: string) {
        const posts = await this.prisma.feedPost.findMany({
            take: limit,
            ...(cursor && {
                skip: 1,
                cursor: { id: cursor },
            }),
            include: {
                user: {
                    select: { id: true, name: true, avatarUrl: true },
                },
                _count: {
                    select: { reactions: true, comments: true },
                },
            },
            orderBy: { createdAt: 'desc' },
        });

        return posts.map((post) => ({
            ...post,
            likesCount: post._count.reactions,
            commentsCount: post._count.comments,
        }));
    }

    // Create a feed post (auto-generated on milestones or manual)
    async createPost(userId: string, content: string, type: any, metadata?: any) {
        return this.prisma.feedPost.create({
            data: {
                userId,
                content,
                type,
                metadata,
            },
            include: {
                user: { select: { id: true, name: true, avatarUrl: true } },
            },
        });
    }

    // React to a post (like, clap, fire)
    async reactToPost(userId: string, postId: string, reactionType = 'like') {
        // Toggle reaction
        const existing = await this.prisma.feedReaction.findUnique({
            where: { postId_userId: { postId, userId } },
        });

        if (existing) {
            // Remove reaction
            await this.prisma.feedReaction.delete({ where: { id: existing.id } });
            await this.prisma.feedPost.update({
                where: { id: postId },
                data: { likesCount: { decrement: 1 } },
            });
            return { reacted: false };
        } else {
            // Add reaction
            await this.prisma.feedReaction.create({
                data: { postId, userId, type: reactionType },
            });
            await this.prisma.feedPost.update({
                where: { id: postId },
                data: { likesCount: { increment: 1 } },
            });
            return { reacted: true };
        }
    }

    // Add a comment
    async addComment(userId: string, postId: string, content: string) {
        const comment = await this.prisma.feedComment.create({
            data: { postId, userId, content },
            include: {
                user: { select: { id: true, name: true, avatarUrl: true } },
            },
        });

        await this.prisma.feedPost.update({
            where: { id: postId },
            data: { commentsCount: { increment: 1 } },
        });

        return comment;
    }

    // Get comments for a post
    async getComments(postId: string) {
        return this.prisma.feedComment.findMany({
            where: { postId },
            include: {
                user: { select: { id: true, name: true, avatarUrl: true } },
            },
            orderBy: { createdAt: 'asc' },
        });
    }

    // Auto-post milestone (called from other services)
    async postMilestone(userId: string, type: any, content: string, metadata?: any) {
        return this.createPost(userId, content, type, metadata);
    }
}
