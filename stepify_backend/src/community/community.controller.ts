import {
  Controller,
  Get,
  Post,
  Param,
  Body,
  Query,
  UseGuards,
} from "@nestjs/common";
import { CommunityService } from "./community.service";
import { JwtAuthGuard } from "../auth/guards/jwt-auth.guard";
import { CurrentUser } from "../auth/decorators/current-user.decorator";
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
} from "@nestjs/swagger";

@ApiTags("Community")
@ApiBearerAuth()
@Controller("community")
@UseGuards(JwtAuthGuard)
export class CommunityController {
  constructor(private readonly communityService: CommunityService) {}

  @Get("feed")
  @ApiOperation({ summary: "Get community feed posts" })
  @ApiResponse({ status: 200, description: "Returns list of feed posts" })
  async getFeed(
    @Query("limit") limit?: number,
    @Query("cursor") cursor?: string,
  ) {
    return this.communityService.getFeed(limit || 20, cursor);
  }

  @Post("posts")
  @ApiOperation({ summary: "Create a manual feed post" })
  @ApiResponse({ status: 201, description: "Post created successfully" })
  async createPost(
    @CurrentUser() user: any,
    @Body() body: { content: string; type?: string },
  ) {
    return this.communityService.createPost(
      user.id,
      body.content,
      body.type || "MANUAL",
    );
  }

  @Post("posts/:id/react")
  @ApiOperation({ summary: "React to a post (like, clap, fire)" })
  @ApiResponse({ status: 201, description: "Reaction toggled successfully" })
  async reactToPost(
    @CurrentUser() user: any,
    @Param("id") postId: string,
    @Body() body: { type?: string },
  ) {
    return this.communityService.reactToPost(
      user.id,
      postId,
      body.type || "like",
    );
  }

  @Get("posts/:id/comments")
  @ApiOperation({ summary: "Get comments for a post" })
  @ApiResponse({ status: 200, description: "Returns post comments" })
  async getComments(@Param("id") postId: string) {
    return this.communityService.getComments(postId);
  }

  @Post("posts/:id/comments")
  @ApiOperation({ summary: "Add comment to a post" })
  @ApiResponse({ status: 201, description: "Comment added successfully" })
  async addComment(
    @CurrentUser() user: any,
    @Param("id") postId: string,
    @Body() body: { content: string },
  ) {
    return this.communityService.addComment(user.id, postId, body.content);
  }
}
