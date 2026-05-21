import {
  Controller,
  Get,
  Post,
  Param,
  Body,
  Query,
  UseGuards,
  Request,
} from "@nestjs/common";
import { CommunityService } from "./community.service";
import { JwtAuthGuard } from "../auth/guards/jwt-auth.guard";

@Controller("community")
@UseGuards(JwtAuthGuard)
export class CommunityController {
  constructor(private readonly communityService: CommunityService) {}

  // GET /api/v1/community/feed - Get feed posts
  @Get("feed")
  async getFeed(
    @Query("limit") limit?: number,
    @Query("cursor") cursor?: string,
  ) {
    return this.communityService.getFeed(limit || 20, cursor);
  }

  // POST /api/v1/community/posts - Create a manual post
  @Post("posts")
  async createPost(
    @Request() req: any,
    @Body() body: { content: string; type?: string },
  ) {
    return this.communityService.createPost(
      req.user.sub,
      body.content,
      body.type || "MANUAL",
    );
  }

  // POST /api/v1/community/posts/:id/react - React to a post
  @Post("posts/:id/react")
  async reactToPost(
    @Request() req: any,
    @Param("id") postId: string,
    @Body() body: { type?: string },
  ) {
    return this.communityService.reactToPost(
      req.user.sub,
      postId,
      body.type || "like",
    );
  }

  // GET /api/v1/community/posts/:id/comments - Get comments
  @Get("posts/:id/comments")
  async getComments(@Param("id") postId: string) {
    return this.communityService.getComments(postId);
  }

  // POST /api/v1/community/posts/:id/comments - Add comment
  @Post("posts/:id/comments")
  async addComment(
    @Request() req: any,
    @Param("id") postId: string,
    @Body() body: { content: string },
  ) {
    return this.communityService.addComment(req.user.sub, postId, body.content);
  }
}
