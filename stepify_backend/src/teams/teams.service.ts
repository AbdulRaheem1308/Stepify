import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class TeamsService {
    constructor(private prisma: PrismaService) { }

    // Get user's teams
    async getMyTeams(userId: string) {
        const memberships = await this.prisma.teamMember.findMany({
            where: { userId },
            include: {
                team: {
                    include: {
                        members: {
                            include: {
                                // Include user info if needed
                            },
                        },
                    },
                },
            },
        });

        return memberships.map((m) => this.formatTeam(m.team, m.role === 'captain'));
    }

    // Get public teams
    async getPublicTeams(userId: string) {
        // Get user's current team IDs
        const userTeamIds = await this.prisma.teamMember.findMany({
            where: { userId },
            select: { teamId: true },
        });
        const excludeIds = userTeamIds.map((t) => t.teamId);

        const teams = await this.prisma.team.findMany({
            where: {
                isPublic: true,
                id: { notIn: excludeIds },
            },
            include: {
                members: true,
            },
            orderBy: { weeklySteps: 'desc' },
            take: 50,
        });

        return teams.map((t) => this.formatTeam(t, false));
    }

    // Get team details
    async getTeamDetails(teamId: string, userId: string) {
        const team = await this.prisma.team.findUnique({
            where: { id: teamId },
            include: {
                members: {
                    orderBy: { weeklySteps: 'desc' },
                },
            },
        });

        if (!team) {
            throw new Error('Team not found');
        }

        // Get user names for members
        const userIds = team.members.map((m) => m.userId);
        const users = await this.prisma.user.findMany({
            where: { id: { in: userIds } },
            select: { id: true, name: true, avatarUrl: true },
        });
        const userMap = new Map(users.map((u) => [u.id, u]));

        const captain = userMap.get(team.captainId);

        return {
            id: team.id,
            name: team.name,
            description: team.description,
            imageUrl: team.imageUrl,
            captainId: team.captainId,
            captainName: captain?.name || 'Unknown',
            memberCount: team.members.length,
            maxMembers: team.maxMembers,
            totalSteps: team.totalSteps,
            weeklySteps: team.weeklySteps,
            isPublic: team.isPublic,
            inviteCode: team.inviteCode,
            createdAt: team.createdAt,
            members: team.members.map((m) => ({
                id: m.id,
                userId: m.userId,
                name: userMap.get(m.userId)?.name || 'Unknown',
                avatarUrl: userMap.get(m.userId)?.avatarUrl,
                steps: m.totalSteps,
                weeklySteps: m.weeklySteps,
                isCaptain: m.role === 'captain',
                joinedAt: m.joinedAt,
            })),
        };
    }

    // Create a new team
    async createTeam(
        userId: string,
        data: {
            name: string;
            description?: string;
            maxMembers?: number;
            isPublic?: boolean;
        },
    ) {
        // Create team
        const team = await this.prisma.team.create({
            data: {
                name: data.name,
                description: data.description || '',
                captainId: userId,
                maxMembers: data.maxMembers || 10,
                isPublic: data.isPublic !== false,
            },
        });

        // Add creator as captain
        await this.prisma.teamMember.create({
            data: {
                teamId: team.id,
                userId: userId,
                role: 'captain',
            },
        });

        return this.getTeamDetails(team.id, userId);
    }

    // Join a team
    async joinTeam(teamId: string, userId: string, inviteCode?: string) {
        const team = await this.prisma.team.findUnique({
            where: { id: teamId },
            include: { members: true },
        });

        if (!team) {
            throw new Error('Team not found');
        }

        if (team.members.length >= team.maxMembers) {
            throw new Error('Team is full');
        }

        // Check if already a member
        const existing = team.members.find((m) => m.userId === userId);
        if (existing) {
            throw new Error('Already a member');
        }

        // Private team requires invite code
        if (!team.isPublic && team.inviteCode !== inviteCode) {
            throw new Error('Invalid invite code');
        }

        await this.prisma.teamMember.create({
            data: {
                teamId: team.id,
                userId: userId,
                role: 'member',
            },
        });

        return { success: true };
    }

    // Leave a team
    async leaveTeam(teamId: string, userId: string) {
        const team = await this.prisma.team.findUnique({
            where: { id: teamId },
        });

        if (!team) {
            throw new Error('Team not found');
        }

        // Captain cannot leave (must transfer or delete)
        if (team.captainId === userId) {
            throw new Error('Captain cannot leave. Transfer ownership or delete team.');
        }

        await this.prisma.teamMember.deleteMany({
            where: { teamId, userId },
        });

        return { success: true };
    }

    // Get team challenges
    async getTeamChallenges(teamId: string) {
        const challenges = await this.prisma.teamChallenge.findMany({
            where: { teamId },
            orderBy: { startDate: 'desc' },
        });

        return challenges;
    }

    // Get team leaderboard
    async getTeamLeaderboard() {
        const teams = await this.prisma.team.findMany({
            where: { isPublic: true },
            include: { members: true },
            orderBy: { weeklySteps: 'desc' },
            take: 100,
        });

        return teams.map((t, index) => ({
            id: t.id,
            name: t.name,
            description: t.description,
            memberCount: t.members.length,
            maxMembers: t.maxMembers,
            totalSteps: t.totalSteps,
            weeklySteps: t.weeklySteps,
            rank: index + 1,
        }));
    }

    // Helper to format team
    private formatTeam(team: any, isCaptain: boolean) {
        return {
            id: team.id,
            name: team.name,
            description: team.description,
            imageUrl: team.imageUrl,
            captainId: team.captainId,
            memberCount: team.members?.length || 0,
            maxMembers: team.maxMembers,
            totalSteps: team.totalSteps,
            weeklySteps: team.weeklySteps,
            isPublic: team.isPublic,
            inviteCode: isCaptain ? team.inviteCode : null,
            createdAt: team.createdAt,
        };
    }
}
