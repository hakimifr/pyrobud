import re
from .. import util, module, command
from typing import ClassVar
from telethon.tl.types import Message

class SrcModule(module.Module):
    name: ClassVar[str] = "Save Restricted Content"

    @command.desc("Save Restricted Content")
    @command.usage("Link of video", reply=True)
    async def cmd_saverc(self, ctx: command.Context):
        self.log.info("Parsing text")
        match = re.match(r"https://t\.me/(\w+)/(\d+)", ctx.input)
        if not match:
            return "Invalid link."

        chat_id = match.group(1)
        message_id = match.group(2)

        entity = await ctx.bot.client.get_entity(chat_id)
        self.log.info(f"Chat id: {chat_id}, {entity.id}")
        self.log.info(f"Message id: {message_id}")
        message = await ctx.bot.client.get_messages(chat_id,
                                                    ids=message_id)

        await ctx.msg.delete()
        await ctx.bot.client.send_file(ctx.msg.chat_id, message.media.video.file_id)
