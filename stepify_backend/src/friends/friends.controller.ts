import {
  Controller,
  Get,
  Post,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
} from "@nestjs/common";
import { Request } from "express";
import { JwtAuthGuard } from "../auth/guards/jwt-auth.guard";
import { CurrentUser } from "../auth/decorators/current-user.decorator";
import { FriendsService } from "./friends.service";

@Controller("friends")
@UseGuards(JwtAuthGuard)
export class FriendsController {
  constructor(private readonly friendsService: FriendsService) {}

  /**
   * GET /friends - Get user's friends list
   */
  @Get()
  async getFriends(@CurrentUser() user: any) {
    return this.friendsService.getFriends(user.id);
  }

  /**
   * GET /friends/pending - Get pending friend requests
   */
  @Get("pending")
  async getPendingRequests(@CurrentUser() user: any) {
    return this.friendsService.getPendingRequests(user.id);
  }

  /**
   * GET /friends/search - Search users
   */
  @Get("search")
  async searchUsers(@CurrentUser() user: any, @Query("q") query: string) {
    return this.friendsService.searchUsers(user.id, query);
  }

  /**
   * GET /friends/leaderboard - Get mini leaderboard
   */
  @Get("leaderboard")
  async getLeaderboard(
    @CurrentUser() user: any,
    @Query("type") type?: string,
    @Query("timeFrame") timeFrame?: string,
  ) {
    if (type === "global") {
      const globalList =
        await this.friendsService.getGlobalLeaderboard(timeFrame);
      // Mark current user
      return globalList.map((entry: any) => ({
        ...entry,
        isCurrentUser: entry.id === user.id,
      }));
    }
    return this.friendsService.getMiniLeaderboard(user.id, timeFrame);
  }

  /**
   * GET /friends/invitations - Get user's invitations
   */
  @Get("invitations")
  async getInvitations(@CurrentUser() user: any) {
    return this.friendsService.getInvitations(user.id);
  }

  /**
   * POST /friends/request - Send friend request
   */
  @Post("request")
  async sendRequest(
    @CurrentUser() user: any,
    @Body("friendId") friendId: string,
  ) {
    return this.friendsService.sendFriendRequest(user.id, friendId);
  }

  /**
   * POST /friends/accept - Accept friend request
   */
  @Post("accept")
  async acceptRequest(
    @CurrentUser() user: any,
    @Body("requesterId") requesterId: string,
  ) {
    return this.friendsService.acceptFriendRequest(user.id, requesterId);
  }

  /**
   * POST /friends/boost - Send boost to friend
   */
  @Post("boost")
  async sendBoost(
    @CurrentUser() user: any,
    @Body("friendId") friendId: string,
  ) {
    return this.friendsService.sendBoost(user.id, friendId);
  }

  /**
   * POST /friends/invite - Create invitation
   */
  @Post("invite")
  async createInvitation(
    @CurrentUser() user: any,
    @Body("email") email?: string,
    @Body("phone") phone?: string,
  ) {
    return this.friendsService.createInvitation(user.id, email, phone);
  }

  /**
   * DELETE /friends/:id - Remove friend
   */
  @Delete(":id")
  async removeFriend(@CurrentUser() user: any, @Param("id") friendId: string) {
    return this.friendsService.removeFriend(user.id, friendId);
  }
}
