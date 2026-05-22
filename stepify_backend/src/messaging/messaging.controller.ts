import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  UseGuards,
  ForbiddenException,
} from "@nestjs/common";
import { MessagingService } from "./messaging.service";
import { JwtAuthGuard } from "../auth/guards/jwt-auth.guard";
import { CurrentUser } from "../auth/decorators/current-user.decorator";
import { StartConversationDto, SendMessageDto } from "./dto/messaging.dto";
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
  ApiParam,
} from "@nestjs/swagger";

@ApiTags("Messaging")
@ApiBearerAuth()
@Controller("messaging")
@UseGuards(JwtAuthGuard)
export class MessagingController {
  constructor(private readonly messagingService: MessagingService) {}

  @Get("conversations/:userId")
  @ApiOperation({ summary: "Get user's conversations" })
  @ApiParam({ name: "userId", description: "User ID or 'me' for current user" })
  @ApiResponse({ status: 200, description: "Returns list of conversations" })
  async getConversations(
    @Param("userId") userId: string,
    @CurrentUser() user: any,
  ) {
    // IDOR Prevention: Support 'me' alias and block viewing conversations of other users
    const resolvedUserId = userId === "me" ? user.id : userId;
    if (resolvedUserId && resolvedUserId !== user.id) {
      throw new ForbiddenException(
        "Cannot query conversations for another user",
      );
    }
    return this.messagingService.getConversations(resolvedUserId);
  }

  @Get("conversations/:id/messages")
  @ApiOperation({ summary: "Get messages in a conversation" })
  @ApiResponse({ status: 200, description: "Returns list of messages" })
  @ApiResponse({
    status: 403,
    description: "Not a participant in this conversation",
  })
  async getMessages(
    @Param("id") conversationId: string,
    @CurrentUser() user: any,
  ) {
    // IDOR Prevention: Enforce that the user is actually a participant of this conversation
    const isParticipant = await this.messagingService.isParticipant(
      conversationId,
      user.id,
    );
    if (!isParticipant) {
      throw new ForbiddenException(
        "You are not a participant in this conversation",
      );
    }
    return this.messagingService.getMessages(conversationId);
  }

  @Post("conversations/start")
  @ApiOperation({ summary: "Start a conversation" })
  @ApiResponse({
    status: 201,
    description: "Conversation started or existing returned",
  })
  async startConversation(
    @Body() body: StartConversationDto,
    @CurrentUser() user: any,
  ) {
    // IDOR Prevention: Prevent starting a conversation on behalf of another user
    const resolvedUserId = body.userId || user.id;
    if (body.userId && body.userId !== user.id) {
      throw new ForbiddenException(
        "Cannot start a conversation as another user",
      );
    }
    return this.messagingService.startConversation(
      resolvedUserId,
      body.otherUserId,
    );
  }

  @Post("messages")
  @ApiOperation({ summary: "Send a message" })
  @ApiResponse({ status: 201, description: "Message sent successfully" })
  @ApiResponse({
    status: 403,
    description: "Not a participant or attempting to send as another user",
  })
  async sendMessage(@Body() body: SendMessageDto, @CurrentUser() user: any) {
    // IDOR Prevention: Ensure senderId matches authenticated user
    const resolvedSenderId = body.senderId || user.id;
    if (body.senderId && body.senderId !== user.id) {
      throw new ForbiddenException("Cannot send a message as another user");
    }
    // IDOR Prevention: Verify that user is actually a participant of this conversation
    const isParticipant = await this.messagingService.isParticipant(
      body.conversationId,
      user.id,
    );
    if (!isParticipant) {
      throw new ForbiddenException(
        "You cannot send messages to a conversation you are not part of",
      );
    }
    return this.messagingService.sendMessage(
      body.conversationId,
      resolvedSenderId,
      body.content,
    );
  }
}
