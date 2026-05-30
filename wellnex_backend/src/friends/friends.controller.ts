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
import { JwtAuthGuard } from "../auth/guards/jwt-auth.guard";
import { CurrentUser } from "../auth/decorators/current-user.decorator";
import { FriendsService } from "./friends.service";
import {
  FriendRequestDto,
  AcceptRequestDto,
  CreateInvitationDto,
} from "./dto/friend.dto";
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
  ApiQuery,
} from "@nestjs/swagger";

@ApiTags("Friends")
@ApiBearerAuth()
@Controller("friends")
@UseGuards(JwtAuthGuard)
export class FriendsController {
  constructor(private readonly friendsService: FriendsService) {}

  @Get()
  @ApiOperation({ summary: "Get user's friends list" })
  @ApiResponse({ status: 200, description: "Returns list of friends" })
  async getFriends(@CurrentUser() user: any) {
    return this.friendsService.getFriends(user.id);
  }

  @Get("pending")
  @ApiOperation({ summary: "Get pending friend requests" })
  @ApiResponse({ status: 200, description: "Returns list of pending requests" })
  async getPendingRequests(@CurrentUser() user: any) {
    return this.friendsService.getPendingRequests(user.id);
  }

  @Get("search")
  @ApiOperation({ summary: "Search users by name or email" })
  @ApiQuery({ name: "q", required: true, description: "Search query string" })
  @ApiResponse({ status: 200, description: "Returns list of matching users" })
  async searchUsers(@CurrentUser() user: any, @Query("q") query: string) {
    return this.friendsService.searchUsers(user.id, query);
  }

  @Get("leaderboard")
  @ApiOperation({ summary: "Get global or friends mini leaderboard" })
  @ApiQuery({ name: "type", required: false, enum: ["global", "friends"] })
  @ApiQuery({
    name: "timeFrame",
    required: false,
    enum: ["daily", "weekly", "monthly", "allTime"],
  })
  @ApiResponse({ status: 200, description: "Returns leaderboard entries" })
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

  @Get("invitations")
  @ApiOperation({ summary: "Get user's sent invitations" })
  @ApiResponse({ status: 200, description: "Returns list of sent invitations" })
  async getInvitations(@CurrentUser() user: any) {
    return this.friendsService.getInvitations(user.id);
  }

  @Post("request")
  @ApiOperation({ summary: "Send a friend request" })
  @ApiResponse({ status: 201, description: "Friend request sent" })
  @ApiResponse({ status: 409, description: "Request already exists" })
  async sendRequest(@CurrentUser() user: any, @Body() body: FriendRequestDto) {
    return this.friendsService.sendFriendRequest(user.id, body.friendId);
  }

  @Post("accept")
  @ApiOperation({ summary: "Accept a friend request" })
  @ApiResponse({ status: 201, description: "Friend request accepted" })
  @ApiResponse({ status: 404, description: "Request not found" })
  async acceptRequest(
    @CurrentUser() user: any,
    @Body() body: AcceptRequestDto,
  ) {
    return this.friendsService.acceptFriendRequest(user.id, body.requesterId);
  }

  @Post("boost")
  @ApiOperation({ summary: "Send a daily boost to a friend" })
  @ApiResponse({ status: 201, description: "Boost sent successfully" })
  @ApiResponse({ status: 400, description: "You can only boost friends" })
  @ApiResponse({ status: 409, description: "Boost already sent today" })
  async sendBoost(
    @CurrentUser() user: any,
    @Body() body: FriendRequestDto, // reusing FriendRequestDto as it just needs friendId
  ) {
    return this.friendsService.sendBoost(user.id, body.friendId);
  }

  @Post("invite")
  @ApiOperation({ summary: "Create an invitation link" })
  @ApiResponse({ status: 201, description: "Invitation created" })
  async createInvitation(
    @CurrentUser() user: any,
    @Body() body: CreateInvitationDto,
  ) {
    return this.friendsService.createInvitation(
      user.id,
      body.email,
      body.phone,
    );
  }

  @Delete(":id")
  @ApiOperation({ summary: "Remove a friend" })
  @ApiResponse({ status: 200, description: "Friend removed successfully" })
  @ApiResponse({ status: 404, description: "Friendship not found" })
  async removeFriend(@CurrentUser() user: any, @Param("id") friendId: string) {
    return this.friendsService.removeFriend(user.id, friendId);
  }
}
